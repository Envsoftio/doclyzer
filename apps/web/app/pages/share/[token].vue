<script setup lang="ts">
import { formatDisplayDate } from "../../utils/formatDisplayDate";
interface PublicLabValueDto {
  parameterName: string;
  value: string;
  unit: string | null;
  sampleDate: string | null;
  referenceRange: string | null;
  rangeStatus: "below" | "within" | "above" | "unknown";
}

interface PublicReportDto {
  id: string;
  originalFileName: string;
  status: string;
  summary: string | null;
  createdAt: string;
  labValues: PublicLabValueDto[];
}

interface PublicShareDto {
  profileName: string;
  scope: string;
  reports: PublicReportDto[];
}

interface ApiSuccessResponse {
  success: true;
  data: PublicShareDto;
  correlationId: string;
}

const { incident: incidentStatus } = useIncidentStatus();

const route = useRoute();
const token = route.params.token as string;
const config = useRuntimeConfig();

useHead({
  meta: [{ name: "robots", content: "noindex, nofollow" }],
});

const shareData = ref<PublicShareDto | null>(null);
const errorStatus = ref<number | null>(null);
const loading = ref(true);
const accessCode = ref("");
const unlockedCode = ref("");
const accessCodeError = ref("");
const unlocking = ref(false);
const downloadingReportId = ref<string | null>(null);
const downloadError = ref("");

onMounted(async () => {
  try {
    const res = await $fetch<ApiSuccessResponse>(
      `${config.public.apiBaseUrl}/sharing/public/${encodeURIComponent(token)}`,
    );
    shareData.value = res.data;
  } catch (err: unknown) {
    const fetchError = err as { response?: { status?: number } };
    errorStatus.value = fetchError?.response?.status ?? 500;
  } finally {
    loading.value = false;
  }
});

async function unlockShare() {
  if (unlocking.value) return;
  accessCodeError.value = "";
  unlocking.value = true;
  try {
    const res = await $fetch<ApiSuccessResponse>(
      `${config.public.apiBaseUrl}/sharing/public/${encodeURIComponent(token)}/unlock`,
      {
        method: "POST",
        body: { accessCode: accessCode.value.replace(/\s/g, "") },
      },
    );
    shareData.value = res.data;
    errorStatus.value = null;
    unlockedCode.value = accessCode.value.replace(/\s/g, "");
    accessCode.value = "";
  } catch (err: unknown) {
    const fetchError = err as { response?: { status?: number } };
    const status = fetchError?.response?.status ?? 500;
    if (status === 403)
      accessCodeError.value =
        "The access code is incorrect. Check the code and try again.";
    else if (status === 429)
      accessCodeError.value = "Too many attempts. Try again later.";
    else errorStatus.value = status;
  } finally {
    unlocking.value = false;
  }
}

async function downloadOriginal(report: PublicReportDto) {
  if (downloadingReportId.value) return;
  downloadError.value = "";
  downloadingReportId.value = report.id;
  try {
    const blob = await $fetch<Blob>(
      `${config.public.apiBaseUrl}/sharing/public/${encodeURIComponent(token)}/reports/${encodeURIComponent(report.id)}/original`,
      {
        method: "POST",
        body: { accessCode: unlockedCode.value },
        responseType: "blob",
      },
    );
    const objectUrl = URL.createObjectURL(blob);
    const anchor = document.createElement("a");
    anchor.href = objectUrl;
    anchor.download = report.originalFileName;
    document.body.appendChild(anchor);
    anchor.click();
    anchor.remove();
    setTimeout(() => URL.revokeObjectURL(objectUrl), 30_000);
  } catch (err: unknown) {
    const fetchError = err as { response?: { status?: number } };
    if (fetchError?.response?.status === 410) errorStatus.value = 410;
    else
      downloadError.value =
        "The original could not be downloaded. Check the link and try again.";
  } finally {
    downloadingReportId.value = null;
  }
}

function formatDate(iso: string): string {
  return formatDisplayDate(iso);
}

interface TrendPoint {
  date: string;
  value: string;
  unit: string | null;
  referenceRange: string | null;
  rangeStatus: PublicLabValueDto["rangeStatus"];
}

interface TrendRow {
  parameterName: string;
  unit: string | null;
  valuesByDate: Map<string, TrendPoint>;
}

function computeTrendRows(reports: PublicReportDto[]): TrendRow[] {
  const paramMap = new Map<string, TrendRow>();
  for (const report of reports) {
    for (const lv of report.labValues) {
      if (!lv.sampleDate) continue;
      const key = JSON.stringify([
        lv.parameterName.trim().toLowerCase(),
        lv.unit?.trim().toLowerCase() ?? "",
      ]);
      if (!paramMap.has(key)) {
        paramMap.set(key, {
          parameterName: lv.parameterName,
          unit: lv.unit,
          valuesByDate: new Map(),
        });
      }
      paramMap.get(key)!.valuesByDate.set(lv.sampleDate, {
        date: lv.sampleDate,
        value: lv.value,
        unit: lv.unit,
        referenceRange: lv.referenceRange,
        rangeStatus: lv.rangeStatus,
      });
    }
  }
  return [...paramMap.values()]
    .filter((row) => row.valuesByDate.size >= 2)
    .sort((a, b) => a.parameterName.localeCompare(b.parameterName));
}

function rangeStatusLabel(status: PublicLabValueDto["rangeStatus"]): string {
  return {
    below: "Below range",
    within: "In listed range",
    above: "Above range",
    unknown: "",
  }[status];
}

const sortedReports = computed(() => {
  if (!shareData.value) return [];
  return [...shareData.value.reports].sort(
    (a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime(),
  );
});

const trends = computed(() => {
  if (!shareData.value) return [];
  return computeTrendRows(shareData.value.reports);
});

const scopeLabel = computed(() => {
  if (shareData.value?.scope === "selected_results")
    return "Selected test results";
  if (shareData.value?.scope === "selected_reports")
    return "Selected original reports";
  return "Original reports";
});

function printPage() {
  if (typeof window !== "undefined") window.print();
}

function splitPrintSummary(summary: string | null): string[] {
  if (!summary) return [];
  const chunks: string[] = [];
  let start = 0;
  while (start < summary.length) {
    let end = Math.min(start + 500, summary.length);
    if (end < summary.length) {
      const wordEnd = summary.lastIndexOf(" ", end);
      if (wordEnd > start + 250) end = wordEnd + 1;
    }
    chunks.push(summary.slice(start, end));
    start = end;
  }
  return chunks;
}

function chunkPrintResults(values: PublicLabValueDto[]): PublicLabValueDto[][] {
  const groups: PublicLabValueDto[][] = [];
  for (let index = 0; index < values.length; index += 3)
    groups.push(values.slice(index, index + 3));
  return groups;
}

const trendDates = computed(() => {
  if (trends.value.length === 0) return [];
  return [
    ...new Set(trends.value.flatMap((row) => [...row.valuesByDate.keys()])),
  ].sort((a, b) => new Date(a).getTime() - new Date(b).getTime());
});
</script>

<template>
  <div
    id="top"
    class="share-page"
    :class="{ 'has-print-document': !!shareData }"
  >
    <header class="site-header no-print">
      <div class="shell header-inner">
        <NuxtLink class="brand" to="/" aria-label="Doclyzer home">
          <span class="brand-mark" aria-hidden="true"
            ><svg viewBox="0 0 24 24">
              <path d="M4 2h7c5 0 9 4 9 10s-4 10-9 10h-7z" />
              <path d="M1 12h5l3-6 4 12 3-6h7" /></svg
          ></span>
          <span>doclyzer</span>
        </NuxtLink>
        <span class="header-label">SHARED HEALTH REPORTS</span>
      </div>
    </header>

    <main class="shell main-content">
      <div class="incident-slot">
        <IncidentBanner :incident="incidentStatus" surface="web_share" />
      </div>

      <div v-if="loading" class="state-card" role="status" aria-live="polite">
        <span class="loading-spinner" aria-hidden="true" />
        <p class="eyebrow">SHARED REPORT</p>
        <h1>Opening shared reports</h1>
        <p class="state-copy">
          Checking this link and loading the included information.
        </p>
      </div>

      <div v-else-if="errorStatus === 404" class="state-card" role="alert">
        <span class="state-icon" aria-hidden="true">?</span>
        <p class="eyebrow">LINK UNAVAILABLE</p>
        <h1>Link not found</h1>
        <p class="state-copy">
          This share link does not exist. Check that the full link was copied.
        </p>
      </div>

      <div v-else-if="errorStatus === 410" class="state-card" role="alert">
        <span class="state-icon" aria-hidden="true">×</span>
        <p class="eyebrow">LINK UNAVAILABLE</p>
        <h1>Link expired or revoked</h1>
        <p class="state-copy">
          Ask the person who shared it to send you a new link.
        </p>
      </div>

      <form
        v-else-if="errorStatus === 403"
        class="state-card access-code-form"
        @submit.prevent="unlockShare"
      >
        <span class="state-icon lock-icon" aria-hidden="true">
          <svg viewBox="0 0 24 24" fill="none">
            <rect x="5" y="10" width="14" height="11" rx="2" />
            <path d="M8 10V7a4 4 0 0 1 8 0v3" />
          </svg>
        </span>
        <p class="eyebrow">ACCESS CODE REQUIRED</p>
        <h1>Open shared reports</h1>
        <p id="access-code-help" class="state-copy">
          Enter the six digit code sent separately by the person who shared this
          link.
        </p>
        <label for="share-access-code">Access code</label>
        <input
          id="share-access-code"
          v-model="accessCode"
          type="text"
          inputmode="numeric"
          autocomplete="one-time-code"
          maxlength="7"
          aria-describedby="access-code-help"
          required
          placeholder="6 digit code"
        />
        <p v-if="accessCodeError" class="form-error" role="alert">
          {{ accessCodeError }}
        </p>
        <button class="primary-button" type="submit" :disabled="unlocking">
          {{ unlocking ? "Checking code…" : "Open reports" }}
        </button>
      </form>

      <div v-else-if="errorStatus !== null" class="state-card" role="alert">
        <span class="state-icon" aria-hidden="true">!</span>
        <p class="eyebrow">UNABLE TO LOAD</p>
        <h1>Something went wrong</h1>
        <p class="state-copy">
          We could not open the shared reports right now. Please try again
          later.
        </p>
      </div>

      <div v-else-if="shareData" class="share-content">
        <section class="share-hero">
          <div class="hero-body">
            <p class="eyebrow">A DOCLYZER SHARE</p>
            <h1>
              {{ shareData.profileName }}'s
              {{
                shareData.scope === "selected_results"
                  ? "shared results"
                  : "health reports"
              }}
            </h1>
            <div class="hero-actions">
              <span class="scope-pill">{{ scopeLabel }}</span>
              <span class="count-pill"
                >{{
                  shareData.scope === "selected_results" ? "Results from " : ""
                }}{{ shareData.reports.length }}
                {{ shareData.reports.length === 1 ? "report" : "reports"
                }}{{
                  shareData.scope === "selected_results" ? "" : " included"
                }}</span
              >
              <button
                class="secondary-button no-print"
                type="button"
                @click="printPage"
              >
                Print / Save as PDF
              </button>
            </div>
          </div>
        </section>

        <p v-if="downloadError" class="download-error" role="alert">
          {{ downloadError }}
        </p>

        <section v-if="trends.length > 0" class="content-card trends-section">
          <div class="section-heading">
            <div>
              <p class="eyebrow">OVERVIEW</p>
              <h2>Trends at a glance</h2>
              <p>
                Results with recorded collection dates in more than one included
                report.
              </p>
            </div>
          </div>
          <div class="table-scroll">
            <table
              class="data-table trend-table"
              aria-label="Shared results over time"
            >
              <thead>
                <tr>
                  <th scope="col">Parameter</th>
                  <th v-for="date in trendDates" :key="date" scope="col">
                    {{ formatDate(date) }}
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="row in trends"
                  :key="`${row.parameterName}:${row.unit}`"
                >
                  <th scope="row">
                    {{ row.parameterName
                    }}<span v-if="row.unit" class="trend-unit">{{
                      row.unit
                    }}</span>
                  </th>
                  <td v-for="date in trendDates" :key="date">
                    <template v-if="row.valuesByDate.has(date)">
                      <span class="trend-value"
                        >{{ row.valuesByDate.get(date)?.value
                        }}<span
                          v-if="row.valuesByDate.get(date)?.unit"
                          class="unit"
                        >
                          {{ row.valuesByDate.get(date)?.unit }}</span
                        ></span
                      >
                      <span
                        v-if="
                          row.valuesByDate.get(date)?.referenceRange?.trim()
                        "
                        class="trend-range"
                        >Lab range
                        {{ row.valuesByDate.get(date)?.referenceRange }}</span
                      >
                      <span
                        v-if="
                          row.valuesByDate.get(date)?.rangeStatus &&
                          row.valuesByDate.get(date)?.rangeStatus !== 'unknown'
                        "
                        class="trend-status"
                        :class="`status-${row.valuesByDate.get(date)?.rangeStatus}`"
                        >{{
                          rangeStatusLabel(
                            row.valuesByDate.get(date)?.rangeStatus ??
                              "unknown",
                          )
                        }}</span
                      >
                    </template>
                    <span v-else class="missing-value">—</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>

        <section class="reports-section">
          <div class="section-heading reports-heading">
            <div>
              <p class="eyebrow">SHARED WITH YOU</p>
              <h2>
                {{
                  shareData.scope === "selected_results"
                    ? "Included results"
                    : "Included reports"
                }}
              </h2>
              <p>
                {{
                  shareData.scope === "selected_results"
                    ? "Only the selected test results are shown. Original files are not included."
                    : "Original files are available when this link includes full reports."
                }}
              </p>
            </div>
            <span class="section-count">{{ shareData.reports.length }}</span>
          </div>

          <div
            v-if="shareData.reports.length === 0"
            class="content-card empty-state"
          >
            <span class="state-icon" aria-hidden="true">—</span>
            <h3>No parsed reports available</h3>
            <p>This link does not currently include any parsed reports.</p>
          </div>

          <article
            v-for="report in sortedReports"
            :key="report.id"
            class="content-card report-card"
          >
            <div class="report-heading">
              <div class="report-icon" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none">
                  <path
                    d="M7 3h7l4 4v13a1 1 0 0 1-1 1H7a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z"
                  />
                  <path d="M14 3v5h4M8 13h8M8 17h6" />
                </svg>
              </div>
              <div class="report-title">
                <p class="report-date">{{ formatDate(report.createdAt) }}</p>
                <h3>{{ report.originalFileName }}</h3>
              </div>
              <button
                v-if="shareData.scope !== 'selected_results'"
                class="download-button no-print"
                type="button"
                :disabled="downloadingReportId !== null"
                @click="downloadOriginal(report)"
              >
                {{
                  downloadingReportId === report.id
                    ? "Downloading…"
                    : "Download original"
                }}
              </button>
            </div>

            <div v-if="report.summary" class="report-summary-block">
              <p class="eyebrow">REPORT SUMMARY</p>
              <blockquote class="report-summary">
                {{ report.summary }}
              </blockquote>
              <AiDisclaimerNote class="report-summary-disclaimer" />
            </div>

            <div v-if="report.labValues.length > 0" class="results-block">
              <h4>Results</h4>
              <p class="results-note">
                Where possible, values are compared with the lab range printed
                on the report. A range may not apply to every person.
              </p>
              <div class="result-grid">
                <div
                  v-for="(lv, index) in report.labValues"
                  :key="`${lv.parameterName}:${index}`"
                  class="result-card"
                  :class="`result-${lv.rangeStatus ?? 'unknown'}`"
                >
                  <strong class="result-name">{{ lv.parameterName }}</strong>
                  <p class="result-reading">
                    {{ lv.value
                    }}<span v-if="lv.unit" class="result-unit">
                      {{ lv.unit }}</span
                    >
                  </p>
                  <div class="result-meta">
                    <span
                      v-if="lv.rangeStatus && lv.rangeStatus !== 'unknown'"
                      class="result-status"
                      :class="`status-${lv.rangeStatus}`"
                      >{{ rangeStatusLabel(lv.rangeStatus) }}</span
                    >
                    <span class="result-range"
                      >Lab reference range
                      <strong>{{
                        lv.referenceRange?.trim() || "Not available"
                      }}</strong></span
                    >
                  </div>
                  <p v-if="lv.sampleDate" class="result-date">
                    Collected {{ formatDate(lv.sampleDate) }}
                  </p>
                </div>
              </div>
            </div>
          </article>
        </section>

        <a class="back-to-top no-print" href="#top">Back to top ↑</a>
      </div>
    </main>

    <table
      v-if="shareData"
      class="print-document"
      aria-label="Printable shared health reports"
    >
      <thead>
        <tr>
          <th scope="col">
            <div class="print-masthead">
              <span class="print-brand">doclyzer</span>
              <span class="print-masthead-label">SHARED HEALTH REPORTS</span>
            </div>
          </th>
        </tr>
      </thead>
      <tfoot>
        <tr>
          <td>
            <div class="print-colophon">
              <span
                ><strong>doclyzer</strong> · Health reports, organized.</span
              >
              <span>Shared health information · Handle with care</span>
            </div>
          </td>
        </tr>
      </tfoot>
      <tbody>
        <tr class="print-intro-row">
          <td>
            <p class="print-eyebrow">A DOCLYZER SHARE</p>
            <h1>
              {{ shareData.profileName }}'s
              {{
                shareData.scope === "selected_results"
                  ? "shared results"
                  : "health reports"
              }}
            </h1>
            <p>
              {{ scopeLabel }} · {{ shareData.reports.length }}
              {{ shareData.reports.length === 1 ? "report" : "reports" }}
            </p>
          </td>
        </tr>
        <template v-if="trends.length > 0">
          <tr class="print-section-row">
            <td>
              <h2>Trends at a glance</h2>
              <p>
                Results with recorded collection dates in more than one included
                report.
              </p>
            </td>
          </tr>
          <template
            v-for="row in trends"
            :key="`${row.parameterName}:${row.unit}`"
          >
            <template v-for="date in trendDates" :key="date">
              <tr v-if="row.valuesByDate.has(date)" class="print-data-row">
                <td>
                  <div class="print-trend-entry">
                    <strong
                      >{{ row.parameterName
                      }}<span v-if="row.unit"> ({{ row.unit }})</span></strong
                    >
                    <span>{{ formatDate(date) }}</span>
                    <strong
                      >{{ row.valuesByDate.get(date)?.value
                      }}<span v-if="row.valuesByDate.get(date)?.unit">
                        {{ row.valuesByDate.get(date)?.unit }}</span
                      ></strong
                    >
                    <span
                      v-if="row.valuesByDate.get(date)?.referenceRange?.trim()"
                      >Lab range
                      {{ row.valuesByDate.get(date)?.referenceRange }}</span
                    >
                    <span
                      v-if="
                        row.valuesByDate.get(date)?.rangeStatus &&
                        row.valuesByDate.get(date)?.rangeStatus !== 'unknown'
                      "
                      >{{
                        rangeStatusLabel(
                          row.valuesByDate.get(date)?.rangeStatus ?? "unknown",
                        )
                      }}</span
                    >
                  </div>
                </td>
              </tr>
            </template>
          </template>
        </template>
        <tr class="print-section-row">
          <td>
            <h2>
              {{
                shareData.scope === "selected_results"
                  ? "Included results"
                  : "Included reports"
              }}
            </h2>
            <p>
              {{
                shareData.scope === "selected_results"
                  ? "Only the selected test results are shown. Original files are not included."
                  : "Original files are available when this link includes full reports."
              }}
            </p>
          </td>
        </tr>
        <tr v-if="shareData.reports.length === 0" class="print-data-row">
          <td>No parsed reports available.</td>
        </tr>
        <template v-for="report in sortedReports" :key="report.id">
          <tr class="print-report-heading">
            <td>
              <span>{{ formatDate(report.createdAt) }}</span>
              <h3>{{ report.originalFileName }}</h3>
            </td>
          </tr>
          <template v-if="report.summary">
            <tr
              v-for="(chunk, chunkIndex) in splitPrintSummary(report.summary)"
              :key="chunkIndex"
              class="print-summary-row"
            >
              <td>
                <p v-if="chunkIndex === 0" class="print-eyebrow">
                  REPORT SUMMARY
                </p>
                <p class="print-summary">{{ chunk }}</p>
              </td>
            </tr>
            <tr class="print-disclaimer-row">
              <td><AiDisclaimerNote /></td>
            </tr>
          </template>
          <tr v-if="report.labValues.length > 0" class="print-results-heading">
            <td>
              <h4>Results</h4>
              <p>
                Where possible, values are compared with the lab range printed
                on the report. A range may not apply to every person.
              </p>
            </td>
          </tr>
          <tr
            v-for="(group, groupIndex) in chunkPrintResults(report.labValues)"
            :key="groupIndex"
            class="print-result-group-row"
          >
            <td>
              <div class="result-grid">
                <div
                  v-for="(lv, index) in group"
                  :key="`${lv.parameterName}:${index}`"
                  class="result-card"
                  :class="`result-${lv.rangeStatus ?? 'unknown'}`"
                >
                  <strong class="result-name">{{ lv.parameterName }}</strong>
                  <p class="result-reading">
                    {{ lv.value
                    }}<span v-if="lv.unit" class="result-unit">
                      {{ lv.unit }}</span
                    >
                  </p>
                  <div class="result-meta">
                    <span
                      v-if="lv.rangeStatus && lv.rangeStatus !== 'unknown'"
                      class="result-status"
                      :class="`status-${lv.rangeStatus}`"
                      >{{ rangeStatusLabel(lv.rangeStatus) }}</span
                    >
                    <span class="result-range"
                      >Lab reference range
                      <strong>{{
                        lv.referenceRange?.trim() || "Not available"
                      }}</strong></span
                    >
                  </div>
                  <p v-if="lv.sampleDate" class="result-date">
                    Collected {{ formatDate(lv.sampleDate) }}
                  </p>
                </div>
              </div>
            </td>
          </tr>
        </template>
      </tbody>
    </table>

    <footer class="site-footer no-print">
      <div class="shell footer-inner">
        <NuxtLink class="brand" to="/" aria-label="Doclyzer home"
          ><span class="brand-mark" aria-hidden="true"
            ><svg viewBox="0 0 24 24">
              <path d="M4 2h7c5 0 9 4 9 10s-4 10-9 10h-7z" />
              <path d="M1 12h5l3-6 4 12 3-6h7" /></svg></span
          ><span>doclyzer</span></NuxtLink
        >
        <span>A shared view of health reports</span>
      </div>
    </footer>
  </div>
</template>

<style scoped>
.share-page {
  --ink: #153d4a;
  --forest: #115278;
  --muted: #536e78;
  --line: #d6e5e5;
  --cream: #fafcfb;
  --soft-green: #e6f4f1;
  min-height: 100vh;
  background: var(--cream);
  color: var(--ink);
  font-family: "Plus Jakarta Sans", system-ui, sans-serif;
  line-height: 1.55;
}
.share-page * {
  box-sizing: border-box;
}
.share-page :focus-visible {
  outline: 3px solid #16aaa4;
  outline-offset: 3px;
}
.shell {
  width: min(100% - 48px, 980px);
  margin-inline: auto;
}
.site-header {
  border-bottom: 1px solid var(--line);
  background: #fafcfb;
}
.header-inner {
  min-height: 82px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
}
.brand {
  display: inline-flex;
  align-items: center;
  gap: 11px;
  color: var(--ink);
  text-decoration: none;
  font-size: 24px;
  font-weight: 800;
  letter-spacing: -0.045em;
}
.brand-mark {
  width: 38px;
  height: 38px;
  display: grid;
  place-items: center;
  border-radius: 11px;
  background: linear-gradient(90deg, #1ebeb6, #115278);
}
.brand-mark svg {
  width: 25px;
  height: 25px;
  fill: none;
  stroke: #fff;
  stroke-width: 2.5;
  stroke-linecap: round;
  stroke-linejoin: round;
}
.header-label,
.eyebrow {
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 0.16em;
}
.header-label {
  color: #126b67;
}
.main-content {
  padding-block: 28px 80px;
  min-height: calc(100vh - 160px);
}
.incident-slot {
  margin-bottom: 28px;
}
.incident-slot:empty {
  display: none;
}
.eyebrow {
  color: #126b67;
  margin: 0 0 12px;
  text-transform: uppercase;
}
.state-card {
  width: min(100%, 560px);
  margin: clamp(20px, 8vh, 96px) auto 0;
  padding: clamp(28px, 5vw, 52px);
  border: 1px solid var(--line);
  border-radius: 24px;
  background: #fff;
  box-shadow: 0 20px 50px #103e540d;
}
.state-card h1 {
  font:
    700 clamp(29px, 4vw, 42px)/1.13 "Plus Jakarta Sans",
    sans-serif;
  letter-spacing: -0.04em;
  margin: 0 0 16px;
}
.state-copy {
  color: var(--muted);
  margin: 0;
  max-width: 44ch;
}
.state-icon {
  width: 56px;
  height: 56px;
  display: grid;
  place-items: center;
  background: var(--soft-green);
  border-radius: 16px;
  color: var(--forest);
  font:
    700 27px "Plus Jakarta Sans",
    sans-serif;
  margin-bottom: 26px;
}
.state-icon svg {
  width: 27px;
  height: 27px;
  stroke: currentColor;
  stroke-width: 1.8;
  stroke-linecap: round;
  stroke-linejoin: round;
}
.loading-spinner {
  display: block;
  width: 48px;
  height: 48px;
  margin-bottom: 28px;
  border-radius: 50%;
  border: 3px solid #d6e5e5;
  border-top-color: #1ebeb6;
  animation: spin 1s linear infinite;
}
@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
.access-code-form label {
  display: block;
  margin: 28px 0 8px;
  font-size: 13px;
  font-weight: 700;
}
.access-code-form input {
  width: 100%;
  min-height: 54px;
  padding: 12px 15px;
  border: 1px solid #b4ccd0;
  border-radius: 12px;
  background: #fff;
  color: var(--ink);
  font:
    600 16px "Plus Jakarta Sans",
    sans-serif;
  letter-spacing: 0.08em;
}
.access-code-form input::placeholder {
  color: #788e96;
  font-weight: 500;
  letter-spacing: normal;
}
.form-error,
.download-error {
  color: #9b3030;
  background: #fff2ef;
  border: 1px solid #ecc9c1;
  border-radius: 12px;
  padding: 12px 14px;
  font-size: 13px;
}
.form-error {
  margin: 12px 0 0;
}
.primary-button,
.secondary-button,
.download-button {
  font:
    700 13px "Plus Jakarta Sans",
    sans-serif;
  cursor: pointer;
  min-height: 46px;
  border-radius: 11px;
  padding: 11px 17px;
}
.primary-button {
  width: 100%;
  margin-top: 18px;
  border: 1px solid var(--forest);
  background: var(--forest);
  color: #fff;
}
.primary-button:hover {
  background: #0d405e;
}
.primary-button:disabled,
.download-button:disabled {
  opacity: 0.6;
  cursor: wait;
}
.share-content {
  display: grid;
  grid-template-columns: minmax(0, 1fr);
  min-width: 0;
  gap: 24px;
}
.share-hero {
  border: 1px solid var(--line);
  border-radius: 18px;
  padding: 24px 28px;
  background: #eaf5f3;
}
.share-hero .eyebrow {
  margin-bottom: 6px;
}
.share-hero h1 {
  font:
    700 clamp(27px, 3.4vw, 36px)/1.18 "Plus Jakarta Sans",
    sans-serif;
  letter-spacing: -0.035em;
  overflow-wrap: anywhere;
  margin: 0;
}
.hero-actions {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
  margin-top: 16px;
}
.scope-pill,
.count-pill,
.section-count {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 999px;
  background: #fff;
  color: var(--forest);
  border: 1px solid #c8dfdf;
  font-size: 12px;
  font-weight: 800;
}
.scope-pill {
  min-height: 34px;
  padding: 5px 12px;
  background: #115278;
  border-color: #115278;
  color: #fff;
}
.count-pill {
  min-height: 34px;
  padding: 5px 12px;
}
.secondary-button {
  min-height: 36px;
  margin-left: auto;
  padding: 7px 12px;
  border: 1px solid var(--forest);
  background: transparent;
  color: var(--forest);
}
.secondary-button:hover,
.download-button:hover {
  background: #e6f4f1;
}
.download-error {
  margin: 0;
}
.content-card {
  min-width: 0;
  border: 1px solid var(--line);
  border-radius: 20px;
  background: #fff;
  box-shadow: 0 10px 30px #103e5409;
}
.trends-section {
  padding: clamp(22px, 4vw, 34px);
}
.section-heading {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  gap: 16px;
  margin-bottom: 22px;
}
.section-heading h2 {
  font:
    700 clamp(24px, 3vw, 30px)/1.2 "Plus Jakarta Sans",
    sans-serif;
  letter-spacing: -0.04em;
  margin: 0 0 6px;
}
.section-heading p:not(.eyebrow) {
  color: var(--muted);
  font-size: 13px;
  margin: 0;
}
.table-scroll {
  max-width: 100%;
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  border: 1px solid var(--line);
  border-radius: 12px;
}
.data-table {
  width: 100%;
  min-width: 520px;
  border-collapse: collapse;
  font-size: 13px;
}
.data-table th,
.data-table td {
  padding: 13px 16px;
  text-align: left;
  vertical-align: top;
  border-bottom: 1px solid #e7ece5;
}
.data-table thead th {
  background: #edf7f6;
  color: #536e78;
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 0.05em;
  white-space: nowrap;
}
.data-table tbody th {
  font-weight: 700;
}
.data-table tbody tr:last-child th,
.data-table tbody tr:last-child td {
  border-bottom: 0;
}
.data-table tbody tr:nth-child(even) {
  background: #fafcfb;
}
.trend-table td,
.trend-table thead th:not(:first-child) {
  white-space: nowrap;
}
.trend-unit {
  display: block;
  color: var(--muted);
  font-size: 11px;
  font-weight: 500;
}
.trend-value {
  display: block;
  font-weight: 700;
}
.trend-range {
  display: block;
  margin-top: 4px;
  color: var(--muted);
  font-size: 11px;
  white-space: normal;
  overflow-wrap: anywhere;
}
.trend-status {
  display: block;
  width: max-content;
  margin-top: 4px;
  font-size: 11px;
  font-weight: 700;
}
.unit {
  color: var(--muted);
  font-size: 12px;
}
.missing-value {
  color: #8ca3a9;
}
.reports-section {
  display: grid;
  gap: 14px;
}
.reports-heading {
  margin: 0 2px 7px;
}
.section-count {
  min-width: 34px;
  height: 34px;
}
.empty-state {
  text-align: center;
  padding: 40px 24px;
}
.empty-state .state-icon {
  margin: 0 auto 18px;
}
.empty-state h3 {
  font:
    700 21px "Plus Jakarta Sans",
    sans-serif;
  margin: 0 0 7px;
}
.empty-state p {
  color: var(--muted);
  margin: 0;
}
.report-card {
  padding: clamp(20px, 3.5vw, 30px);
}
.report-heading {
  display: flex;
  align-items: center;
  gap: 14px;
}
.report-icon {
  display: grid;
  place-items: center;
  flex: 0 0 44px;
  height: 48px;
  background: #e6f4f1;
  color: var(--forest);
  border-radius: 12px;
}
.report-icon svg {
  width: 23px;
  height: 23px;
  stroke: currentColor;
  stroke-width: 1.6;
  stroke-linecap: round;
  stroke-linejoin: round;
}
.report-title {
  min-width: 0;
  flex: 1;
}
.report-date {
  color: var(--muted);
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  margin: 0 0 3px;
}
.report-title h3 {
  overflow-wrap: anywhere;
  font:
    700 17px/1.3 "Plus Jakarta Sans",
    sans-serif;
  letter-spacing: -0.02em;
  margin: 0;
}
.download-button {
  border: 1px solid #c8dfdf;
  background: #fff;
  color: var(--forest);
  white-space: nowrap;
}
.report-summary-block,
.results-block {
  border-top: 1px solid var(--line);
  margin-top: 22px;
  padding-top: 20px;
}
.report-summary-block .eyebrow {
  margin-bottom: 10px;
}
.report-summary {
  background: #f0f7f6;
  border-left: 3px solid #1ebeb6;
  border-radius: 0 10px 10px 0;
  padding: 14px 18px;
  margin: 0 0 10px;
  color: var(--ink);
  font-size: 14px;
  line-height: 1.7;
  white-space: pre-wrap;
}
.results-block h4 {
  font:
    700 15px "Plus Jakarta Sans",
    sans-serif;
  margin: 0 0 12px;
}
.results-note {
  max-width: 70ch;
  color: var(--muted);
  font-size: 12px;
  margin: -4px 0 16px;
}
.result-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px;
}
.result-card {
  display: flex;
  flex-direction: column;
  min-width: 0;
  padding: 14px 15px;
  border: 1px solid var(--line);
  border-radius: 16px;
  background: #f5f8f7;
  break-inside: avoid;
}
.result-within {
  border-color: #cce5d3;
  background: #e8f5ec;
}
.result-below,
.result-above {
  border-color: #f2d1cc;
  background: #fff0ed;
}
.result-name {
  display: block;
  font-size: 14px;
  line-height: 1.35;
  overflow-wrap: anywhere;
}
.result-meta {
  display: flex;
  align-items: flex-start;
  flex-direction: column;
  gap: 8px;
  margin-top: auto;
}
.result-status {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 4px 8px;
  border-radius: 999px;
  font-size: 11px;
  font-weight: 700;
  line-height: 1.4;
  white-space: nowrap;
}
.result-status::before,
.trend-status::before {
  display: inline-block;
  margin-right: 4px;
}
.status-within {
  color: #166534;
}
.status-within.result-status {
  background: #d8efdf;
}
.status-within::before {
  content: "✓";
}
.status-below,
.status-above {
  color: #96392f;
}
.status-below.result-status,
.status-above.result-status {
  background: #fbe4df;
}
.status-below::before {
  content: "↓";
}
.status-above::before {
  content: "↑";
}
.result-reading {
  font:
    800 clamp(24px, 2.8vw, 29px)/1.2 "Plus Jakarta Sans",
    sans-serif;
  letter-spacing: -0.04em;
  margin: 8px 0 10px;
  overflow-wrap: anywhere;
}
.result-within .result-reading {
  color: #166534;
}
.result-below .result-reading,
.result-above .result-reading {
  color: #96392f;
}
.result-unit {
  font:
    700 14px "Plus Jakarta Sans",
    sans-serif;
  letter-spacing: normal;
}
.result-range {
  display: grid;
  gap: 2px;
  width: 100%;
  padding-top: 8px;
  border-top: 1px solid var(--line);
  color: var(--muted);
  font-size: 11px;
  overflow-wrap: anywhere;
}
.result-range strong {
  color: var(--ink);
  font-size: 12px;
  font-weight: 700;
}
.result-date {
  color: var(--muted);
  font-size: 11px;
  margin: 7px 0 0;
}
.back-to-top {
  justify-self: end;
  color: var(--forest);
  font-size: 13px;
  font-weight: 800;
  text-decoration: none;
  border-bottom: 1px solid #86b8bb;
  padding-bottom: 4px;
}
.print-document {
  display: none;
}
.site-footer {
  border-top: 1px solid var(--line);
}
.footer-inner {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  padding-block: 24px;
  color: var(--muted);
  font-size: 11px;
}
.footer-inner .brand {
  font-size: 20px;
}
.footer-inner .brand-mark {
  width: 30px;
  height: 30px;
  border-radius: 9px;
}
.footer-inner .brand-mark svg {
  width: 20px;
  height: 20px;
}
@media (max-width: 900px) {
  .result-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}
@media (max-width: 640px) {
  .shell {
    width: min(100% - 32px, 980px);
  }
  .header-inner {
    min-height: 70px;
  }
  .header-label {
    font-size: 9px;
    text-align: right;
  }
  .brand {
    font-size: 23px;
  }
  .brand-mark {
    width: 32px;
    height: 32px;
    border-radius: 9px;
  }
  .brand-mark svg {
    width: 21px;
    height: 21px;
  }
  .main-content {
    padding-block: 24px 56px;
  }
  .share-content {
    gap: 20px;
  }
  .share-hero {
    border-radius: 16px;
    padding: 18px;
  }
  .hero-actions {
    gap: 8px;
    margin-top: 14px;
  }
  .secondary-button {
    margin-left: 0;
  }
  .section-heading {
    align-items: flex-start;
  }
  .report-heading {
    align-items: flex-start;
    flex-wrap: wrap;
  }
  .download-button {
    margin-left: 58px;
    width: calc(100% - 58px);
  }
  .result-grid {
    grid-template-columns: 1fr;
  }
  .footer-inner {
    flex-direction: column;
  }
}
@media (prefers-reduced-motion: reduce) {
  .loading-spinner {
    animation: none;
  }
}
</style>

<style>
@page {
  margin: 12mm 15mm;
}
@media print {
  .share-page {
    min-height: 0;
    background: #fff !important;
    color: #153d4a !important;
    print-color-adjust: exact;
    -webkit-print-color-adjust: exact;
  }
  .share-page .no-print {
    display: none !important;
  }
  .share-page.has-print-document .main-content {
    display: none;
  }
  .share-page .print-document {
    display: table;
    width: 100%;
    table-layout: fixed;
    border-collapse: collapse;
    font-size: 11px;
    line-height: 1.4;
  }
  .share-page .print-document thead {
    display: table-header-group;
  }
  .share-page .print-document tfoot {
    display: table-footer-group;
  }
  .share-page .print-document th,
  .share-page .print-document td {
    min-width: 0;
    padding: 0;
    text-align: left;
    vertical-align: top;
    overflow-wrap: anywhere;
  }
  .share-page .print-document tr {
    break-inside: avoid;
    page-break-inside: avoid;
  }
  .share-page .print-masthead {
    display: block;
    min-height: 15mm;
    margin-bottom: 4mm;
    padding-bottom: 3mm;
    border-bottom: 1px solid #9fc9c7;
  }
  .share-page .print-brand {
    color: #115278;
    font-size: 18px;
    font-weight: 800;
    letter-spacing: -0.04em;
  }
  .share-page .print-masthead-label {
    margin-left: 12px;
    color: #115278;
    font-size: 9px;
    font-weight: 800;
    letter-spacing: 0.12em;
  }
  .share-page .print-colophon {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
  }
  .share-page .print-colophon {
    min-height: 11mm;
    margin-top: 4mm;
    padding-top: 3mm;
    border-top: 1px solid #9fc9c7;
    color: #536e78;
    font-size: 9px;
    font-weight: 600;
  }
  .share-page .print-intro-row td {
    padding: 3mm 0 5mm;
  }
  .share-page .print-eyebrow {
    margin: 0 0 4px;
    color: #126b67;
    font-size: 9px;
    font-weight: 800;
    letter-spacing: 0.12em;
  }
  .share-page .print-intro-row h1 {
    margin: 0 0 5px;
    font-size: 23px;
    line-height: 1.2;
  }
  .share-page .print-intro-row p:last-child,
  .share-page .print-section-row p,
  .share-page .print-results-heading p {
    margin: 0;
    color: #536e78;
  }
  .share-page .print-section-row td {
    padding: 5mm 0 2mm;
    border-top: 1px solid #d6e5e5;
  }
  .share-page .print-section-row h2 {
    margin: 0 0 3px;
    font-size: 16px;
  }
  .share-page .print-data-row td {
    padding: 5px 0;
    border-bottom: 1px solid #e1eaea;
  }
  .share-page .print-trend-entry {
    display: flex;
    flex-wrap: wrap;
    gap: 3px 12px;
  }
  .share-page .print-trend-entry > :first-child {
    flex-basis: 100%;
  }
  .share-page .print-report-heading td {
    padding: 6mm 0 2mm;
    border-top: 1px solid #9fc9c7;
  }
  .share-page .print-report-heading span {
    color: #536e78;
    font-size: 9px;
    font-weight: 800;
    text-transform: uppercase;
  }
  .share-page .print-report-heading h3 {
    margin: 3px 0 0;
    font-size: 14px;
  }
  .share-page .print-summary-row td,
  .share-page .print-disclaimer-row td {
    padding: 3px 0;
  }
  .share-page .print-summary {
    margin: 0;
    white-space: pre-wrap;
  }
  .share-page .print-results-heading td {
    padding: 4mm 0 2mm;
  }
  .share-page .print-results-heading h4 {
    margin: 0 0 3px;
    font-size: 13px;
  }
  .share-page .print-result-group-row td {
    padding: 5px 0;
  }
  .share-page .print-result-group-row .result-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 10px;
  }
  .share-page .print-result-group-row .result-card {
    break-inside: avoid;
    page-break-inside: avoid;
    overflow-wrap: anywhere;
  }
  .share-page .print-result-group-row .result-reading,
  .share-page .print-result-group-row .result-range {
    overflow-wrap: anywhere;
  }
}
</style>
