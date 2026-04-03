# Email templates

Templates for the email pipeline (Story 6.6). Variables use Handlebars-style `{{variable}}` placeholders.

| Template           | Variables |
|--------------------|-----------|
| `welcome.html`     | `userName`, `loginUrl`, `supportUrl` |
| `verify-email.html`| `userName`, `verifyLink`, `expiryMinutes` |
| `otp.html`        | `otpCode`, `expiryMinutes`, `purpose` |
| `password-reset.html` | `resetLink`, `expiryMinutes` |
| `account-email-changed.html` | _(no variables)_ |
| `account-password-changed.html` | _(no variables)_ |
| `account-closure-confirmed.html` | _(no variables)_ |
| `report-upload-complete.html` | _(no variables)_ |
| `report-parse-failed.html` | _(no variables)_ |
| `billing-payment-success.html` | _(no variables)_ |
| `billing-payment-failed.html` | _(no variables)_ |
| `billing-subscription-activated.html` | _(no variables)_ |
| `billing-subscription-cancelled.html` | _(no variables)_ |
| `admin-announcement.html` | _(no variables)_ |
| `admin-incident.html` | _(no variables)_ |
| `admin-support.html` | _(no variables)_ |

Render with a safe HTML escape for all variables to avoid injection. Use plain-text fallbacks for clients that don’t support HTML.
