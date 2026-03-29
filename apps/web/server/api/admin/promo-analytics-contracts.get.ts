export default defineEventHandler(() => {
  return {
    story: '5-4-promo-redemption-and-revenue-impact-analytics',
    status: 'stub',
    endpoints: [
      {
        route: '/v1/billing/admin/promo-analytics',
        method: 'GET',
        description:
          'Returns paginated promo redemption and finalized revenue impact analytics',
        states: ['pending', 'success', 'failure', 'reverted'],
      },
      {
        route: '/v1/billing/admin/promo-analytics/export',
        method: 'POST',
        description:
          'Exports PHI-safe promo analytics (CSV/JSON) with auditable scope metadata',
        states: ['pending', 'success', 'failure', 'reverted'],
      },
    ],
  };
});
