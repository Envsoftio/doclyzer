<script setup lang="ts">
import { formatDisplayDate } from "../../../utils/formatDisplayDate";

definePageMeta({ layout: "admin" });
useSeoMeta({
  robots: "noindex, nofollow",
  title: "Promo codes — Doclyzer Admin",
});

interface Promo {
  id: string;
  code: string;
  discountType: "percentage" | "fixed";
  discountValue: number;
  maxDiscountAmount: number | null;
  appliesTo: "credit_pack" | "subscription" | "both";
  validFrom: string | null;
  validUntil: string | null;
  usageCapTotal: number | null;
  usageCapPerUser: number | null;
  isActive: boolean;
  redemptions: { reserved: number; redeemed: number; void: number };
  updatedAt: string;
}
const { adminFetch } = useAdminApi();
const promos = ref<Promo[]>([]);
const loading = ref(true);
const saving = ref(false);
const busyId = ref<string | null>(null);
const error = ref("");
const notice = ref("");
const promoSearch = ref("");
const promoStatus = ref("");
const promoPage = ref(1);
const promoPageSize = 20;
const filteredPromos = computed(() => promos.value.filter(item =>
  (!promoStatus.value || (promoStatus.value === 'active') === item.isActive) &&
  (!promoSearch.value.trim() || item.code.toLowerCase().includes(promoSearch.value.trim().toLowerCase())),
));
const visiblePromos = computed(() => filteredPromos.value.slice((promoPage.value - 1) * promoPageSize, promoPage.value * promoPageSize));
const promoPages = computed(() => Math.max(1, Math.ceil(filteredPromos.value.length / promoPageSize)));
watch([promoSearch, promoStatus], () => { promoPage.value = 1; });
const code = ref("");
const discountType = ref<"percentage" | "fixed">("percentage");
const discountValue = ref<number | null>(null);
const maxDiscountAmount = ref<number | null>(null);
const appliesTo = ref<"credit_pack" | "subscription" | "both">("credit_pack");
const validUntil = ref("");
const usageCapTotal = ref<number | null>(null);
const usageCapPerUser = ref<number | null>(null);

async function loadPromos() {
  loading.value = true;
  error.value = "";
  try {
    const response = await adminFetch<{ data: { promos: Promo[] } }>(
      "/billing/admin/promos",
    );
    promos.value = response.data.promos;
  } catch (e: unknown) {
    error.value =
      e instanceof Error ? e.message : "Could not load promo codes.";
  } finally {
    loading.value = false;
  }
}

async function createPromo() {
  error.value = "";
  notice.value = "";
  if (!code.value.trim() || !discountValue.value || discountValue.value <= 0) {
    error.value = "Enter a code and a positive discount value.";
    return;
  }
  if (discountType.value === "percentage" && discountValue.value > 100) {
    error.value = "Percentage discount cannot exceed 100%.";
    return;
  }
  if (
    [usageCapTotal.value, usageCapPerUser.value].some(
      (value: unknown) =>
        value !== null &&
        value !== "" &&
        (!Number.isInteger(value) || Number(value) < 1),
    )
  ) {
    error.value = "Usage caps must be whole numbers greater than zero.";
    return;
  }
  if (
    validUntil.value &&
    new Date(`${validUntil.value}T23:59:59Z`).getTime() <= Date.now()
  ) {
    error.value = "The end date must be in the future.";
    return;
  }
  saving.value = true;
  try {
    await adminFetch("/billing/admin/promos", {
      method: "POST",
      body: {
        code: code.value.trim().toUpperCase(),
        discountType: discountType.value,
        discountValue: discountValue.value,
        appliesTo: appliesTo.value,
        ...(discountType.value === "percentage" && maxDiscountAmount.value
          ? { maxDiscountAmount: maxDiscountAmount.value }
          : {}),
        ...(validUntil.value
          ? { validUntil: `${validUntil.value}T23:59:59Z` }
          : {}),
        ...(usageCapTotal.value ? { usageCapTotal: usageCapTotal.value } : {}),
        ...(usageCapPerUser.value
          ? { usageCapPerUser: usageCapPerUser.value }
          : {}),
      },
    });
    notice.value = `Promo ${code.value.trim().toUpperCase()} created.`;
    code.value = "";
    discountValue.value = null;
    await loadPromos();
  } catch (e: unknown) {
    error.value =
      e instanceof Error ? e.message : "Could not create promo code.";
  } finally {
    saving.value = false;
  }
}

async function togglePromo(promo: Promo) {
  busyId.value = promo.id;
  error.value = "";
  notice.value = "";
  try {
    await adminFetch(
      `/billing/admin/promos/${encodeURIComponent(promo.id)}/${promo.isActive ? "deactivate" : "reactivate"}`,
      { method: "POST" },
    );
    notice.value = `${promo.code} ${promo.isActive ? "deactivated" : "reactivated"}.`;
    await loadPromos();
  } catch (e: unknown) {
    error.value =
      e instanceof Error ? e.message : "Could not change promo status.";
  } finally {
    busyId.value = null;
  }
}

onMounted(loadPromos);
</script>

<template>
  <div class="admin-ops">
    <header class="admin-ops__header">
      <div>
        <p class="admin-ops__eyebrow">Manage / Billing</p>
        <h1>Promo codes</h1>
        <p class="admin-ops__subtitle">
          Create and manage discounts used during credit pack checkout.
        </p>
      </div>
      <button
        class="admin-ops__button"
        type="button"
        :disabled="loading"
        @click="loadPromos"
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
        <h2>Create a promo</h2>
        <p>
          Credit pack promo codes work in the current mobile checkout.
          Subscription promo entry is shown in the app but is not yet supported
          there.
        </p>
        <form @submit.prevent="createPromo">
          <label class="admin-ops__field"
            >Code<input
              v-model="code"
              class="admin-ops__input"
              maxlength="64"
              required
              placeholder="e.g. WELCOME20"
          /></label>
          <div class="admin-ops__row">
            <label class="admin-ops__field"
              >Discount type<select
                v-model="discountType"
                class="admin-ops__select"
              >
                <option value="percentage">Percentage</option>
                <option value="fixed">Fixed amount</option>
              </select></label
            ><label class="admin-ops__field"
              >{{ discountType === "percentage" ? "Percent off" : "Amount off"
              }}<input
                v-model.number="discountValue"
                class="admin-ops__input"
                type="number"
                min="0.01"
                :max="discountType === 'percentage' ? 100 : undefined"
                step="0.01"
                required
            /></label>
          </div>
          <label v-if="discountType === 'percentage'" class="admin-ops__field"
            >Maximum discount amount (optional)<input
              v-model.number="maxDiscountAmount"
              class="admin-ops__input"
              type="number"
              min="0.01"
              step="0.01" /></label
          ><label class="admin-ops__field"
            >Applies to<select v-model="appliesTo" class="admin-ops__select">
              <option value="credit_pack">Credit packs</option>
              <option value="subscription">Subscriptions</option>
              <option value="both">Both</option>
            </select></label
          ><label class="admin-ops__field"
            >End date (optional)<input
              v-model="validUntil"
              class="admin-ops__input"
              type="date"
          /></label>
          <div class="admin-ops__row">
            <label class="admin-ops__field"
              >Total uses (optional)<input
                v-model.number="usageCapTotal"
                class="admin-ops__input"
                type="number"
                min="1"
                step="1" /></label
            ><label class="admin-ops__field"
              >Uses per user (optional)<input
                v-model.number="usageCapPerUser"
                class="admin-ops__input"
                type="number"
                min="1"
                step="1"
            /></label>
          </div>
          <button
            class="admin-ops__button admin-ops__button--primary"
            type="submit"
            :disabled="saving"
          >
            {{ saving ? "Creating…" : "Create promo" }}
          </button>
        </form>
      </section>
      <section class="admin-ops__card">
        <h2>
          Existing promos
          <span class="admin-ops__muted">({{ promos.length }})</span>
        </h2>
        <p>
          Deactivation stops future use. Reserved redemptions are voided by the
          billing service.
        </p>
        <div class="admin-ops__row"><label class="admin-ops__field">Find code<input v-model="promoSearch" class="admin-ops__input" type="search" placeholder="Promo code" /></label><label class="admin-ops__field">Status<select v-model="promoStatus" class="admin-ops__select"><option value="">All</option><option value="active">Active</option><option value="inactive">Inactive</option></select></label></div>
        <p v-if="loading" role="status">Loading promos…</p>
        <p v-else-if="!filteredPromos.length" class="admin-ops__empty">
          No promo codes match.
        </p>
        <div v-else class="admin-ops__table-wrap">
          <table class="admin-ops__table">
            <thead>
              <tr>
                <th>Code</th>
                <th>Discount</th>
                <th>Applies to</th>
                <th>Redeemed</th>
                <th>Ends</th>
                <th>Status</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="promo in visiblePromos" :key="promo.id">
                <td class="admin-ops__code">{{ promo.code }}</td>
                <td>
                  {{
                    promo.discountType === "percentage"
                      ? `${promo.discountValue}%`
                      : promo.discountValue
                  }}<span
                    v-if="promo.maxDiscountAmount"
                    class="admin-ops__muted"
                  >
                    · max {{ promo.maxDiscountAmount }}</span
                  >
                </td>
                <td>{{ promo.appliesTo.replaceAll("_", " ") }}</td>
                <td>
                  {{ promo.redemptions.redeemed
                  }}{{ promo.usageCapTotal ? ` / ${promo.usageCapTotal}` : "" }}
                </td>
                <td>
                  {{
                    promo.validUntil
                      ? formatDisplayDate(promo.validUntil)
                      : "No end date"
                  }}
                </td>
                <td>
                  <span
                    class="admin-ops__badge"
                    :class="{ 'admin-ops__badge--warm': !promo.isActive }"
                    >{{ promo.isActive ? "Active" : "Inactive" }}</span
                  >
                </td>
                <td>
                  <button
                    class="admin-ops__button"
                    type="button"
                    :disabled="busyId === promo.id"
                    @click="togglePromo(promo)"
                  >
                    {{ promo.isActive ? "Deactivate" : "Reactivate" }}
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-if="filteredPromos.length > promoPageSize" class="admin-ops__pagination"><span>{{ (promoPage - 1) * promoPageSize + 1 }}–{{ Math.min(promoPage * promoPageSize, filteredPromos.length) }} of {{ filteredPromos.length }}</span><div><button class="admin-ops__button" :disabled="promoPage <= 1" @click="promoPage--">Previous</button><span>Page {{ promoPage }} of {{ promoPages }}</span><button class="admin-ops__button" :disabled="promoPage >= promoPages" @click="promoPage++">Next</button></div></div>
      </section>
    </div>
  </div>
</template>
