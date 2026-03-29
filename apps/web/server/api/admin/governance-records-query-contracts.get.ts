export default defineEventHandler(() => {
  return {
    story: '5-8-access-share-consent-policy-records-query-console',
    status: 'stub',
    endpoints: [
      {
        route: '/v1/admin/analytics/governance/records',
        method: 'GET',
        description:
          'Queries access/share/consent/policy governance records with bounded windows and cursor pagination.',
        states: ['pending', 'success', 'failure', 'reverted'],
      },
      {
        route: '/v1/admin/analytics/governance/records/export',
        method: 'POST',
        description:
          'Exports PHI-safe governance records with correlation metadata and sanitized payload fields.',
        states: ['pending', 'success', 'failure', 'reverted'],
      },
    ],
  };
});
