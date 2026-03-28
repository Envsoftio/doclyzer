export default defineEventHandler(() => {
  return {
    story: '5-2-plan-definition-and-limit-configuration-management',
    status: 'stub',
    endpoints: [
      {
        route: '/v1/entitlements/admin/plan-configs',
        method: 'GET',
        description: 'Lists current plan definitions with config versions',
        states: ['pending', 'success', 'failure', 'reverted'],
      },
      {
        route: '/v1/entitlements/admin/plan-configs/:planId',
        method: 'PUT',
        description:
          'Validates and updates plan limits using optimistic config version checks',
        states: ['pending', 'success', 'failure', 'reverted'],
      },
    ],
  };
});
