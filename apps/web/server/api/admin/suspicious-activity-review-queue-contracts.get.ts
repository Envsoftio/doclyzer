export default defineEventHandler(() => {
  return {
    story: '5-9-suspicious-activity-detection-and-review-queue',
    status: 'stub',
    endpoints: [
      {
        route: '/v1/admin/risk/suspicious-activity',
        method: 'POST',
        description:
          'Ingests suspicious activity signals and creates or dedupes review queue items with severity and status',
        states: ['pending', 'success', 'failure', 'reverted'],
      },
      {
        route: '/v1/admin/risk/suspicious-activity',
        method: 'GET',
        description:
          'Lists suspicious activity review queue items with filtering by status, severity, and target scope',
        states: ['pending', 'success', 'failure', 'reverted'],
      },
      {
        route: '/v1/admin/risk/suspicious-activity/:queueItemId/status',
        method: 'PATCH',
        description:
          'Updates suspicious activity queue item triage status with constrained transitions and audit trail metadata',
        states: ['pending', 'success', 'failure', 'reverted'],
      },
    ],
  };
});
