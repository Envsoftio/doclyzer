<script setup lang="ts">
import { formatDisplayDate } from "../../../utils/formatDisplayDate";

definePageMeta({ layout: "admin" });
useSeoMeta({
  robots: "noindex, nofollow",
  title: "Service incidents — Doclyzer Admin",
});

type Surface = "mobile_app" | "web_share" | "web_landing" | "api";
interface Incident {
  id: string;
  severity: "major" | "critical";
  status: "active" | "monitoring" | "resolved";
  headline: string;
  message: string;
  whatsAffected: string;
  affectedSurfaces: Surface[];
  startedAt: string;
  updatedAt: string;
}
const surfaces: Array<{ value: Surface; label: string }> = [
  { value: "mobile_app", label: "Mobile app" },
  { value: "web_share", label: "Web sharing" },
  { value: "web_landing", label: "Website" },
  { value: "api", label: "API" },
];
const { adminFetch } = useAdminApi();
const current = ref<Incident | null>(null);
const activeIncidents = ref<Incident[]>([]);
const severity = ref<"major" | "critical">("major");
const status = ref<"active" | "monitoring">("active");
const headline = ref("");
const message = ref("");
const whatsAffected = ref("");
const affectedSurfaces = ref<Surface[]>(["mobile_app"]);
const loading = ref(true);
const saving = ref(false);
const resolving = ref(false);
const error = ref("");
const notice = ref("");

async function loadIncident() {
  loading.value = true;
  error.value = "";
  try {
    const response = await adminFetch<{ data: Incident[] }>("/admin/incidents");
    activeIncidents.value = response.data;
    current.value = response.data[0] ?? null;
    if (current.value) {
      severity.value = current.value.severity;
      status.value =
        current.value.status === "monitoring" ? "monitoring" : "active";
      headline.value = current.value.headline;
      message.value = current.value.message;
      whatsAffected.value = current.value.whatsAffected;
      affectedSurfaces.value = [...current.value.affectedSurfaces];
    }
  } catch (e: unknown) {
    error.value =
      e instanceof Error ? e.message : "Could not load incident status.";
  } finally {
    loading.value = false;
  }
}

async function publish() {
  error.value = "";
  notice.value = "";
  if (
    !headline.value.trim() ||
    !message.value.trim() ||
    !whatsAffected.value.trim() ||
    !affectedSurfaces.value.length
  ) {
    error.value =
      "Add a headline, message, affected service, and at least one surface.";
    return;
  }
  saving.value = true;
  try {
    const response = await adminFetch<{ data: Incident }>("/admin/incidents", {
      method: "POST",
      body: {
        ...(current.value ? { incidentId: current.value.id } : {}),
        severity: severity.value,
        status: status.value,
        headline: headline.value.trim(),
        message: message.value.trim(),
        whatsAffected: whatsAffected.value.trim(),
        affectedSurfaces: affectedSurfaces.value,
      },
    });
    await loadIncident();
    notice.value =
      "Incident status published. The selected surfaces will show this message.";
  } catch (e: unknown) {
    error.value =
      e instanceof Error ? e.message : "Could not publish the incident.";
  } finally {
    saving.value = false;
  }
}

async function resolveIncident(id: string) {
  error.value = "";
  notice.value = "";
  resolving.value = true;
  try {
    await adminFetch(`/admin/incidents/${encodeURIComponent(id)}/resolve`, {
      method: "PATCH",
      body: {},
    });
    await loadIncident();
    notice.value = "Incident resolved. Public status has been refreshed.";
  } catch (e: unknown) {
    error.value =
      e instanceof Error ? e.message : "Could not resolve the incident.";
  } finally {
    resolving.value = false;
  }
}

onMounted(loadIncident);
</script>

<template>
  <div class="admin-ops">
    <header class="admin-ops__header">
      <div>
        <p class="admin-ops__eyebrow">Operations / Status</p>
        <h1>Service incidents</h1>
        <p class="admin-ops__subtitle">
          Publish the incident banner shown on affected app and web surfaces.
        </p>
      </div>
      <button
        class="admin-ops__button"
        type="button"
        :disabled="loading"
        @click="loadIncident"
      >
        Refresh
      </button>
    </header>
    <p
      v-if="error"
      class="admin-ops__message admin-ops__message--error"
      role="alert"
    >
      {{ error }}
    </p>
    <p v-if="notice" class="admin-ops__message" role="status">{{ notice }}</p>
    <div class="admin-ops__grid">
      <section class="admin-ops__card">
        <h2>Current public status</h2>
        <p>
          Only the most recently updated active or monitoring incident is shown
          publicly.
        </p>
        <p v-if="loading">Loading status…</p>
        <div v-else-if="current" class="admin-ops__detail">
          <dl>
            <dt>Status</dt>
            <dd>
              <span
                class="admin-ops__badge"
                :class="
                  current.severity === 'critical'
                    ? 'admin-ops__badge--red'
                    : 'admin-ops__badge--warm'
                "
                >{{ current.status }} · {{ current.severity }}</span
              >
            </dd>
            <dt>Headline</dt>
            <dd>{{ current.headline }}</dd>
            <dt>Affected</dt>
            <dd>{{ current.whatsAffected }}</dd>
            <dt>Started</dt>
            <dd>{{ formatDisplayDate(current.startedAt, true) }}</dd>
            <dt>Last updated</dt>
            <dd>{{ formatDisplayDate(current.updatedAt, true) }}</dd>
          </dl>
        </div>
        <p v-else class="admin-ops__empty">No active public incident.</p>
        <div v-if="current" class="admin-ops__actions">
          <button
            class="admin-ops__button admin-ops__button--danger"
            type="button"
            :disabled="resolving || saving"
            @click="resolveIncident(current.id)"
          >
            {{ resolving ? "Resolving…" : "Resolve incident" }}
          </button>
        </div>
      </section>
      <section v-if="activeIncidents.length > 1" class="admin-ops__card">
        <h2>Other active incidents</h2>
        <p>
          Resolving the public incident can reveal an older one. Resolve stale
          incidents here too.
        </p>
        <div
          v-for="incident in activeIncidents.slice(1)"
          :key="incident.id"
          class="admin-ops__detail"
          style="margin-bottom: 10px"
        >
          <strong>{{ incident.headline }}</strong>
          <p class="admin-ops__muted">
            {{ incident.status }} ·
            {{ formatDisplayDate(incident.updatedAt, true) }}
          </p>
          <button
            class="admin-ops__button admin-ops__button--danger"
            type="button"
            :disabled="resolving"
            @click="resolveIncident(incident.id)"
          >
            Resolve
          </button>
        </div>
      </section>
      <section class="admin-ops__card">
        <h2>{{ current ? "Update incident" : "Publish incident" }}</h2>
        <p>
          Use concise language that helps users understand the issue and what is
          affected.
        </p>
        <form @submit.prevent="publish">
          <div class="admin-ops__row">
            <label class="admin-ops__field"
              >Severity<select v-model="severity" class="admin-ops__select">
                <option value="major">Major</option>
                <option value="critical">Critical</option>
              </select></label
            ><label class="admin-ops__field"
              >Status<select v-model="status" class="admin-ops__select">
                <option value="active">Active</option>
                <option value="monitoring">Monitoring</option>
              </select></label
            >
          </div>
          <label class="admin-ops__field"
            >Headline<input
              v-model="headline"
              class="admin-ops__input"
              maxlength="140"
              required
              placeholder="e.g. Report uploads are delayed" /></label
          ><label class="admin-ops__field"
            >Message<textarea
              v-model="message"
              class="admin-ops__textarea"
              maxlength="600"
              required
              placeholder="What users should know right now"
            ></textarea></label
          ><label class="admin-ops__field"
            >What is affected<input
              v-model="whatsAffected"
              class="admin-ops__input"
              maxlength="240"
              required
              placeholder="e.g. Report processing"
          /></label>
          <div class="admin-ops__field">
            <span>Show on</span>
            <div>
              <label
                v-for="surface in surfaces"
                :key="surface.value"
                class="admin-ops__check"
                ><input
                  v-model="affectedSurfaces"
                  type="checkbox"
                  :value="surface.value"
                />{{ surface.label }}</label
              >
            </div>
          </div>
          <div class="admin-ops__actions">
            <button
              class="admin-ops__button admin-ops__button--primary"
              type="submit"
              :disabled="saving || resolving || loading"
            >
              {{
                saving
                  ? "Publishing…"
                  : current
                    ? "Update public status"
                    : "Publish public status"
              }}
            </button>
          </div>
        </form>
      </section>
    </div>
  </div>
</template>
