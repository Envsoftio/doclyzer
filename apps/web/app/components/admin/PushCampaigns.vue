<script setup lang="ts">
import { nextTick, ref } from "vue";
const { adminFetch } = useAdminApi();
interface Campaign {
  deep_link: string | null;
  image_url: string | null;
  audience_filter: {
    audience: string;
    userId: string | null;
    platform: string;
  };
  id: string;
  name: string;
  title: string;
  body: string;
  status: string;
  target_count: number;
  sent_count: number;
  failed_count: number;
  skipped_count: number;
  is_test: boolean;
  scheduled_at: string | null;
  started_at: string | null;
}
interface Preview {
  devices: number;
  users: number;
  title: string;
  body: string;
  deepLink: string;
  imageUrl: string | null;
}
interface Analytics {
  devices: number;
  users: number;
  accepted: number;
  failed: number;
  skipped: number;
  received: number;
  opens: number;
  actions: number;
  openRate: number;
  actionRate: number;
  definitions: string;
  platforms: { platform: string; status: string; count: number }[];
  failures: { failure_code: string; count: number }[];
  events: { event_type: string; created_at: string }[];
}
interface AccountOption {
  id: string;
  email: string;
  displayName: string | null;
}
const rows = ref<Campaign[]>([]),
  selected = ref<Campaign | null>(null);
const preview = ref<Preview | null>(null),
  analytics = ref<Analytics | null>(null);
const form = ref({
  name: "",
  title: "",
  body: "",
  deepLink: "/notifications",
  imageUrl: "",
  audience: "all",
  userId: "",
  platform: "all",
});
const editing = ref("");
const copiedFrom = ref("");
const composerForm = ref<HTMLFormElement | null>(null);
const titleInput = ref<HTMLInputElement | null>(null);
const deleting = ref<Campaign | null>(null);
const accountSearch = ref("");
const accountOptions = ref<AccountOption[]>([]);
const selectedAccount = ref<AccountOption | null>(null);
const accountPickerOpen = ref(false);
const accountSearchLoading = ref(false);
const accountSearchError = ref("");
const activeAccountIndex = ref(-1);
let accountSearchTimer: ReturnType<typeof setTimeout> | undefined;
let accountRequestVersion = 0;
const key = ref(""),
  composerSchedule = ref(""),
  error = ref(""),
  message = ref(""),
  busy = ref(false);
async function request<T>(
  path: string,
  body?: object,
  method: "POST" | "PATCH" | "DELETE" = "POST",
) {
  const options = body ? { method, body } : method === "POST" ? {} : { method };
  const res = await adminFetch<{ data: T }>(
    `/admin/notifications/campaigns${path}`,
    options,
  );
  return res.data;
}
function audienceLabel(campaign: Campaign): string {
  const audience =
    campaign.audience_filter.audience === "single"
      ? "Specific account"
      : "All opted-in accounts";
  const platform =
    campaign.audience_filter.platform === "all"
      ? "All platforms"
      : campaign.audience_filter.platform;
  return `${audience} · ${platform}`;
}
function statusClass(status: string): string {
  if (["failed", "partially_failed"].includes(status))
    return "status-pill--danger";
  if (["queued", "sending"].includes(status)) return "status-pill--warm";
  if (status === "completed") return "status-pill--success";
  if (status === "cancelled") return "status-pill--muted";
  return "";
}
function canDelete(campaign: Campaign): boolean {
  return !["queued", "sending"].includes(campaign.status);
}
function deliveryLabel(campaign: Campaign): string {
  const sent = Number(campaign.sent_count ?? 0);
  const target = Number(campaign.target_count ?? 0);
  return target ? `${sent} / ${target}` : "—";
}
function resetComposer() {
  editing.value = "";
  copiedFrom.value = "";
  key.value = "";
  composerSchedule.value = "";
  form.value = {
    name: "",
    title: "",
    body: "",
    deepLink: "/notifications",
    imageUrl: "",
    audience: "all",
    userId: "",
    platform: "all",
  };
  selectedAccount.value = null;
  accountSearch.value = "";
}
function accountLabel(account: AccountOption): string {
  return account.displayName?.trim() || account.email;
}
async function loadAccounts(query = accountSearch.value, open = true) {
  const version = ++accountRequestVersion;
  accountSearchLoading.value = true;
  accountSearchError.value = "";
  try {
    const params = new URLSearchParams({
      page: "1",
      limit: "10",
      sortBy: "email",
      sortDir: "ASC",
    });
    if (query.trim()) params.set("search", query.trim());
    const response = await adminFetch<{
      data: { users: AccountOption[] };
    }>(`/admin/analytics/users?${params}`);
    if (version !== accountRequestVersion) return;
    accountOptions.value = response.data.users;
    activeAccountIndex.value = accountOptions.value.findIndex(
      (account) => account.id === form.value.userId,
    );
    if (open) accountPickerOpen.value = true;
  } catch (cause) {
    if (version !== accountRequestVersion) return;
    accountOptions.value = [];
    accountSearchError.value =
      cause instanceof Error ? cause.message : "Could not search accounts.";
    if (open) accountPickerOpen.value = true;
  } finally {
    if (version === accountRequestVersion) accountSearchLoading.value = false;
  }
}
function scheduleAccountSearch() {
  if (
    selectedAccount.value &&
    accountSearch.value !== accountLabel(selectedAccount.value)
  ) {
    selectedAccount.value = null;
    form.value.userId = "";
  }
  if (accountSearchTimer) clearTimeout(accountSearchTimer);
  accountPickerOpen.value = true;
  activeAccountIndex.value = -1;
  accountSearchTimer = setTimeout(() => void loadAccounts(), 250);
}
function selectAccount(account: AccountOption) {
  selectedAccount.value = account;
  form.value.userId = account.id;
  accountSearch.value = accountLabel(account);
  accountPickerOpen.value = false;
  activeAccountIndex.value = -1;
}
async function resolveAccount(accountId: string) {
  if (!accountId) return;
  await loadAccounts(accountId, false);
  const match = accountOptions.value.find(
    (account) => account.id === accountId,
  );
  if (match) selectAccount(match);
}
function accountPickerKeydown(event: KeyboardEvent) {
  if (event.key === "Escape") {
    accountPickerOpen.value = false;
    return;
  }
  if (!["ArrowDown", "ArrowUp", "Enter"].includes(event.key)) return;
  if (!accountPickerOpen.value) {
    accountPickerOpen.value = true;
    return;
  }
  if (event.key === "Enter") {
    const account = accountOptions.value[activeAccountIndex.value];
    if (account) {
      event.preventDefault();
      selectAccount(account);
    }
    return;
  }
  event.preventDefault();
  const direction = event.key === "ArrowDown" ? 1 : -1;
  const last = accountOptions.value.length - 1;
  if (last < 0) return;
  if (activeAccountIndex.value < 0) {
    activeAccountIndex.value = direction > 0 ? 0 : last;
    return;
  }
  activeAccountIndex.value =
    (activeAccountIndex.value + direction + accountOptions.value.length) %
    accountOptions.value.length;
}
function closeAccountPicker(event: FocusEvent) {
  const container = event.currentTarget as HTMLElement;
  if (
    event.relatedTarget instanceof Node &&
    container.contains(event.relatedTarget)
  )
    return;
  accountPickerOpen.value = false;
}
async function refresh() {
  rows.value = await request<Campaign[]>("");
}
async function action(fn: () => Promise<void>) {
  if (busy.value) return;
  busy.value = true;
  error.value = "";
  message.value = "";
  try {
    await fn();
  } catch (e) {
    error.value = e instanceof Error ? e.message : String(e);
  } finally {
    busy.value = false;
  }
}
async function saveCampaign(): Promise<string> {
  if (form.value.audience === "single" && !form.value.userId)
    throw new Error("Select an account from the search results.");
  if (!key.value) key.value = crypto.randomUUID();
  const { id } = await request<{ id: string }>(
    editing.value ? `/${editing.value}` : "",
    {
      name: form.value.name.trim() || form.value.title.trim(),
      title: form.value.title,
      body: form.value.body,
      deepLink: form.value.deepLink,
      audience: form.value.audience,
      platform: form.value.platform,
      idempotencyKey: key.value,
      ...(form.value.imageUrl ? { imageUrl: form.value.imageUrl } : {}),
      ...(form.value.audience === "single" ? { userId: form.value.userId } : {}),
    },
    editing.value ? "PATCH" : "POST",
  );
  editing.value = id;
  copiedFrom.value = "";
  key.value = "";
  return id;
}
async function create() {
  if (!composerForm.value?.reportValidity()) return;
  await action(async () => {
    const id = await saveCampaign();
    await refresh();
    await inspect(rows.value.find((c) => c.id === id)!);
    message.value = "Draft saved. You can send it from the campaign details.";
  });
}
async function sendFromComposer() {
  if (!composerForm.value?.reportValidity()) return;
  await action(async () => {
    const id = await saveCampaign();
    await request(`/${id}/schedule`, {
      ...(composerSchedule.value
        ? { scheduledAt: new Date(composerSchedule.value).toISOString() }
        : {}),
    });
    const scheduled = Boolean(composerSchedule.value);
    resetComposer();
    await refresh();
    await inspect(rows.value.find((c) => c.id === id)!);
    message.value = preview.value?.devices === 0
      ? "Notification queued, but no eligible devices currently match this audience."
      : scheduled
        ? "Notification scheduled for delivery to eligible devices."
        : "Notification queued for delivery to eligible devices.";
  });
}
function editDraft(c: Campaign) {
  key.value = "";
  editing.value = c.id;
  copiedFrom.value = "";
  form.value = {
    name: c.name,
    title: c.title,
    body: c.body,
    deepLink: c.deep_link ?? "/notifications",
    imageUrl: c.image_url ?? "",
    audience: c.audience_filter.audience,
    userId: c.audience_filter.userId ?? "",
    platform: c.audience_filter.platform,
  };
  selectedAccount.value = null;
  accountSearch.value = c.audience_filter.userId ?? "";
  void resolveAccount(form.value.userId);
}
async function copyForResend(c: Campaign) {
  ++inspectionVersion;
  selected.value = null;
  preview.value = null;
  analytics.value = null;
  editing.value = "";
  copiedFrom.value = c.name;
  key.value = "";
  composerSchedule.value = "";
  error.value = "";
  message.value =
    "Review the copied notification, then create a new campaign to send it again.";
  form.value = {
    name: c.name,
    title: c.title,
    body: c.body,
    deepLink: c.deep_link ?? "/notifications",
    imageUrl: c.image_url ?? "",
    audience: c.audience_filter.audience,
    userId: c.audience_filter.userId ?? "",
    platform: c.audience_filter.platform,
  };
  selectedAccount.value = null;
  accountSearch.value = form.value.userId;
  if (form.value.userId) void resolveAccount(form.value.userId);
  await nextTick();
  titleInput.value?.focus();
  titleInput.value?.scrollIntoView({ block: "center", behavior: "smooth" });
}
let inspectionVersion = 0;
async function inspect(c: Campaign) {
  const version = ++inspectionVersion;
  selected.value = c;
  preview.value = null;
  analytics.value = null;
  const [p, a] = await Promise.all([
    request<Preview>(`/${c.id}/preview`),
    request<Analytics>(`/${c.id}/analytics`),
  ]);
  if (version !== inspectionVersion) return;
  preview.value = p;
  analytics.value = a;
}
async function testSavedDraft() {
  if (!selected.value || selected.value.status !== "draft") return;
  await action(async () => {
    const id = selected.value!.id;
    await request(`/${id}/test`, {});
    message.value =
      "Test queued to your eligible devices. Tests appear separately in history.";
    await refresh();
    await inspect(rows.value.find((c) => c.id === id)!);
  });
}
async function cancel(c: Campaign) {
  await action(async () => {
    await request(`/${c.id}/cancel`, {});
    await refresh();
    if (selected.value?.id === c.id)
      await inspect(rows.value.find((r) => r.id === c.id)!);
    message.value = "Campaign cancelled.";
  });
}
async function deleteCampaign() {
  if (!deleting.value) return;
  const campaign = deleting.value;
  await action(async () => {
    await request(`/${campaign.id}`, undefined, "DELETE");
    if (selected.value?.id === campaign.id) {
      selected.value = null;
      preview.value = null;
      analytics.value = null;
    }
    if (editing.value === campaign.id) resetComposer();
    deleting.value = null;
    await refresh();
    if (rows.value[0]) await inspect(rows.value[0]);
    message.value = "Campaign deleted. Delivery audit records were retained.";
  });
}
onMounted(() =>
  action(async () => {
    await refresh();
    if (rows.value[0]) await inspect(rows.value[0]);
  }),
);
onUnmounted(() => {
  if (accountSearchTimer) clearTimeout(accountSearchTimer);
});
</script>
<template>
  <section class="campaigns admin-ops">
    <header class="campaign-header">
      <div>
        <h2>Marketing campaigns</h2>
        <p>
          Send a message to accounts that enabled marketing notifications.
        </p>
      </div>
      <button
        class="admin-ops__button"
        type="button"
        :disabled="busy"
        @click="action(refresh)"
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
    <p v-if="message" class="admin-ops__message" role="status">
      {{ message }}
    </p>

    <div class="campaign-workspace">
      <form
        ref="composerForm"
        class="campaign-card composer-panel"
        @submit.prevent="sendFromComposer"
      >
        <div class="section-heading">
          <div>
            <p class="section-kicker">
              {{ editing ? "Draft" : copiedFrom ? "Send again" : "New notification" }}
            </p>
            <h3>
              {{
                editing
                  ? "Send saved draft"
                  : copiedFrom
                    ? "Send this notification again"
                    : "Send a push notification"
              }}
            </h3>
          </div>
          <button
            v-if="editing || copiedFrom"
            class="admin-ops__text-button"
            type="button"
            @click="resetComposer"
          >
            Start new
          </button>
        </div>
        <p class="section-description">
          Write the message, choose who receives it, and send.
        </p>
        <label class="admin-ops__field"
          >Notification title
          <input
            ref="titleInput"
            v-model="form.title"
            class="admin-ops__input"
            required
            minlength="3"
            maxlength="120"
            placeholder="What recipients will see"
          />
        </label>
        <label class="admin-ops__field"
          >Message
          <textarea
            v-model="form.body"
            class="admin-ops__textarea"
            required
            minlength="3"
            maxlength="280"
            placeholder="Write a short, useful message"
          ></textarea>
          <small class="field-meta">{{ form.body.length }}/280</small>
        </label>

        <label class="admin-ops__field"
          >Send to
          <select v-model="form.audience" class="admin-ops__select">
            <option value="all">All opted-in accounts</option>
            <option value="single">One account</option>
          </select>
        </label>

        <div
          v-if="form.audience === 'single'"
          class="account-picker admin-ops__field"
          @focusout="closeAccountPicker"
        >
          <label for="campaign-account">Account</label>
          <input
            id="campaign-account"
            v-model="accountSearch"
            class="admin-ops__input"
            type="search"
            role="combobox"
            autocomplete="off"
            spellcheck="false"
            placeholder="Search name, email, or UUID"
            :aria-expanded="accountPickerOpen"
            aria-controls="campaign-account-results"
            :aria-activedescendant="
              activeAccountIndex >= 0
                ? `campaign-account-${activeAccountIndex}`
                : undefined
            "
            :aria-invalid="form.audience === 'single' && !form.userId"
            @focus="
              accountPickerOpen = true;
              if (!accountOptions.length) loadAccounts();
            "
            @input="scheduleAccountSearch"
            @keydown="accountPickerKeydown"
          />
          <div
            v-if="accountPickerOpen"
            id="campaign-account-results"
            class="account-results"
            role="listbox"
          >
            <p v-if="accountSearchLoading" class="account-state">
              Searching accounts…
            </p>
            <p
              v-else-if="accountSearchError"
              class="account-state account-state--error"
            >
              {{ accountSearchError }}
            </p>
            <p v-else-if="!accountOptions.length" class="account-state">
              No matching accounts.
            </p>
            <template v-else>
              <button
                v-for="(account, index) in accountOptions"
                :id="`campaign-account-${index}`"
                :key="account.id"
                type="button"
                role="option"
                class="account-option"
                :class="{
                  'account-option--active': index === activeAccountIndex,
                }"
                :aria-selected="account.id === form.userId"
                @mouseenter="activeAccountIndex = index"
                @click="selectAccount(account)"
              >
                <strong>{{ accountLabel(account) }}</strong>
                <span v-if="account.displayName">{{ account.email }}</span>
                <code>{{ account.id }}</code>
              </button>
            </template>
          </div>
          <small v-if="selectedAccount" class="selected-account">
            Selected UUID: <code>{{ selectedAccount.id }}</code>
          </small>
          <small v-else class="field-meta">
            Choose an account from the search results.
          </small>
        </div>

        <details class="composer-options">
          <summary>More options</summary>
          <label class="admin-ops__field"
            >Campaign name (optional)
            <input
              v-model="form.name"
              class="admin-ops__input"
              minlength="3"
              maxlength="120"
              placeholder="Uses the notification title when empty"
            />
          </label>
          <div class="form-row">
            <label class="admin-ops__field"
              >Destination
              <select v-model="form.deepLink" class="admin-ops__select">
                <option value="/notifications">Notifications</option>
                <option value="/reports">Reports</option>
                <option value="/account">Account</option>
              </select>
            </label>
            <label class="admin-ops__field"
              >Platform
              <select v-model="form.platform" class="admin-ops__select">
                <option value="all">All platforms</option>
                <option value="android">Android</option>
                <option value="ios">iOS</option>
                <option value="web">Web</option>
                <option value="mobile_web">Mobile web</option>
              </select>
            </label>
          </div>

          <label class="admin-ops__field"
            >Optional image URL
            <input
              v-model="form.imageUrl"
              class="admin-ops__input"
              type="url"
              maxlength="2048"
              placeholder="https://example.com/image.png"
            />
          </label>
          <label class="admin-ops__field"
            >Schedule for later (optional)
            <input
              v-model="composerSchedule"
              class="admin-ops__input"
              type="datetime-local"
            />
          </label>
        </details>

        <div class="composer-actions">
          <button
            class="admin-ops__button admin-ops__button--primary"
            :disabled="busy"
          >
            {{
              busy
                ? "Working…"
                : composerSchedule
                  ? "Schedule notification"
                  : "Send now"
            }}
          </button>
          <button
            class="admin-ops__button"
            type="button"
            :disabled="busy"
            @click="create"
          >
            Save draft
          </button>
        </div>
        <p class="send-note">
          Delivery starts shortly. Only accounts and devices that allow marketing
          notifications receive it.
        </p>
      </form>

      <section v-if="selected" class="campaign-card detail-panel" aria-live="polite">
        <template v-if="selected">
          <div class="selected-header">
            <div>
              <div class="selected-title-row">
                <h3>{{ selected.name }}</h3>
                <span class="status-pill" :class="statusClass(selected.status)">
                  {{
                    selected.is_test
                      ? "Test"
                      : selected.status.replaceAll("_", " ")
                  }}
                </span>
              </div>
              <p>{{ audienceLabel(selected) }}</p>
            </div>
            <div v-if="selected.status === 'draft'" class="send-actions">
              <button
                class="admin-ops__button"
                type="button"
                :disabled="busy"
                @click="editDraft(selected)"
              >
                Edit draft
              </button>
              <button
                class="admin-ops__button"
                type="button"
                :disabled="busy"
                @click="testSavedDraft"
              >
                Test saved draft
              </button>
            </div>
          </div>

          <div v-if="preview" class="notification-preview">
            <p class="preview-label">Notification preview</p>
            <div class="notification-card">
              <strong>{{ preview.title }}</strong>
              <p>{{ preview.body }}</p>
              <span>Opens {{ preview.deepLink }}</span>
            </div>
          </div>
          <div v-else class="preview-loading" role="status">
            Loading campaign preview…
          </div>

          <div v-if="preview" class="audience-section">
            <h4>Audience estimate</h4>
            <div class="audience-metrics">
              <div>
                <span>Opted-in accounts</span>
                <strong>{{ preview.users }}</strong>
              </div>
              <div>
                <span>Eligible devices</span>
                <strong>{{ preview.devices }}</strong>
              </div>
            </div>
            <p v-if="preview.devices === 0" class="eligibility-note">
              No eligible devices currently match this audience. A device must
              be active, have OS notification permission, and have marketing
              consent at both account and device level.
            </p>
            <p v-else class="eligibility-note eligibility-note--ready">
              Eligibility is checked again immediately before delivery.
            </p>
          </div>

          <div v-if="analytics" class="analytics-panel">
            <div class="section-heading">
              <div>
                <p class="section-kicker">Delivery</p>
                <h4>Campaign analytics</h4>
              </div>
            </div>
            <div class="analytics-metrics">
              <div>
                <span>Targeted</span><strong>{{ analytics.devices }}</strong>
              </div>
              <div>
                <span>Accepted</span><strong>{{ analytics.accepted }}</strong>
              </div>
              <div>
                <span>Failed</span><strong>{{ analytics.failed }}</strong>
              </div>
              <div>
                <span>Opened</span><strong>{{ analytics.opens }}</strong>
              </div>
              <div>
                <span>Open rate</span>
                <strong>{{ (analytics.openRate * 100).toFixed(1) }}%</strong>
              </div>
            </div>
            <p class="analytics-definition">
              {{ analytics.definitions }} FCM acceptance does not confirm
              delivery or viewing.
            </p>
            <div
              v-if="analytics.platforms.length || analytics.failures.length"
              class="analytics-breakdown"
            >
              <span
                v-for="item in analytics.platforms"
                :key="item.platform + item.status"
              >
                {{ item.platform }} · {{ item.status }}: {{ item.count }}
              </span>
              <span
                v-for="item in analytics.failures"
                :key="item.failure_code"
                class="analytics-failure"
              >
                {{ item.failure_code }}: {{ item.count }}
              </span>
            </div>
            <details v-if="analytics.events.length" class="audit-details">
              <summary>Audit history</summary>
              <ol>
                <li v-for="(event, index) in analytics.events" :key="index">
                  <time>{{ new Date(event.created_at).toLocaleString() }}</time>
                  <span>{{ event.event_type.replaceAll("_", " ") }}</span>
                </li>
              </ol>
            </details>
          </div>
        </template>

        <div v-else class="campaign-empty">
          <p class="section-kicker">Campaign details</p>
          <h3>Select a campaign</h3>
          <p>
            Choose a row from campaign history to review its audience, delivery
            state, and audit history.
          </p>
        </div>
      </section>
    </div>

    <section class="campaign-card history-panel">
      <div class="history-header">
        <div>
          <h3>Campaign history</h3>
          <p>
            Drafts, tests, scheduled sends, and completed campaigns. Delivery
            audit records remain after campaign deletion.
          </p>
        </div>
        <span class="history-count">{{ rows.length }} shown</span>
      </div>

      <p v-if="!rows.length" class="admin-ops__empty">
        No campaigns yet. Create a draft to get started.
      </p>
      <div v-else class="admin-ops__table-wrap">
        <table class="admin-ops__table campaign-table">
          <thead>
            <tr>
              <th>Campaign</th>
              <th>Audience</th>
              <th>Status</th>
              <th>Schedule</th>
              <th title="FCM acceptance does not confirm device delivery">FCM accepted</th>
              <th><span class="sr-only">Actions</span></th>
            </tr>
          </thead>
          <tbody>
            <template v-for="campaign in rows" :key="campaign.id">
              <tr
                :class="{
                  'campaign-row--selected': selected?.id === campaign.id,
                }"
              >
                <td>
                  <button
                    class="campaign-name"
                    type="button"
                    @click="action(() => inspect(campaign))"
                  >
                    <strong>{{ campaign.name }}</strong>
                    <span>{{ campaign.title }}</span>
                  </button>
                </td>
                <td>{{ audienceLabel(campaign) }}</td>
                <td>
                  <span
                    class="status-pill"
                    :class="statusClass(campaign.status)"
                  >
                    {{
                      campaign.is_test
                        ? "Test"
                        : campaign.status.replaceAll("_", " ")
                    }}
                  </span>
                </td>
                <td>
                  {{
                    campaign.scheduled_at
                      ? new Date(campaign.scheduled_at).toLocaleString()
                      : "Not scheduled"
                  }}
                </td>
                <td>{{ deliveryLabel(campaign) }}</td>
                <td>
                  <div class="row-actions">
                    <button
                      class="admin-ops__text-button"
                      type="button"
                      @click="action(() => inspect(campaign))"
                    >
                      View
                    </button>
                    <button
                      v-if="campaign.status === 'draft'"
                      class="admin-ops__text-button"
                      type="button"
                      @click="editDraft(campaign)"
                    >
                      Edit
                    </button>
                    <button
                      v-if="
                        !campaign.is_test &&
                        !['draft', 'queued', 'sending'].includes(campaign.status)
                      "
                      class="admin-ops__text-button"
                      type="button"
                      :disabled="busy"
                      @click="copyForResend(campaign)"
                    >
                      Send again
                    </button>
                    <button
                      v-if="
                        ['draft', 'queued'].includes(campaign.status) &&
                        !campaign.started_at
                      "
                      class="admin-ops__text-button"
                      type="button"
                      :disabled="busy"
                      @click="cancel(campaign)"
                    >
                      Cancel
                    </button>
                    <button
                      v-if="canDelete(campaign)"
                      class="admin-ops__text-button delete-link"
                      type="button"
                      :disabled="busy"
                      @click="deleting = campaign"
                    >
                      Delete
                    </button>
                  </div>
                </td>
              </tr>
              <tr
                v-if="deleting?.id === campaign.id"
                class="delete-confirmation-row"
              >
                <td colspan="6">
                  <div class="delete-confirmation" role="alert">
                    <div>
                      <strong>Delete “{{ campaign.name }}”?</strong>
                      <p>
                        Campaign details, recipients, and campaign analytics
                        will be removed. Delivery audit records are retained.
                      </p>
                    </div>
                    <div class="delete-actions">
                      <button
                        class="admin-ops__button"
                        type="button"
                        :disabled="busy"
                        @click="deleting = null"
                      >
                        Keep campaign
                      </button>
                      <button
                        class="admin-ops__button admin-ops__button--danger"
                        type="button"
                        :disabled="busy"
                        @click="deleteCampaign"
                      >
                        {{ busy ? "Deleting…" : "Delete campaign" }}
                      </button>
                    </div>
                  </div>
                </td>
              </tr>
            </template>
          </tbody>
        </table>
      </div>
    </section>
  </section>
</template>

<style scoped>
.campaigns {
  max-width: 1280px;
  margin: 0 auto 28px;
  color: var(--brand-ink);
}
.campaigns * {
  box-sizing: border-box;
}
.campaign-header,
.section-heading,
.selected-header,
.history-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 18px;
}
.campaign-header {
  margin-bottom: 20px;
}
.campaign-header h2,
.campaign-card h3,
.campaign-card h4 {
  margin: 0;
  font-family: var(--font-display);
  letter-spacing: -0.025em;
}
.campaign-header h2 {
  font-size: clamp(24px, 2vw, 30px);
}
.campaign-header p,
.history-header p,
.section-description,
.selected-header p {
  color: var(--brand-muted);
  line-height: 1.5;
}
.campaign-header p {
  max-width: 68ch;
  margin: 6px 0 0;
  font-size: 14px;
}
.campaign-workspace {
  display: block;
}
.campaign-card {
  min-width: 0;
  border: 1px solid rgba(13, 27, 42, 0.1);
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.94);
  box-shadow: 0 12px 28px rgba(13, 27, 42, 0.06);
}
.composer-panel,
.detail-panel,
.history-panel {
  padding: 22px;
}
.composer-panel {
  max-width: 760px;
}
.detail-panel {
  margin-top: 18px;
}
.composer-panel h3,
.detail-panel h3,
.history-panel h3 {
  font-size: 19px;
}
.section-kicker {
  margin: 0 0 5px;
  color: var(--brand-teal);
  font-size: 11px;
  font-weight: 800;
  letter-spacing: 0.1em;
  text-transform: uppercase;
}
.section-description {
  margin: 7px 0 18px;
  font-size: 13px;
}
.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}
.admin-ops__field {
  margin: 13px 0;
}
.field-meta,
.selected-account {
  color: var(--brand-muted);
  font-size: 12px;
  font-weight: 500;
}
.field-meta {
  text-align: right;
}
.selected-account {
  overflow-wrap: anywhere;
}
.composer-actions,
.send-actions,
.row-actions,
.delete-actions {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 9px;
}
.composer-actions {
  margin-top: 20px;
}
.composer-options {
  margin-top: 14px;
  padding-top: 12px;
  border-top: 1px solid var(--brand-border);
}
.composer-options summary {
  color: var(--brand-blue);
  font-size: 13px;
  font-weight: 700;
  cursor: pointer;
}
.send-note {
  margin: 10px 0 0;
  color: var(--brand-muted);
  font-size: 12px;
  line-height: 1.5;
}
.account-picker {
  position: relative;
}
.account-picker > label {
  font-weight: 700;
}
.account-results {
  position: absolute;
  z-index: 20;
  top: 70px;
  right: 0;
  left: 0;
  max-height: 280px;
  overflow-y: auto;
  padding: 6px;
  border: 1px solid var(--brand-border);
  border-radius: 10px;
  background: #fff;
  box-shadow: 0 14px 30px rgba(13, 27, 42, 0.14);
}
.account-option {
  display: grid;
  width: 100%;
  gap: 2px;
  padding: 9px 10px;
  border: 0;
  border-radius: 7px;
  color: var(--brand-ink);
  text-align: left;
  background: transparent;
  cursor: pointer;
}
.account-option:hover,
.account-option--active {
  background: var(--brand-canvas);
}
.account-option span,
.account-option code,
.account-state {
  color: var(--brand-muted);
  font-size: 12px;
  overflow-wrap: anywhere;
}
.account-state {
  margin: 0;
  padding: 10px;
}
.account-state--error {
  color: #a52626;
}
.selected-title-row {
  display: flex;
  align-items: center;
  gap: 9px;
  flex-wrap: wrap;
}
.selected-header p {
  margin: 6px 0 0;
  font-size: 13px;
  text-transform: capitalize;
}
.status-pill {
  display: inline-flex;
  align-items: center;
  min-height: 24px;
  padding: 3px 9px;
  border-radius: 20px;
  background: var(--brand-mint);
  color: var(--brand-teal);
  font-size: 12px;
  font-weight: 800;
  text-transform: capitalize;
  white-space: nowrap;
}
.status-pill--success {
  background: #e6f7ed;
  color: #19643b;
}
.status-pill--warm {
  background: #fff2dd;
  color: #8a5715;
}
.status-pill--danger {
  background: #ffe9e6;
  color: #a52626;
}
.status-pill--muted {
  background: #edf1f4;
  color: #566575;
}
.notification-preview {
  margin-top: 20px;
  padding: 14px;
  border: 1px solid var(--brand-border);
  border-radius: 13px;
  background: var(--brand-canvas);
}
.preview-label {
  margin: 0 0 10px;
  color: var(--brand-muted);
  font-size: 12px;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: 0.06em;
}
.notification-card {
  max-width: 520px;
  margin: 0 auto;
  padding: 16px;
  border: 1px solid rgba(13, 27, 42, 0.12);
  border-radius: 11px;
  background: #fff;
  box-shadow: 0 8px 18px rgba(13, 27, 42, 0.06);
}
.notification-card strong {
  font-size: 15px;
}
.notification-card p {
  margin: 6px 0 13px;
  color: var(--brand-ink);
  font-size: 14px;
  line-height: 1.45;
}
.notification-card span {
  color: var(--brand-blue);
  font-size: 13px;
  font-weight: 700;
}
.preview-loading,
.campaign-empty {
  padding: 42px 18px;
  color: var(--brand-muted);
  text-align: center;
}
.campaign-empty h3 {
  margin-top: 4px;
  color: var(--brand-ink);
}
.campaign-empty p:last-child {
  max-width: 48ch;
  margin: 8px auto 0;
  line-height: 1.55;
}
.audience-section,
.analytics-panel {
  margin-top: 22px;
}
.audience-section h4,
.analytics-panel h4 {
  font-size: 16px;
}
.audience-metrics,
.analytics-metrics {
  display: grid;
  gap: 10px;
  margin-top: 10px;
}
.audience-metrics {
  grid-template-columns: 1fr 1fr;
}
.audience-metrics > div,
.analytics-metrics > div {
  padding: 13px;
  border: 1px solid var(--brand-border);
  border-radius: 10px;
  background: #fff;
}
.audience-metrics span,
.analytics-metrics span {
  display: block;
  margin-bottom: 4px;
  color: var(--brand-muted);
  font-size: 12px;
}
.audience-metrics strong,
.analytics-metrics strong {
  color: var(--brand-ink);
  font: 800 21px var(--font-display);
  font-variant-numeric: tabular-nums;
}
.eligibility-note {
  margin: 10px 0 0;
  padding: 11px 12px;
  border: 1px solid #ead7b5;
  border-radius: 9px;
  background: #fff9ee;
  color: #72501d;
  font-size: 13px;
  line-height: 1.5;
}
.eligibility-note--ready {
  border-color: #b9dfcb;
  background: #effaf3;
  color: #16653b;
}
.analytics-panel {
  padding-top: 20px;
  border-top: 1px solid var(--brand-border);
}
.analytics-metrics {
  grid-template-columns: repeat(5, minmax(78px, 1fr));
}
.analytics-definition {
  margin: 12px 0 0;
  color: var(--brand-muted);
  font-size: 12px;
  line-height: 1.5;
}
.analytics-breakdown {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: 12px;
}
.analytics-breakdown span {
  padding: 4px 8px;
  border-radius: 20px;
  background: var(--brand-canvas);
  color: var(--brand-muted);
  font-size: 12px;
}
.analytics-breakdown .analytics-failure {
  background: #fff1ef;
  color: #a52626;
}
.audit-details {
  margin-top: 14px;
  font-size: 13px;
}
.audit-details summary {
  color: var(--brand-blue);
  font-weight: 700;
  cursor: pointer;
}
.audit-details ol {
  margin: 10px 0 0;
  padding-left: 20px;
}
.audit-details li {
  margin: 7px 0;
}
.audit-details time {
  display: inline-block;
  min-width: 165px;
  color: var(--brand-muted);
  font-variant-numeric: tabular-nums;
}
.history-panel {
  margin-top: 18px;
}
.history-header {
  align-items: end;
  margin-bottom: 16px;
}
.history-header p {
  max-width: 70ch;
  margin: 5px 0 0;
  font-size: 13px;
}
.history-count {
  color: var(--brand-muted);
  font-size: 13px;
  white-space: nowrap;
}
.campaign-table td {
  color: var(--brand-muted);
}
.campaign-table td:first-child {
  min-width: 210px;
}
.campaign-table td:nth-child(2) {
  min-width: 190px;
  text-transform: capitalize;
}
.campaign-name {
  display: grid;
  gap: 3px;
  padding: 0;
  border: 0;
  color: var(--brand-ink);
  text-align: left;
  background: transparent;
  cursor: pointer;
}
.campaign-name strong {
  font-size: 14px;
}
.campaign-name span {
  max-width: 34ch;
  overflow: hidden;
  color: var(--brand-muted);
  font-size: 12px;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.campaign-row--selected {
  background: #f2faf8;
}
.row-actions {
  flex-wrap: nowrap;
  justify-content: flex-end;
}
.row-actions .admin-ops__text-button {
  white-space: nowrap;
}
.delete-link {
  color: #a52626;
}
.delete-confirmation-row td {
  padding: 0 12px 13px;
  background: #fff8f7;
}
.delete-confirmation {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 18px;
  padding: 13px;
  border: 1px solid #efbeb9;
  border-radius: 10px;
}
.delete-confirmation strong {
  color: #8e211c;
}
.delete-confirmation p {
  margin: 4px 0 0;
  color: #7d4a46;
  font-size: 13px;
}
.delete-actions {
  flex-shrink: 0;
}
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
}
@media (max-width: 1050px) {
  .campaign-workspace {
    grid-template-columns: 1fr;
  }
  .analytics-metrics {
    grid-template-columns: repeat(3, 1fr);
  }
}
@media (max-width: 700px) {
  .campaign-header,
  .selected-header,
  .history-header,
  .delete-confirmation {
    align-items: stretch;
    flex-direction: column;
  }
  .form-row,
  .audience-metrics {
    grid-template-columns: 1fr;
  }
  .analytics-metrics {
    grid-template-columns: repeat(2, 1fr);
  }
  .composer-panel,
  .detail-panel,
  .history-panel {
    padding: 16px;
  }
  .delete-actions > button {
    flex: 1;
  }
}
@media (prefers-reduced-motion: reduce) {
  .campaign-card {
    scroll-behavior: auto;
  }
}
</style>
