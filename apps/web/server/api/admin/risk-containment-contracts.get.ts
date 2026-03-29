export default defineEventHandler(() => {
  return {
    story: '5-10-share-link-account-suspension-and-restore-controls',
    status: 'stub',
    endpoints: [
      {
        route: '/v1/admin/risk-controls/share-links/:shareLinkId/suspension',
        method: 'PATCH',
        description:
          'Suspends or restores recipient access for a share link with auditable superadmin intent.',
        states: ['pending', 'success', 'failure', 'reverted'],
      },
      {
        route: '/v1/admin/risk-controls/accounts/:userId/suspension',
        method: 'PATCH',
        description:
          'Suspends or restores protected account actions and records governance-safe audit evidence.',
        states: ['pending', 'success', 'failure', 'reverted'],
      },
    ],
  };
});
