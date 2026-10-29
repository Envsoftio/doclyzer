<script setup lang="ts">
import { ref } from "vue";
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
  schedule = ref(""),
  approval = ref(""),
  error = ref(""),
  message = ref(""),
  busy = ref(false);
async function request<T>(
  path: string,
  body?: object,
  method: "POST" | "PATCH" = "POST",
) {
  const res = await adminFetch<{ data: T }>(
    `/admin/notifications/campaigns${path}`,
    body ? { method, body } : {},
  );
  return res.data;
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
async function create() {
  await action(async () => {
    if (form.value.audience === "single" && !form.value.userId)
      throw new Error("Select an account from the search results.");
    if (!key.value) key.value = crypto.randomUUID();
    const { id } = await request<{ id: string }>(
      editing.value ? `/${editing.value}` : "",
      {
        name: form.value.name,
        title: form.value.title,
        body: form.value.body,
        deepLink: form.value.deepLink,
        audience: form.value.audience,
        platform: form.value.platform,
        idempotencyKey: key.value,
        ...(form.value.imageUrl ? { imageUrl: form.value.imageUrl } : {}),
        ...(form.value.audience === "single"
          ? { userId: form.value.userId }
          : {}),
      },
      editing.value ? "PATCH" : "POST",
    );
    editing.value = "";
    key.value = "";
    await refresh();
    await inspect(rows.value.find((c) => c.id === id)!);
    message.value =
      "Draft saved. Review the audience estimate before scheduling.";
  });
}
function editDraft(c: Campaign) {
  editing.value = c.id;
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
async function inspect(c: Campaign) {
  selected.value = c;
  preview.value = null;
  analytics.value = null;
  const [p, a] = await Promise.all([
    request<Preview>(`/${c.id}/preview`),
    request<Analytics>(`/${c.id}/analytics`),
  ]);
  preview.value = p;
  analytics.value = a;
}
async function send(test = false) {
  if (!selected.value) return;
  await action(async () => {
    const id = selected.value!.id;
    if (test) {
      await request(`/${id}/test`, {});
      message.value =
        "Test queued to your own eligible devices. Tests appear separately in history.";
    } else {
      await request(`/${id}/schedule`, {
        ...(schedule.value
          ? { scheduledAt: new Date(schedule.value).toISOString() }
          : {}),
        approvalToken: approval.value,
      });
      message.value =
        "Campaign queued. The dispatcher processes it at the scheduled time.";
    }
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
onMounted(() => action(refresh));
onUnmounted(() => {
  if (accountSearchTimer) clearTimeout(accountSearchTimer);
});
</script>
<template>
  <section class="campaigns">
    <h3>Marketing campaigns</h3>
    <p>
      Only devices with notification permission, device consent, and account
      marketing consent are eligible.
    </p>
    <form class="composer" @submit.prevent="create">
      <label
        >Campaign name<input
          v-model="form.name"
          required
          minlength="3"
          maxlength="120"
      /></label>
      <label
        >Title<input
          v-model="form.title"
          required
          minlength="3"
          maxlength="120"
      /></label>
      <label class="wide"
        >Message<textarea
          v-model="form.body"
          required
          minlength="3"
          maxlength="280"
        />
      </label>
      <label
        >Destination<select v-model="form.deepLink">
          <option>/notifications</option>
          <option>/reports</option>
          <option>/account</option>
        </select></label
      >
      <label
        >Image (optional HTTPS URL)<input
          v-model="form.imageUrl"
          type="url"
          maxlength="2048"
          placeholder="https://…"
      /></label>
      <label
        >Audience<select v-model="form.audience">
          <option value="all">All opted-in accounts</option>
          <option value="single">Specific account</option>
        </select></label
      >
      <div
        v-if="form.audience === 'single'"
        class="account-picker"
        @focusout="closeAccountPicker"
      >
        <label for="campaign-account">Account</label>
        <input
          id="campaign-account"
          v-model="accountSearch"
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
          <p v-else-if="accountSearchError" class="account-state error">
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
        <p v-if="selectedAccount" class="selected-account">
          Selected UUID: <code>{{ selectedAccount.id }}</code>
        </p>
        <p v-else class="account-help">
          Choose a result to attach its UUID to this campaign.
        </p>
      </div>
      <label
        >Platform<select v-model="form.platform">
          <option value="all">All platforms</option>
          <option value="android">Android</option>
          <option value="ios">iOS</option>
          <option value="web">Web</option>
        </select></label
      >
      <div class="wide">
        <button
          :disabled="busy || (form.audience === 'single' && !form.userId)"
        >
          {{ editing ? "Save draft changes" : "Save draft" }}
        </button>
        <button v-if="editing" type="button" @click="editing = ''">
          Create a new draft instead
        </button>
      </div>
    </form>
    <p v-if="error" role="alert" class="error">{{ error }}</p>
    <p v-if="message" role="status">{{ message }}</p>
    <section v-if="selected">
      <h4>
        {{ selected.name }} · {{ selected.status
        }}{{ selected.is_test ? " · Test" : "" }}
      </h4>
      <blockquote v-if="preview">
        <strong>{{ preview.title }}</strong>
        <p>{{ preview.body }}</p>
        <small>{{ preview.deepLink }}</small>
      </blockquote>
      <p v-if="preview">
        Estimated audience: {{ preview.users }} accounts,
        {{ preview.devices }} eligible devices. Eligibility is checked again
        when sending.
      </p>
      <div v-if="selected.status === 'draft'" class="composer">
        <label
          >Schedule in your local timezone (blank sends now)<input
            v-model="schedule"
            type="datetime-local"
        /></label>
        <label
          >Broadcast approval token<input
            v-model="approval"
            type="password"
            autocomplete="off"
        /></label>
        <div class="wide">
          <button :disabled="busy || !preview" @click="send(true)">
            Test on my devices
          </button>
          <button
            :disabled="busy || !preview || preview.devices === 0"
            @click="send(false)"
          >
            {{ schedule ? "Schedule" : "Send now" }}
          </button>
        </div>
      </div>
      <div v-if="analytics" class="analytics">
        <p>
          {{ analytics.users }} targeted accounts ·
          {{ analytics.devices }} devices · {{ analytics.accepted }} provider
          accepted · {{ analytics.failed }} failed ·
          {{ analytics.skipped }} skipped
        </p>
        <p>
          {{ analytics.received }} app received · {{ analytics.opens }} device
          opens ({{ (analytics.openRate * 100).toFixed(1) }}%) ·
          {{ analytics.actions }} destination opens ({{
            (analytics.actionRate * 100).toFixed(1)
          }}%)
        </p>
        <small
          >{{ analytics.definitions }} FCM acceptance does not confirm delivery
          or viewing.</small
        >
        <p v-for="p in analytics.platforms" :key="p.platform + p.status">
          {{ p.platform }} · {{ p.status }}: {{ p.count }}
        </p>
        <p v-for="f in analytics.failures" :key="f.failure_code">
          {{ f.failure_code }}: {{ f.count }}
        </p>
        <details>
          <summary>Audit history</summary>
          <p v-for="(e, i) in analytics.events" :key="i">
            {{ new Date(e.created_at).toLocaleString() }} · {{ e.event_type }}
          </p>
        </details>
      </div>
    </section>
    <h4>
      Campaign history
      <button :disabled="busy" @click="action(refresh)">Refresh</button>
    </h4>
    <div class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Status</th>
            <th>Schedule</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="c in rows" :key="c.id">
            <td>
              <button @click="action(() => inspect(c))">
                {{ c.name }}{{ c.is_test ? " (Test)" : "" }}
              </button>
            </td>
            <td>{{ c.status }}</td>
            <td>
              {{
                c.scheduled_at
                  ? new Date(c.scheduled_at).toLocaleString()
                  : "Draft"
              }}
            </td>
            <td>
              <button
                v-if="c.status === 'draft'"
                :disabled="busy"
                @click="editDraft(c)"
              >
                Edit
              </button>
              <button
                v-if="['draft', 'queued'].includes(c.status) && !c.started_at"
                :disabled="busy"
                @click="cancel(c)"
              >
                Cancel
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>
</template>
<style scoped>
.campaigns {
  padding: 24px;
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  margin: 24px 0;
  color: #0f172a;
}
.composer {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
  margin: 20px 0;
}
.composer label {
  display: flex;
  flex-direction: column;
  gap: 6px;
  font-size: 14px;
}
.account-picker {
  position: relative;
  min-width: 0;
}
.account-picker > label {
  display: block;
  margin-bottom: 6px;
  font-size: 14px;
}
.account-picker > input {
  width: 100%;
  box-sizing: border-box;
}
.account-results {
  position: absolute;
  z-index: 20;
  top: calc(100% - 20px);
  right: 0;
  left: 0;
  max-height: 280px;
  overflow-y: auto;
  padding: 6px;
  border: 1px solid #cbd5e1;
  border-radius: 8px;
  background: white;
  box-shadow: 0 12px 28px rgb(15 23 42 / 14%);
}
.account-option {
  display: grid;
  width: 100%;
  gap: 2px;
  padding: 9px 10px;
  border: 0;
  text-align: left;
  background: transparent;
}
.account-option:hover,
.account-option--active {
  background: #f1f5f9;
}
.account-option strong,
.account-option span,
.account-option code {
  overflow-wrap: anywhere;
}
.account-option span,
.account-option code,
.account-state,
.account-help,
.selected-account {
  color: #64748b;
  font-size: 12px;
}
.account-option code,
.selected-account code {
  font-variant-numeric: tabular-nums;
}
.account-state {
  margin: 0;
  padding: 10px;
}
.account-help,
.selected-account {
  margin: 6px 0 0;
}
.wide {
  grid-column: 1/-1;
}
input,
select,
textarea {
  border: 1px solid #cbd5e1;
  border-radius: 6px;
  padding: 10px;
  font: inherit;
}
textarea {
  min-height: 90px;
}
button {
  border: 1px solid #94a3b8;
  border-radius: 6px;
  padding: 8px 12px;
  cursor: pointer;
  background: #f8fafc;
  color: #0f172a;
}
button:disabled {
  opacity: 0.5;
  cursor: default;
}
.error {
  color: #b91c1c;
}
blockquote,
.analytics {
  background: #f8fafc;
  padding: 16px;
  margin: 16px 0;
  border-radius: 8px;
}
.table-wrap {
  overflow: auto;
}
table {
  width: 100%;
  border-collapse: collapse;
}
td,
th {
  padding: 12px;
  text-align: left;
  border-bottom: 1px solid #e2e8f0;
}
@media (max-width: 700px) {
  .composer {
    grid-template-columns: 1fr;
  }
}
</style>
