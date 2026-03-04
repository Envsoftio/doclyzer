import { AuthService } from './auth.service';

describe('AuthService', () => {
  let service: AuthService;

  beforeEach(() => {
    service = new AuthService();
  });

  it('hashes passwords and verifies them', async () => {
    const hash = await service.hashPassword('StrongPass123!');

    expect(hash).not.toBe('StrongPass123!');
    await expect(service.verifyPassword('StrongPass123!', hash)).resolves.toBe(
      true,
    );
    await expect(service.verifyPassword('wrong', hash)).resolves.toBe(false);
  });

  it('issues and revokes login sessions', async () => {
    await service.register({
      email: 'unit@example.com',
      password: 'StrongPass123!',
      policyAccepted: true,
    });

    const login = await service.login({
      email: 'unit@example.com',
      password: 'StrongPass123!',
    });

    expect(login.accessToken).toBeTruthy();
    expect(login.refreshToken).toBeTruthy();

    await service.logout(login.accessToken);
    await expect(service.logout(login.accessToken)).rejects.toThrow();
  });

  it('requires policy acceptance to register', async () => {
    await expect(
      service.register({
        email: 'policy@example.com',
        password: 'StrongPass123!',
        policyAccepted: false,
      }),
    ).rejects.toThrow();
  });
});
