<script setup lang="ts">
import { formatDisplayDate } from "../../../utils/formatDisplayDate";

definePageMeta({ layout: "admin" });
useSeoMeta({
  robots: "noindex, nofollow",
  title: "Gift vouchers — Doclyzer Admin",
});

interface Voucher {
  id: string;
  codeMask: string;
  creditAmount: number;
  status: "active" | "redeemed" | "voided" | "expired";
  expiresAt: string | null;
  redeemedByUserId: string | null;
  redeemedAt: string | null;
  voidReason: string | null;
  createdAt: string;
}
interface GeneratedVoucher extends Voucher {
  code: string;
}
const { adminFetch } = useAdminApi();
const vouchers = ref<Voucher[]>([]);
const generated = ref<GeneratedVoucher[]>([]);
const creditAmount = ref<number | null>(null);
const count = ref(1);
const expiresAt = ref("");
const voiding = ref<Voucher | null>(null);
const voidReason = ref("");
const loading = ref(true);
const saving = ref(false);
const error = ref("");
const notice = ref("");
const voucherStatus = ref("");
const voucherSearch = ref("");
const voucherPage = ref(1);
const voucherPageSize = 20;
const filteredVouchers = computed(() => vouchers.value.filter(item =>
  (!voucherStatus.value || item.status === voucherStatus.value) &&
  (!voucherSearch.value.trim() || item.codeMask.toLowerCase().includes(voucherSearch.value.trim().toLowerCase())),
));
const visibleVouchers = computed(() => filteredVouchers.value.slice((voucherPage.value - 1) * voucherPageSize, voucherPage.value * voucherPageSize));
const voucherPages = computed(() => Math.max(1, Math.ceil(filteredVouchers.value.length / voucherPageSize)));
watch([voucherStatus, voucherSearch], () => { voucherPage.value = 1; });

async function loadVouchers() {
  loading.value = true;
  error.value = "";
  try {
    const response = await adminFetch<{ data: { vouchers: Voucher[] } }>(
      "/gift-vouchers/admin",
    );
    vouchers.value = response.data.vouchers;
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : "Could not load vouchers.";
  } finally {
    loading.value = false;
  }
}

async function generate() {
  error.value = "";
  notice.value = "";
  if (
    !creditAmount.value ||
    creditAmount.value <= 0 ||
    !Number.isInteger(count.value) ||
    count.value < 1 ||
    count.value > 100
  ) {
    error.value = "Enter a positive credit amount and a count from 1 to 100.";
    return;
  }
  if (
    expiresAt.value &&
    new Date(`${expiresAt.value}T23:59:59Z`).getTime() <= Date.now()
  ) {
    error.value = "Expiry must be a future date.";
    return;
  }
  saving.value = true;
  try {
    const response = await adminFetch<{
      data: { vouchers: GeneratedVoucher[] };
    }>("/gift-vouchers/admin", {
      method: "POST",
      body: {
        creditAmount: creditAmount.value,
        count: count.value,
        ...(expiresAt.value
          ? { expiresAt: `${expiresAt.value}T23:59:59Z` }
          : {}),
      },
    });
    generated.value = response.data.vouchers;
    notice.value = `${generated.value.length} voucher${generated.value.length === 1 ? "" : "s"} created. Copy the codes now; they are masked on later visits.`;
    await loadVouchers();
  } catch (e: unknown) {
    error.value =
      e instanceof Error ? e.message : "Could not generate vouchers.";
  } finally {
    saving.value = false;
  }
}

async function copyCodes() {
  try {
    await navigator.clipboard.writeText(
      generated.value.map((item) => item.code).join("\n"),
    );
    notice.value = "Codes copied to clipboard.";
  } catch {
    error.value = "Clipboard access failed. Select and copy the visible codes.";
  }
}

async function voidVoucher() {
  if (!voiding.value || !voidReason.value.trim() || saving.value) return;
  error.value = "";
  saving.value = true;
  try {
    await adminFetch(
      `/gift-vouchers/admin/${encodeURIComponent(voiding.value.id)}/void`,
      { method: "POST", body: { reason: voidReason.value.trim() } },
    );
    notice.value = `Voucher ${voiding.value.codeMask} voided.`;
    voiding.value = null;
    voidReason.value = "";
    await loadVouchers();
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : "Could not void voucher.";
  } finally {
    saving.value = false;
  }
}

onMounted(loadVouchers);
</script>

<template>
  <div class="admin-ops">
    <header class="admin-ops__header">
      <div>
        <p class="admin-ops__eyebrow">Manage / Rewards</p>
        <h1>Gift vouchers</h1>
        <p class="admin-ops__subtitle">
          Create redeemable credit codes for the mobile app and track their
          status.
        </p>
      </div>
      <button
        class="admin-ops__button"
        type="button"
        :disabled="loading"
        @click="loadVouchers"
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
      <div>
        <section class="admin-ops__card">
          <h2>Generate vouchers</h2>
          <p>
            Each code can be redeemed once. Full codes appear only after
            creation.
          </p>
          <form @submit.prevent="generate">
            <label class="admin-ops__field"
              >Credits per voucher<input
                v-model.number="creditAmount"
                class="admin-ops__input"
                type="number"
                min="0.01"
                step="0.01"
                required /></label
            ><label class="admin-ops__field"
              >Number of vouchers<input
                v-model.number="count"
                class="admin-ops__input"
                type="number"
                min="1"
                max="100"
                step="1"
                required /></label
            ><label class="admin-ops__field"
              >Expiry date (optional)<input
                v-model="expiresAt"
                class="admin-ops__input"
                type="date" /></label
            ><button
              class="admin-ops__button admin-ops__button--primary"
              type="submit"
              :disabled="saving"
            >
              {{ saving ? "Generating…" : "Generate codes" }}
            </button>
          </form>
        </section>
        <section v-if="generated.length" class="admin-ops__card">
          <h2>New codes</h2>
          <p>
            Copy these before leaving this page. They cannot be revealed again.
          </p>
          <div class="admin-ops__detail">
            <p v-for="item in generated" :key="item.id" class="admin-ops__code">
              {{ item.code }} · {{ item.creditAmount }} credits
            </p>
          </div>
          <div class="admin-ops__actions">
            <button class="admin-ops__button" type="button" @click="copyCodes">
              Copy all codes</button
            ><button
              class="admin-ops__button"
              type="button"
              @click="generated = []"
            >
              Hide codes
            </button>
          </div>
        </section>
      </div>
      <div>
        <section class="admin-ops__card">
          <h2>Recent vouchers</h2>
          <p>Showing the 100 most recently created vouchers.</p>
          <div class="admin-ops__row"><label class="admin-ops__field">Find masked code<input v-model="voucherSearch" class="admin-ops__input" type="search" placeholder="Code prefix" /></label><label class="admin-ops__field">Status<select v-model="voucherStatus" class="admin-ops__select"><option value="">All statuses</option><option value="active">Active</option><option value="redeemed">Redeemed</option><option value="expired">Expired</option><option value="voided">Voided</option></select></label></div>
          <p v-if="loading" role="status">Loading vouchers…</p>
          <p v-else-if="!filteredVouchers.length" class="admin-ops__empty">
            No recent vouchers match.
          </p>
          <div v-else class="admin-ops__table-wrap">
            <table class="admin-ops__table">
              <thead>
                <tr>
                  <th>Code</th>
                  <th>Credits</th>
                  <th>Status</th>
                  <th>Created</th>
                  <th>Expires</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in visibleVouchers" :key="item.id">
                  <td class="admin-ops__code">{{ item.codeMask }}</td>
                  <td>{{ item.creditAmount }}</td>
                  <td>
                    <span
                      class="admin-ops__badge"
                      :class="{
                        'admin-ops__badge--red': item.status === 'voided',
                        'admin-ops__badge--warm': item.status === 'expired',
                      }"
                      >{{ item.status }}</span
                    >
                  </td>
                  <td>{{ formatDisplayDate(item.createdAt) }}</td>
                  <td>
                    {{
                      item.expiresAt
                        ? formatDisplayDate(item.expiresAt)
                        : "Never"
                    }}
                  </td>
                  <td>
                    <button
                      v-if="item.status === 'active'"
                      class="admin-ops__button admin-ops__button--danger"
                      type="button"
                      @click="
                        voiding = item;
                        voidReason = '';
                      "
                    >
                      Void
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <div v-if="filteredVouchers.length > voucherPageSize" class="admin-ops__pagination"><span>{{ (voucherPage - 1) * voucherPageSize + 1 }}–{{ Math.min(voucherPage * voucherPageSize, filteredVouchers.length) }} of {{ filteredVouchers.length }} recent vouchers</span><div><button class="admin-ops__button" :disabled="voucherPage <= 1" @click="voucherPage--">Previous</button><span>Page {{ voucherPage }} of {{ voucherPages }}</span><button class="admin-ops__button" :disabled="voucherPage >= voucherPages" @click="voucherPage++">Next</button></div></div>
        </section>
        <section v-if="voiding" class="admin-ops__card">
          <h2>Void {{ voiding.codeMask }}</h2>
          <p>
            This code will stop working immediately. Give a reason for the
            record.
          </p>
          <form @submit.prevent="voidVoucher">
            <label class="admin-ops__field"
              >Reason<textarea
                v-model="voidReason"
                class="admin-ops__textarea"
                maxlength="240"
                required
              ></textarea>
            </label>
            <div class="admin-ops__actions">
              <button
                class="admin-ops__button admin-ops__button--danger"
                type="submit"
                :disabled="saving || !voidReason.trim()"
              >
                {{ saving ? "Voiding…" : "Void voucher" }}</button
              ><button
                class="admin-ops__button"
                type="button"
                @click="voiding = null"
              >
                Cancel
              </button>
            </div>
          </form>
        </section>
      </div>
    </div>
  </div>
</template>
