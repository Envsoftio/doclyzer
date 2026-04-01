export default defineEventHandler(() => {
  return {
    story: '5-15-email-queue-delivery-analytics-and-sending-history-admin-panel',
    status: 'stub',
    endpoints: [
      {
        route: '/v1/admin/email/queue-status',
        method: 'GET',
        description: 'Returns pending/processing/completed email queue counts',
        states: ['pending', 'success', 'failure', 'reverted'],
      },
      {
        route: '/v1/admin/email/delivery-analytics',
        method: 'GET',
        description:
          'Returns PHI-safe counts by email type and outcome for a date window',
        states: ['pending', 'success', 'failure', 'reverted'],
      },
      {
        route: '/v1/admin/email/sending-history',
        method: 'GET',
        description:
          'Returns paginated sending history with timestamp/type/scope/outcome',
        states: ['pending', 'success', 'failure', 'reverted'],
      },
    ],
  };
});
