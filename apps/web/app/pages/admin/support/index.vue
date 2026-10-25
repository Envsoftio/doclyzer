<script setup lang="ts">
import { formatDisplayDate } from "../../../utils/formatDisplayDate";

definePageMeta({ layout: "admin" });
useSeoMeta({
  robots: "noindex, nofollow",
  title: "Support requests — Doclyzer Admin",
});

type Status = "open" | "triaged" | "resolved";
interface SupportItem {
  id: string;
  userId: string;
  actionType: string;
  correlationId: string;
  status: Status;
  createdAt: string;
}
interface SupportDetail extends SupportItem {
  clientActionId: string | null;
  errorCode: string | null;
  errorMessage: string | null;
  entityIds: Record<string, string> | null;
  userMessage: string | null;
}
interface SupportList {
  items: SupportItem[];
  total: number;
  page: number;
  limit: number;
}

const { adminFetch } = useAdminApi();
const items = ref<SupportItem[]>([]);
const selected = ref<SupportDetail | null>(null);
const statusFilter = ref("open");
const actionFilter = ref("");
const userFilter = ref("");
const page = ref(1);
const total = ref(0);
const limit = 20;
const loading = ref(true);
const detailLoading = ref(false);
const saving = ref(false);
const error = ref("");
const message = ref("");

const actionTypes = [
  "auth",
  "report_upload",
  "report_parse",
  "share_link_create",
  "share_link_revoke",
  "billing_entitlement",
  "billing_checkout",
  "notification_preferences",
  "account_profile_update",
  "product_help",
];
const statuses: Status[] = ["open", "triaged", "resolved"];
const totalPages = computed(() => Math.max(1, Math.ceil(total.value / limit)));

async function loadRequests() {
  loading.value = true;
  error.value = "";
  try {
    const query = new URLSearchParams({
      page: String(page.value),
      limit: String(limit),
    });
    if (statusFilter.value) query.set("status", statusFilter.value);
    if (actionFilter.value) query.set("actionType", actionFilter.value);
    if (userFilter.value.trim()) query.set("userId", userFilter.value.trim());
    const response = await adminFetch<{ data: SupportList }>(
      `/admin/support-requests?${query}`,
    );
    items.value = response.data.items;
    total.value = response.data.total;
    if (
      selected.value &&
      !items.value.some((item) => item.id === selected.value?.id)
    )
      selected.value = null;
  } catch (e: unknown) {
    error.value =
      e instanceof Error ? e.message : "Could not load support requests.";
  } finally {
    loading.value = false;
  }
}

async function openRequest(id: string) {
  detailLoading.value = true;
  error.value = "";
  try {
    const response = await adminFetch<{ data: SupportDetail }>(
      `/admin/support-requests/${encodeURIComponent(id)}`,
    );
    selected.value = response.data;
  } catch (e: unknown) {
    error.value =
      e instanceof Error ? e.message : "Could not load request details.";
  } finally {
    detailLoading.value = false;
  }
}

async function setStatus(status: Status) {
  if (!selected.value || saving.value) return;
  saving.value = true;
  error.value = "";
  message.value = "";
  try {
    const response = await adminFetch<{ data: SupportDetail }>(
      `/admin/support-requests/${encodeURIComponent(selected.value.id)}/status`,
      {
        method: "PATCH",
        body: { status },
      },
    );
    selected.value = response.data;
    message.value = `Request marked ${status}.`;
    await loadRequests();
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : "Could not update request.";
  } finally {
    saving.value = false;
  }
}

function applyFilters() {
  page.value = 1;
  selected.value = null;
  void loadRequests();
}
function changePage(next: number) {
  page.value = next;
  selected.value = null;
  void loadRequests();
}
onMounted(loadRequests);
</script>

<template>
  <div class="admin-ops">
    <header class="admin-ops__header">
      <div>
        <p class="admin-ops__eyebrow">Operations / Help desk</p>
        <h1>Support requests</h1>
        <p class="admin-ops__subtitle">
          Review problems reported from the mobile app and track their handling
          status.
        </p>
      </div>
      <button
        class="admin-ops__button"
        type="button"
        :disabled="loading"
        @click="loadRequests"
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
    <p v-if="message" class="admin-ops__message" role="status">{{ message }}</p>
    <div class="admin-ops__grid">
      <section class="admin-ops__card">
        <h2>Find requests</h2>
        <p>Filter by status, app action, or a user ID.</p>
        <form @submit.prevent="applyFilters">
          <label class="admin-ops__field"
            >Status<select v-model="statusFilter" class="admin-ops__select">
              <option value="">All statuses</option>
              <option value="open">Open</option>
              <option value="triaged">Triaged</option>
              <option value="resolved">Resolved</option>
            </select></label
          >
          <label class="admin-ops__field"
            >Action<select v-model="actionFilter" class="admin-ops__select">
              <option value="">All actions</option>
              <option
                v-for="action in actionTypes"
                :key="action"
                :value="action"
              >
                {{ action.replaceAll("_", " ") }}
              </option>
            </select></label
          >
          <label class="admin-ops__field"
            >User ID<input
              v-model="userFilter"
              class="admin-ops__input"
              type="text"
              placeholder="Optional user UUID"
          /></label>
          <button
            class="admin-ops__button admin-ops__button--primary"
            type="submit"
          >
            Apply filters
          </button>
        </form>
      </section>
      <div>
        <section class="admin-ops__card">
          <h2>
            Queue <span class="admin-ops__muted">({{ total }})</span>
          </h2>
          <p v-if="loading" role="status">Loading requests…</p>
          <p v-else-if="items.length === 0" class="admin-ops__empty">
            No requests match these filters.
          </p>
          <div v-else class="admin-ops__table-wrap">
            <table class="admin-ops__table">
              <thead>
                <tr>
                  <th>Received</th>
                  <th>Action</th>
                  <th>User</th>
                  <th>Status</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in items" :key="item.id">
                  <td>{{ formatDisplayDate(item.createdAt, true) }}</td>
                  <td>{{ item.actionType.replaceAll("_", " ") }}</td>
                  <td class="admin-ops__code">
                    {{ item.userId.slice(0, 8) }}…
                  </td>
                  <td>
                    <span
                      class="admin-ops__badge"
                      :class="{
                        'admin-ops__badge--warm': item.status === 'triaged',
                        'admin-ops__badge--red': item.status === 'open',
                      }"
                      >{{ item.status }}</span
                    >
                  </td>
                  <td>
                    <button
                      class="admin-ops__button"
                      type="button"
                      @click="openRequest(item.id)"
                    >
                      Review
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <div v-if="totalPages > 1" class="admin-ops__actions">
            <button
              class="admin-ops__button"
              type="button"
              :disabled="page <= 1 || loading"
              @click="changePage(page - 1)"
            >
              Previous</button
            ><span class="admin-ops__muted"
              >Page {{ page }} of {{ totalPages }}</span
            ><button
              class="admin-ops__button"
              type="button"
              :disabled="page >= totalPages || loading"
              @click="changePage(page + 1)"
            >
              Next
            </button>
          </div>
        </section>
        <section v-if="selected || detailLoading" class="admin-ops__card">
          <h2>Request details</h2>
          <p v-if="detailLoading">Loading details…</p>
          <template v-else-if="selected">
            <div class="admin-ops__detail">
              <dl>
                <dt>User</dt>
                <dd>
                  <NuxtLink :to="`/admin/users/${selected.userId}`">{{
                    selected.userId
                  }}</NuxtLink>
                </dd>
                <dt>Action</dt>
                <dd>{{ selected.actionType.replaceAll("_", " ") }}</dd>
                <dt>Correlation ID</dt>
                <dd class="admin-ops__code">{{ selected.correlationId }}</dd>
                <dt>Client action ID</dt>
                <dd class="admin-ops__code">
                  {{ selected.clientActionId || "—" }}
                </dd>
                <dt>Error code</dt>
                <dd>{{ selected.errorCode || "—" }}</dd>
                <dt>Error message</dt>
                <dd>{{ selected.errorMessage || "—" }}</dd>
                <dt>User message</dt>
                <dd>{{ selected.userMessage || "—" }}</dd>
                <dt>Related IDs</dt>
                <dd class="admin-ops__code">
                  {{
                    selected.entityIds
                      ? Object.entries(selected.entityIds)
                          .map(([key, value]) => `${key}: ${value}`)
                          .join(", ")
                      : "—"
                  }}
                </dd>
              </dl>
            </div>
            <div class="admin-ops__actions">
              <button
                v-for="status in statuses"
                :key="status"
                class="admin-ops__button"
                :class="{ 'admin-ops__button--primary': status === 'resolved' }"
                type="button"
                :disabled="saving || selected.status === status"
                @click="setStatus(status)"
              >
                Mark {{ status }}
              </button>
            </div>
          </template>
        </section>
      </div>
    </div>
  </div>
</template>
