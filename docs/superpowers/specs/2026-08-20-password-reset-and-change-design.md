# Forgot Password & Change Password — Design

Date: 2026-08-20
Status: Approved for planning

## Overview

Two related, currently-missing password-management features for the admin web
app (`Web::BaseController` / cookie-session auth, distinct from the JWT-based
`Api::V1` admin auth):

1. **Forgot password** — an unauthenticated admin requests a 6-digit code by
   email, enters it, then sets a new password.
2. **Change password** — an authenticated admin changes their password from a
   dedicated page, given their current password.

Both flows share one password-strength rule and both end by emailing the
admin a "your password was changed" notice. Change-password additionally logs
the admin out immediately after a successful change.

No email delivery infrastructure exists yet ([`app/mailers/application_mailer.rb`](../../../app/mailers/application_mailer.rb)
is boilerplate, no SMTP configured). This spec adds SMTP wiring, driven by
`ENV`, with values left blank for the operator to fill in later.

## Password strength rule (shared)

New validator, applied to `Admin#password` only when a password is being set:

- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one digit
- At least one special (non-alphanumeric) character

`Admin` already uses `has_secure_password`, which provides `password_confirmation`
matching for free — this is what backs the "two password boxes must match"
requirement in both flows. No new column is needed for confirmation.

Implementation: `app/validators/strong_password_validator.rb`
(`ActiveModel::EachValidator`), regex-based:
`/\A(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}\z/`

Applied in `Admin`:
```ruby
validates :password, strong_password: true, if: -> { password.present? }
```

## Data model

New table `password_reset_codes`:

| column | type | notes |
|---|---|---|
| `id` | uuid | matches existing table conventions (see `admins`) |
| `admin_id` | uuid, FK | `belongs_to :admin` |
| `code_digest` | string | `BCrypt::Password.create(code)` — plaintext code is never stored |
| `expires_at` | datetime | request time + 10 minutes |
| `used_at` | datetime, nullable | set when the code is successfully verified |
| `created_at` / `updated_at` | datetime | |

Model `PasswordResetCode`:
- `belongs_to :admin`
- `self.generate_for(admin)` — deletes any existing rows for that admin, creates
  a new one with a random 6-digit code, returns `[record, plaintext_code]`
- `#expired?` → `expires_at.past?`
- `#matches?(code)` → `BCrypt::Password.new(code_digest) == code`

Only one active code exists per admin at a time (new request invalidates the
old one), matching the "keep it simple" answer on abuse limits — no attempt
counter, no throttle, just expiry + single-use.

## Forgot-password flow (3 pages, unauthenticated)

New `PasswordResetsController < Web::BaseController` (top-level, alongside
`SessionsController` — not under the `/admin` namespace, since the admin
isn't authenticated yet).

Routes (`config/routes.rb`, top-level near the existing `login`/`logout`):
```ruby
get   'forgot_password',        to: 'password_resets#new',     as: 'new_password_reset'
post  'forgot_password',        to: 'password_resets#create'
get   'forgot_password/verify', to: 'password_resets#verify',  as: 'verify_password_reset'
post  'forgot_password/verify', to: 'password_resets#confirm'
get   'forgot_password/edit',   to: 'password_resets#edit',    as: 'edit_password_reset'
patch 'forgot_password/edit',   to: 'password_resets#update'
```

**Step 1 — `new` / `create`:** email field. On submit, look up
`Admin.find_by(email: params[:email]&.downcase)`. If found, generate a code via
`PasswordResetCode.generate_for(admin)`, email it with `PasswordMailer.reset_code`,
and set `session[:password_reset_admin_id] = admin.id`. Regardless of whether
the admin was found, redirect to step 2 with the same generic flash: *"If that
email is registered, a code has been sent."* (Prevents account enumeration —
if the email wasn't found, `session[:password_reset_admin_id]` is simply never
set, so step 2 naturally rejects any code entered.)

**Step 2 — `verify` / `confirm`:** 6-digit code field. Requires
`session[:password_reset_admin_id]`; redirects to step 1 with an alert if
missing. On submit, load the admin's current `PasswordResetCode`
(`used_at: nil`, not expired); if it matches the entered code, mark
`used_at = Time.current` and set `session[:password_reset_verified] = true`,
then redirect to step 3. On mismatch or expiry, generic flash error, stay on
the page (no attempt counter, no lockout — matches the "no extra limits"
answer).

**Step 3 — `edit` / `update`:** guarded by both
`session[:password_reset_admin_id]` and `session[:password_reset_verified]`;
missing either redirects back to step 1. Two password fields (new + confirm).
On success: update the admin's password, send
`PasswordMailer.password_changed(admin)`, clear both session keys, redirect to
`login_path` with a success notice. On validation failure, re-render with
errors (mirrors the existing `form-errors` pattern used elsewhere in the app).

Login page (`app/views/sessions/new.html.erb`) gets a "Forgot password?" link
to `new_password_reset_path`.

## Change-password flow (authenticated, dedicated page)

New `Web::Admin::PasswordsController < Web::BaseController`, `before_action
:authenticate_admin!`, layout `'admin'`.

Route, inside the existing `namespace :admin do ... end` block:
```ruby
resource :password, only: %i[edit update], controller: 'passwords'
```
(→ `edit_admin_password_path` / `admin_password_path`)

Page: current password, new password, confirm new password. On submit:
1. If `current_admin.authenticate(params[:current_password])` fails → generic
   error ("Current password is incorrect"), re-render.
2. Otherwise update `password` / `password_confirmation` (strength + match
   validated via the shared validator / `has_secure_password`). On validation
   failure, re-render with errors.
3. On success: send `PasswordMailer.password_changed(current_admin)`, call
   `reset_session` (logs the admin out immediately, per requirement), redirect
   to `login_path` with a notice to sign back in.

Linked from `app/views/shared/_admin_header.html.erb`, next to the existing
Logout button in the header's account/actions area.

## Mailer

New `PasswordMailer < ApplicationMailer`:
- `reset_code(admin, code)` — subject "Your password reset code", body states
  the code and that it expires in 10 minutes.
- `password_changed(admin)` — subject "Your password was changed", informs the
  admin their password changed and to contact support if it wasn't them.

Both flows call `password_changed` on completion (forgot-password reset *and*
authenticated change), per the "notify on both" answer. Views under
`app/views/password_mailer/` (html + text), using the existing
`layouts/mailer.html.erb` / `.text.erb`.

## SMTP configuration

`config/initializers/mailer.rb` (applies to all environments except `test`,
which already forces `delivery_method = :test` in `config/environments/test.rb`
and loads after initializers, so it isn't affected):
```ruby
Rails.application.config.action_mailer.delivery_method = :smtp
Rails.application.config.action_mailer.smtp_settings = {
  address:             ENV['SMTP_ADDRESS'],
  port:                ENV.fetch('SMTP_PORT', 587).to_i,
  user_name:           ENV['SMTP_USERNAME'],
  password:            ENV['SMTP_PASSWORD'],
  domain:              ENV['SMTP_DOMAIN'],
  authentication:      'plain',
  enable_starttls_auto: true
}
Rails.application.config.action_mailer.default_url_options = {
  host: ENV.fetch('APP_HOST', 'localhost:3000')
}
```
`ApplicationMailer`'s `default from:` becomes `ENV.fetch('MAIL_FROM', 'from@example.com')`.
All values default to blank/placeholder — real credentials are supplied later
via the deploy environment, per the "leave it blank on ENV" answer.

## Error handling summary

- Unknown email at step 1 → same generic success message (no enumeration).
- Wrong/expired code at step 2 → generic error, resend available by going back
  to step 1 (which invalidates any prior code).
- Skipping steps by direct URL access → redirected back to the appropriate
  earlier step with an alert.
- Wrong current password on change-password → generic error, no lockout.
- Weak password / mismatched confirmation on either flow → standard Rails
  validation errors rendered via the existing `.form-errors` styling.

## Testing

- Model: `PasswordResetCode.generate_for` (invalidates prior codes, expiry
  math), `StrongPasswordValidator` (accepts/rejects boundary cases).
- Request specs: full happy path for both flows; wrong code; expired code;
  skipping steps; wrong current password; weak/mismatched new password;
  session is reset after change-password.
- Mailer specs: `PasswordMailer` renders expected subject/body for both
  actions (using `ActionMailer::Base.deliveries` in test env).
