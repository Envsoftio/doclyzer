export default defineEventHandler(() => {
  return {
    story: '5-1-superadmin-authentication-hardening-mfa-role-guard-baseline',
    status: 'stub',
    endpoints: [
      {
        route: '/v1/auth/superadmin/elevation/challenge',
        method: 'POST',
        description: 'Starts or reuses MFA challenge for privilege elevation',
        states: ['pending', 'success', 'failure', 'reverted'],
      },
      {
        route: '/v1/auth/superadmin/elevation/verify',
        method: 'POST',
        description: 'Verifies MFA code and sets trust window',
        states: ['pending', 'success', 'failure', 'reverted'],
      },
      {
        route: '/v1/auth/superadmin/elevation/token',
        method: 'POST',
        description:
          'Issues admin action token only after successful MFA challenge',
        states: ['pending', 'success', 'failure', 'reverted'],
      },
    ],
  };
});
