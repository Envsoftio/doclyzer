# Email templates

Templates for the email pipeline (Story 6.6) use `.hbs` files with Handlebars-style `{{variable}}` placeholders.

Each message template is rendered as body content and inserted into `layouts/default.hbs`. The shared layout includes `partials/email-header.hbs` and `partials/email-footer.hbs`, so individual templates only need the email-specific content.

| Template | Variables |
| --- | --- |
| `welcome.hbs` | `userName`, `loginUrl`, `supportUrl` |
| `verify-email.hbs` | `userName`, `verifyLink`, `expiryMinutes` |
| `otp.hbs` | `otpCode`, `expiryMinutes`, `purpose` |
| `password-reset.hbs` | `resetLink`, `expiryMinutes` |
| `account-email-changed.hbs` | _(no variables)_ |
| `account-password-changed.hbs` | _(no variables)_ |
| `account-closure-confirmed.hbs` | _(no variables)_ |
| `report-upload-complete.hbs` | _(no variables)_ |
| `report-parse-failed.hbs` | _(no variables)_ |
| `billing-payment-success.hbs` | _(no variables)_ |
| `billing-payment-failed.hbs` | _(no variables)_ |
| `billing-ops-alert.hbs` | _(no variables)_ |
| `billing-subscription-activated.hbs` | _(no variables)_ |
| `billing-subscription-cancelled.hbs` | _(no variables)_ |
| `admin-announcement.hbs` | _(no variables)_ |
| `admin-incident.hbs` | _(no variables)_ |
| `admin-support.hbs` | _(no variables)_ |

Variables are HTML-escaped by default to avoid injection. Use triple-stache only for trusted layout slots such as `{{{content}}}`.

Default template variables are provided by `EmailTemplateService`: `brandName`, `previewText`, `supportUrl`, and `currentYear`.
