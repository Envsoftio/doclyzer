# Email templates

Templates for the email pipeline (Story 6.6). Variables use Handlebars-style `{{variable}}` placeholders.

| Template           | Variables |
|--------------------|-----------|
| `welcome.html`     | `userName`, `loginUrl`, `supportUrl` |
| `verify-email.html`| `userName`, `verifyLink`, `expiryMinutes` |
| `otp.html`        | `otpCode`, `expiryMinutes`, `purpose` |
| `password-reset.html` | `resetLink`, `expiryMinutes` |

Render with a safe HTML escape for all variables to avoid injection. Use plain-text fallbacks for clients that don’t support HTML.
