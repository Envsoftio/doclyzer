<script setup lang="ts">
definePageMeta({ layout: "admin" });
useSeoMeta({
  robots: "noindex, nofollow",
  title: "Referral policy — Doclyzer Admin",
});

interface Tier {
  label: string;
  thresholdAmount: number;
  rewardCredits: number;
}
interface Policy {
  inviteeBonusCredits: number;
  milestoneACredits: number;
  milestoneBTiers: Tier[];
  monthlyRewardCap: number;
  zeroAmountOrderEligible: boolean;
  updatedAt: string | null;
}
const { adminFetch } = useAdminApi();
const policy = ref<Policy | null>(null);
const edit = ref<Policy | null>(null);
const loading = ref(true);
const saving = ref(false);
const error = ref("");
const notice = ref("");

function copyPolicy(value: Policy): Policy {
  return {
    ...value,
    milestoneBTiers: value.milestoneBTiers.map((tier) => ({ ...tier })),
  };
}

async function loadPolicy() {
  loading.value = true;
  error.value = "";
  try {
    const response = await adminFetch<{ data: Policy }>(
      "/admin/referrals/policy",
    );
    policy.value = response.data;
    edit.value = copyPolicy(response.data);
  } catch (e: unknown) {
    error.value =
      e instanceof Error ? e.message : "Could not load referral policy.";
  } finally {
    loading.value = false;
  }
}

function addTier() {
  if (!edit.value || edit.value.milestoneBTiers.length >= 10) return;
  const previous = edit.value.milestoneBTiers.at(-1);
  edit.value.milestoneBTiers.push({
    label: `tier_${edit.value.milestoneBTiers.length + 1}`,
    thresholdAmount: previous ? previous.thresholdAmount + 1 : 0,
    rewardCredits: 0,
  });
}

function validate(value: Policy): string | null {
  const amounts = [
    value.inviteeBonusCredits,
    value.milestoneACredits,
    value.monthlyRewardCap,
    ...value.milestoneBTiers.flatMap((tier) => [
      tier.thresholdAmount,
      tier.rewardCredits,
    ]),
  ];
  if (
    amounts.some(
      (amount) =>
        typeof amount !== "number" ||
        !Number.isFinite(amount) ||
        amount < 0 ||
        amount > 99999999 ||
        Math.abs(Math.round(amount * 100) - amount * 100) > 1e-6,
    )
  )
    return "Amounts must be non-negative numbers with at most two decimal places.";
  if (value.milestoneBTiers.length < 1 || value.milestoneBTiers.length > 10)
    return "Add between 1 and 10 paid-order tiers.";
  if (value.milestoneBTiers[0]?.thresholdAmount !== 0)
    return "The first paid-order tier must start at zero.";
  if (
    value.milestoneBTiers.some(
      (tier, index) =>
        index > 0 &&
        tier.thresholdAmount <=
          value.milestoneBTiers[index - 1]!.thresholdAmount,
    )
  )
    return "Tier thresholds must increase from top to bottom.";
  const labels = value.milestoneBTiers.map((tier) => tier.label.trim());
  if (
    labels.some((label) => !label || label.length > 64) ||
    new Set(labels).size !== labels.length
  )
    return "Tier labels must be unique and 1–64 characters.";
  return null;
}

async function savePolicy() {
  if (!edit.value || !policy.value || saving.value) return;
  error.value = validate(edit.value) ?? "";
  notice.value = "";
  if (error.value) return;
  saving.value = true;
  try {
    const response = await adminFetch<{ data: Policy }>(
      "/admin/referrals/policy",
      {
        method: "PUT",
        body: { ...edit.value, expectedUpdatedAt: policy.value.updatedAt },
      },
    );
    policy.value = response.data;
    edit.value = copyPolicy(response.data);
    notice.value =
      "Referral policy saved. New reward decisions will use these values.";
  } catch (e: unknown) {
    error.value =
      e instanceof Error
        ? e.message
        : "Could not save referral policy. Reload before trying again.";
  } finally {
    saving.value = false;
  }
}

onMounted(loadPolicy);
</script>

<template>
  <div class="admin-ops">
    <header class="admin-ops__header">
      <div>
        <p class="admin-ops__eyebrow">Manage / Growth</p>
        <h1>Referral policy</h1>
        <p class="admin-ops__subtitle">
          Set the credit rewards and thresholds displayed in the mobile referral
          dashboard.
        </p>
      </div>
      <button
        class="admin-ops__button"
        type="button"
        :disabled="loading || saving"
        @click="loadPolicy"
      >
        Reload policy
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
    <p v-if="loading">Loading policy…</p>
    <form v-else-if="edit" class="admin-ops__grid" @submit.prevent="savePolicy">
      <div>
        <section class="admin-ops__card">
          <h2>Reward amounts</h2>
          <p>
            Credits are awarded when the app's eligibility checks complete.
            Changes affect future reward decisions.
          </p>
          <label class="admin-ops__field"
            >Invitee bonus credits<input
              v-model.number="edit.inviteeBonusCredits"
              class="admin-ops__input"
              type="number"
              min="0"
              step="0.01"
              required /></label
          ><label class="admin-ops__field"
            >First analysis reward credits<input
              v-model.number="edit.milestoneACredits"
              class="admin-ops__input"
              type="number"
              min="0"
              step="0.01"
              required /></label
          ><label class="admin-ops__field"
            >Monthly reward cap<input
              v-model.number="edit.monthlyRewardCap"
              class="admin-ops__input"
              type="number"
              min="0"
              step="0.01"
              required /></label
          ><label class="admin-ops__check"
            ><input
              v-model="edit.zeroAmountOrderEligible"
              type="checkbox"
            />Zero-amount orders qualify for paid-order rewards</label
          >
        </section>
        <section class="admin-ops__card">
          <h2>Review changes</h2>
          <p>
            Saving immediately changes the policy used by reward processing.
            Existing credits are not recalculated.
          </p>
          <button
            class="admin-ops__button admin-ops__button--primary"
            type="submit"
            :disabled="saving"
          >
            {{ saving ? "Saving…" : "Save referral policy" }}
          </button>
        </section>
      </div>
      <section class="admin-ops__card">
        <h2>First paid-order tiers</h2>
        <p>
          Set the reward for the invitee's first qualifying paid order. Keep
          thresholds in ascending order, starting at zero. Thresholds compare
          the raw charged amount; currencies are not converted.
        </p>
        <div
          v-for="(tier, index) in edit.milestoneBTiers"
          :key="index"
          class="admin-ops__detail"
          style="margin-bottom: 12px"
        >
          <div class="admin-ops__row">
            <label class="admin-ops__field"
              >Tier label<input
                v-model="tier.label"
                class="admin-ops__input"
                maxlength="64"
                required /></label
            ><label class="admin-ops__field"
              >Order amount threshold<input
                v-model.number="tier.thresholdAmount"
                class="admin-ops__input"
                type="number"
                min="0"
                step="0.01"
                required /></label
            ><label class="admin-ops__field"
              >Reward credits<input
                v-model.number="tier.rewardCredits"
                class="admin-ops__input"
                type="number"
                min="0"
                step="0.01"
                required
            /></label>
          </div>
          <button
            v-if="edit.milestoneBTiers.length > 1"
            class="admin-ops__button admin-ops__button--danger"
            type="button"
            @click="edit.milestoneBTiers.splice(index, 1)"
          >
            Remove tier
          </button>
        </div>
        <button
          class="admin-ops__button"
          type="button"
          :disabled="edit.milestoneBTiers.length >= 10"
          @click="addTier"
        >
          Add tier
        </button>
      </section>
    </form>
  </div>
</template>
