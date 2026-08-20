# Forgot Password & Change Password Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a 3-step email-code forgot-password flow for logged-out admins and a dedicated change-password page for authenticated admins, both enforcing one shared password-strength rule and both emailing the admin a change notification.

**Architecture:** A `PasswordResetCode` model (BCrypt-hashed 6-digit code, 10-minute expiry, single active code per admin) backs the unauthenticated flow, driven through Rails session state across three pages/controller actions. A shared `StrongPasswordValidator` is applied to `Admin#password` so both flows enforce identical strength rules via `has_secure_password`'s existing confirmation support. A new `PasswordMailer` sends the code and the "password changed" notice; SMTP is wired via `ENV`, left blank for the operator to fill in.

**Tech Stack:** Rails 6.1, RSpec + FactoryBot + shoulda-matchers (existing test stack), PostgreSQL (uuid PKs via `pgcrypto`), `has_secure_password` (bcrypt), ActionMailer (SMTP).

**Spec:** `docs/superpowers/specs/2026-08-20-password-reset-and-change-design.md`

## Global Constraints

- Password strength regex (applies everywhere a password is set): `/\A(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}\z/` — min 8 chars, ≥1 uppercase, ≥1 lowercase, ≥1 digit, ≥1 special character.
- Reset codes: 6 digits, expire in 10 minutes, single-use, only one active code per admin at a time. No attempt counter, no request throttling (explicitly out of scope per spec).
- Unknown email at the forgot-password step must show the exact same response as a known email (no account enumeration).
- Both the forgot-password reset and the authenticated change-password flow must send the "password changed" notification email on success.
- Change-password must call `reset_session` after a successful change and redirect to `login_path`.
- SMTP settings (`SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_DOMAIN`, `MAIL_FROM`, `APP_HOST`) are read from `ENV` with safe defaults/blanks — no real credentials are committed.

**Deviation from spec:** the spec names `config/initializers/mailer.rb` for SMTP config. Rails loads `config/environments/<env>.rb` **before** `config/initializers/*.rb`, so an initializer setting `delivery_method = :smtp` would run after — and override — `test.rb`'s `delivery_method = :test`, breaking `ActionMailer::Base.deliveries` in specs. Task 3 instead adds the SMTP block directly to `config/environments/development.rb` and `config/environments/production.rb`, which matches how `action_mailer` is already configured in this codebase and leaves `test.rb` untouched. Behavior and intent are unchanged.

---

## File Structure

- `app/validators/strong_password_validator.rb` — new, the shared strength rule.
- `app/models/admin.rb` — modified, applies the validator.
- `spec/factories/admins.rb`, `spec/requests/api/v1/sessions_spec.rb` — modified, factory password updated to satisfy the new rule.
- `db/migrate/20260820120000_create_password_reset_codes.rb`, `app/models/password_reset_code.rb` — new, the reset-code model.
- `app/mailers/application_mailer.rb`, `app/mailers/password_mailer.rb`, `app/views/password_mailer/*.erb` — new/modified, email sending.
- `config/environments/development.rb`, `config/environments/production.rb` — modified, SMTP wiring.
- `spec/rails_helper.rb` — modified, clears `ActionMailer::Base.deliveries` between examples.
- `config/routes.rb` — modified, new routes for both flows.
- `app/controllers/password_resets_controller.rb`, `app/views/password_resets/{new,verify,edit}.html.erb` — new, forgot-password flow.
- `app/views/sessions/new.html.erb`, `app/assets/stylesheets/sessions.scss` — modified, "Forgot password?" link + shared page styling.
- `app/controllers/web/admin/passwords_controller.rb`, `app/views/web/admin/passwords/edit.html.erb` — new, change-password flow.
- `app/views/shared/_admin_header.html.erb` — modified, "Change password" link.

---

### Task 1: Shared password-strength validator

**Files:**
- Create: `app/validators/strong_password_validator.rb`
- Modify: `app/models/admin.rb`
- Modify: `spec/factories/admins.rb`
- Modify: `spec/requests/api/v1/sessions_spec.rb`
- Test: `spec/validators/strong_password_validator_spec.rb`

**Interfaces:**
- Produces: `StrongPasswordValidator` (an `ActiveModel::EachValidator`), usable as `validates :password, strong_password: true`. `Admin` now rejects a weak `password` whenever one is set.
- Consumes: nothing (first task).

- [ ] **Step 1: Write the failing validator spec**

Create `spec/validators/strong_password_validator_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe StrongPasswordValidator do
  let(:admin) { build(:admin) }

  it "accepts a password with upper, lower, digit, and special char" do
    admin.password = admin.password_confirmation = "Password123!"
    expect(admin).to be_valid
  end

  it "rejects a password shorter than 8 characters" do
    admin.password = admin.password_confirmation = "P1a!bcd"
    expect(admin).not_to be_valid
    expect(admin.errors[:password]).to be_present
  end

  it "rejects a password missing an uppercase letter" do
    admin.password = admin.password_confirmation = "password123!"
    expect(admin).not_to be_valid
  end

  it "rejects a password missing a lowercase letter" do
    admin.password = admin.password_confirmation = "PASSWORD123!"
    expect(admin).not_to be_valid
  end

  it "rejects a password missing a digit" do
    admin.password = admin.password_confirmation = "Password!!"
    expect(admin).not_to be_valid
  end

  it "rejects a password missing a special character" do
    admin.password = admin.password_confirmation = "Password123"
    expect(admin).not_to be_valid
  end
end
```

- [ ] **Step 2: Run the spec and confirm it fails**

Run: `bundle exec rspec spec/validators/strong_password_validator_spec.rb`
Expected: the four "rejects ..." examples FAIL (admin is currently valid with any password) — this proves the rule isn't enforced yet. The "accepts" example passes trivially.

- [ ] **Step 3: Create the validator**

Create `app/validators/strong_password_validator.rb`:

```ruby
class StrongPasswordValidator < ActiveModel::EachValidator
  FORMAT = /\A(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}\z/

  def validate_each(record, attribute, value)
    return if value.blank?

    return if value.match?(FORMAT)

    record.errors.add(
      attribute,
      'must be at least 8 characters and include an uppercase letter, a lowercase letter, a number, and a special character'
    )
  end
end
```

- [ ] **Step 4: Apply the validator to `Admin`**

Modify `app/models/admin.rb`:

```ruby
class Admin < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, strong_password: true, if: -> { password.present? }
  before_save { email.downcase! }
end
```

- [ ] **Step 5: Run the validator spec and confirm it passes**

Run: `bundle exec rspec spec/validators/strong_password_validator_spec.rb`
Expected: all 6 examples PASS.

- [ ] **Step 6: Fix the now-broken factory default**

The existing factory default password `"password123"` no longer satisfies the rule, which will break every spec using `create(:admin)`/`build(:admin)` without an explicit password. Modify `spec/factories/admins.rb`:

```ruby
FactoryBot.define do
  factory :admin do
    sequence(:email) { |n| "admin#{n}@example.com" }
    password { "Password123!" }
    password_confirmation { "Password123!" }
  end
end
```

- [ ] **Step 7: Fix the hardcoded password in the existing sessions request spec**

Modify `spec/requests/api/v1/sessions_spec.rb` — replace both occurrences of `"password123"` (the `create(:admin, ...)` call and the matching login `params:`) with `"Password123!"`. Leave the `"wrong"` and `"nobody@example.com"` cases untouched.

- [ ] **Step 8: Run the full suite and confirm nothing else broke**

Run: `bundle exec rspec`
Expected: all examples PASS (in particular `spec/models/admin_spec.rb` and `spec/requests/api/v1/sessions_spec.rb`).

- [ ] **Step 9: Commit**

```bash
git add app/validators/strong_password_validator.rb app/models/admin.rb \
  spec/validators/strong_password_validator_spec.rb spec/factories/admins.rb \
  spec/requests/api/v1/sessions_spec.rb
git commit -m "Add shared strong-password validator and apply it to Admin"
```

---

### Task 2: `PasswordResetCode` model

**Files:**
- Create: `db/migrate/20260820120000_create_password_reset_codes.rb`
- Create: `app/models/password_reset_code.rb`
- Test: `spec/models/password_reset_code_spec.rb`

**Interfaces:**
- Consumes: `Admin` (from Task 1, unchanged interface — `belongs_to :admin`).
- Produces: `PasswordResetCode.generate_for(admin) -> [PasswordResetCode, String]` (record + plaintext 6-digit code), `#expired? -> Boolean`, `#matches?(code_string) -> Boolean`. `admin_id`, `used_at`, `expires_at`, `created_at` columns.

- [ ] **Step 1: Write the failing model spec**

Create `spec/models/password_reset_code_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe PasswordResetCode, type: :model do
  let(:admin) { create(:admin) }

  describe ".generate_for" do
    it "creates a 6-digit code with a 10-minute expiry" do
      record, code = PasswordResetCode.generate_for(admin)

      expect(code).to match(/\A\d{6}\z/)
      expect(record.admin).to eq(admin)
      expect(record.expires_at).to be_within(1.second).of(10.minutes.from_now)
      expect(record.matches?(code)).to be true
    end

    it "invalidates any previously generated code for the same admin" do
      first_record, = PasswordResetCode.generate_for(admin)

      PasswordResetCode.generate_for(admin)

      expect(PasswordResetCode.exists?(first_record.id)).to be false
    end
  end

  describe "#expired?" do
    it "is true once expires_at has passed" do
      record, = PasswordResetCode.generate_for(admin)
      record.update!(expires_at: 1.minute.ago)

      expect(record).to be_expired
    end

    it "is false while still within the expiry window" do
      record, = PasswordResetCode.generate_for(admin)

      expect(record).not_to be_expired
    end
  end

  describe "#matches?" do
    it "returns false for an incorrect code" do
      _record, code = PasswordResetCode.generate_for(admin)
      wrong_code = code == "000000" ? "111111" : "000000"

      record = PasswordResetCode.last
      expect(record.matches?(wrong_code)).to be false
    end
  end
end
```

- [ ] **Step 2: Run the spec and confirm it fails**

Run: `bundle exec rspec spec/models/password_reset_code_spec.rb`
Expected: FAIL with `uninitialized constant PasswordResetCode`.

- [ ] **Step 3: Create the migration**

Create `db/migrate/20260820120000_create_password_reset_codes.rb`:

```ruby
class CreatePasswordResetCodes < ActiveRecord::Migration[6.1]
  def change
    create_table :password_reset_codes, id: :uuid do |t|
      t.references :admin, null: false, type: :uuid, foreign_key: true
      t.string :code_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :used_at

      t.timestamps
    end
  end
end
```

- [ ] **Step 4: Run the migration**

Run: `bin/rails db:migrate`
Expected: migration runs, `db/schema.rb` gains the `password_reset_codes` table and its version bumps.

- [ ] **Step 5: Create the model**

Create `app/models/password_reset_code.rb`:

```ruby
class PasswordResetCode < ApplicationRecord
  belongs_to :admin

  CODE_LENGTH = 6
  EXPIRY = 10.minutes

  def self.generate_for(admin)
    where(admin: admin).delete_all

    code = Array.new(CODE_LENGTH) { rand(10) }.join
    record = create!(
      admin: admin,
      code_digest: BCrypt::Password.create(code),
      expires_at: EXPIRY.from_now
    )

    [record, code]
  end

  def expired?
    expires_at.past?
  end

  def matches?(code)
    BCrypt::Password.new(code_digest) == code.to_s
  end
end
```

- [ ] **Step 6: Run the spec and confirm it passes**

Run: `bundle exec rspec spec/models/password_reset_code_spec.rb`
Expected: all 5 examples PASS.

- [ ] **Step 7: Commit**

```bash
git add db/migrate/20260820120000_create_password_reset_codes.rb db/schema.rb \
  app/models/password_reset_code.rb spec/models/password_reset_code_spec.rb
git commit -m "Add PasswordResetCode model for the forgot-password flow"
```

---

### Task 3: `PasswordMailer` and SMTP configuration

**Files:**
- Modify: `app/mailers/application_mailer.rb`
- Create: `app/mailers/password_mailer.rb`
- Create: `app/views/password_mailer/reset_code.html.erb`
- Create: `app/views/password_mailer/reset_code.text.erb`
- Create: `app/views/password_mailer/password_changed.html.erb`
- Create: `app/views/password_mailer/password_changed.text.erb`
- Modify: `config/environments/development.rb`
- Modify: `config/environments/production.rb`
- Modify: `spec/rails_helper.rb`
- Test: `spec/mailers/password_mailer_spec.rb`

**Interfaces:**
- Consumes: `Admin#email` (existing).
- Produces: `PasswordMailer.reset_code(admin, code).deliver_now`, `PasswordMailer.password_changed(admin).deliver_now`.

- [ ] **Step 1: Write the failing mailer spec**

Create `spec/mailers/password_mailer_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe PasswordMailer, type: :mailer do
  let(:admin) { create(:admin, email: 'admin@example.com') }

  describe "#reset_code" do
    let(:mail) { PasswordMailer.reset_code(admin, '123456') }

    it "renders the subject and recipient" do
      expect(mail.subject).to eq('Your password reset code')
      expect(mail.to).to eq(['admin@example.com'])
    end

    it "includes the code in the body" do
      expect(mail.body.encoded).to include('123456')
    end
  end

  describe "#password_changed" do
    let(:mail) { PasswordMailer.password_changed(admin) }

    it "renders the subject and recipient" do
      expect(mail.subject).to eq('Your password was changed')
      expect(mail.to).to eq(['admin@example.com'])
    end
  end
end
```

- [ ] **Step 2: Run the spec and confirm it fails**

Run: `bundle exec rspec spec/mailers/password_mailer_spec.rb`
Expected: FAIL with `uninitialized constant PasswordMailer`.

- [ ] **Step 3: Update `ApplicationMailer`'s default sender**

Modify `app/mailers/application_mailer.rb`:

```ruby
class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAIL_FROM', 'from@example.com')
  layout 'mailer'
end
```

- [ ] **Step 4: Create `PasswordMailer`**

Create `app/mailers/password_mailer.rb`:

```ruby
class PasswordMailer < ApplicationMailer
  def reset_code(admin, code)
    @admin = admin
    @code = code
    mail(to: @admin.email, subject: 'Your password reset code')
  end

  def password_changed(admin)
    @admin = admin
    mail(to: @admin.email, subject: 'Your password was changed')
  end
end
```

- [ ] **Step 5: Create the mailer views**

Create `app/views/password_mailer/reset_code.html.erb`:

```erb
<p>Hi <%= @admin.email %>,</p>
<p>Use this code to reset your password. It expires in 10 minutes.</p>
<p style="font-size: 24px; font-weight: bold; letter-spacing: 4px;"><%= @code %></p>
<p>If you didn't request this, you can safely ignore this email.</p>
```

Create `app/views/password_mailer/reset_code.text.erb`:

```erb
Hi <%= @admin.email %>,

Use this code to reset your password. It expires in 10 minutes.

<%= @code %>

If you didn't request this, you can safely ignore this email.
```

Create `app/views/password_mailer/password_changed.html.erb`:

```erb
<p>Hi <%= @admin.email %>,</p>
<p>Your password was just changed. If this wasn't you, please contact support immediately.</p>
```

Create `app/views/password_mailer/password_changed.text.erb`:

```erb
Hi <%= @admin.email %>,

Your password was just changed. If this wasn't you, please contact support immediately.
```

- [ ] **Step 6: Clear `ActionMailer::Base.deliveries` between examples**

Modify `spec/rails_helper.rb` — add inside the existing `RSpec.configure do |config| ... end` block (near `config.include FactoryBot::Syntax::Methods`):

```ruby
  config.after { ActionMailer::Base.deliveries.clear }
```

- [ ] **Step 7: Run the spec and confirm it passes**

Run: `bundle exec rspec spec/mailers/password_mailer_spec.rb`
Expected: all 3 examples PASS.

- [ ] **Step 8: Wire SMTP via ENV in development and production**

Modify `config/environments/development.rb` — add directly after the existing `config.action_mailer.perform_caching = false` line:

```ruby
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: ENV['SMTP_ADDRESS'],
    port: ENV.fetch('SMTP_PORT', 587).to_i,
    user_name: ENV['SMTP_USERNAME'],
    password: ENV['SMTP_PASSWORD'],
    domain: ENV['SMTP_DOMAIN'],
    authentication: 'plain',
    enable_starttls_auto: true
  }
  config.action_mailer.default_url_options = { host: ENV.fetch('APP_HOST', 'localhost:3000') }
```

Modify `config/environments/production.rb` — add directly after its `config.action_mailer.perform_caching = false` line:

```ruby
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: ENV['SMTP_ADDRESS'],
    port: ENV.fetch('SMTP_PORT', 587).to_i,
    user_name: ENV['SMTP_USERNAME'],
    password: ENV['SMTP_PASSWORD'],
    domain: ENV['SMTP_DOMAIN'],
    authentication: 'plain',
    enable_starttls_auto: true
  }
  config.action_mailer.default_url_options = { host: ENV.fetch('APP_HOST', 'example.com') }
```

- [ ] **Step 9: Verify environment loading order didn't break test delivery**

Run: `RAILS_ENV=test bin/rails runner "puts Rails.application.config.action_mailer.delivery_method"`
Expected: prints `test` (unaffected by the new SMTP block, since it's not present in `test.rb`).

Run: `RAILS_ENV=development bin/rails runner "puts Rails.application.config.action_mailer.delivery_method"`
Expected: prints `smtp`.

- [ ] **Step 10: Run the full suite**

Run: `bundle exec rspec`
Expected: all examples PASS.

- [ ] **Step 11: Commit**

```bash
git add app/mailers/application_mailer.rb app/mailers/password_mailer.rb \
  app/views/password_mailer/ config/environments/development.rb \
  config/environments/production.rb spec/rails_helper.rb \
  spec/mailers/password_mailer_spec.rb
git commit -m "Add PasswordMailer and wire SMTP delivery via ENV"
```

---

### Task 4: Forgot-password flow (unauthenticated, 3 steps)

**Files:**
- Modify: `config/routes.rb`
- Create: `app/controllers/password_resets_controller.rb`
- Create: `app/views/password_resets/new.html.erb`
- Create: `app/views/password_resets/verify.html.erb`
- Create: `app/views/password_resets/edit.html.erb`
- Modify: `app/views/sessions/new.html.erb`
- Modify: `app/assets/stylesheets/sessions.scss`
- Test: `spec/requests/password_resets_spec.rb`

**Interfaces:**
- Consumes: `PasswordResetCode.generate_for/expired?/matches?` (Task 2), `PasswordMailer.reset_code/password_changed` (Task 3), `Admin` strength validation (Task 1), `Web::BaseController#session`/`current_admin` (existing).
- Produces: routes `new_password_reset_path` (GET/POST `/forgot_password`), `verify_password_reset_path` (GET/POST `/forgot_password/verify`), `edit_password_reset_path` (GET/PATCH `/forgot_password/edit`).

- [ ] **Step 1: Write the failing request spec**

Create `spec/requests/password_resets_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe "PasswordResets", type: :request do
  let!(:admin) { create(:admin, email: "admin@example.com", password: "Password123!") }

  def sent_code
    ActionMailer::Base.deliveries.last.text_part.body.to_s[/\d{6}/]
  end

  describe "POST /forgot_password" do
    it "sends a reset code when the email is registered" do
      expect {
        post "/forgot_password", params: { email: "admin@example.com" }
      }.to change { PasswordResetCode.where(admin: admin).count }.by(1)

      expect(ActionMailer::Base.deliveries.last.to).to eq(["admin@example.com"])
      expect(response).to redirect_to(verify_password_reset_path)
    end

    it "shows the same generic message for an unknown email" do
      post "/forgot_password", params: { email: "nobody@example.com" }

      expect(response).to redirect_to(verify_password_reset_path)
      follow_redirect!
      expect(response.body).to include("If that email is registered")
    end
  end

  describe "POST /forgot_password/verify" do
    it "redirects to the start if no reset was requested" do
      post "/forgot_password/verify", params: { code: "123456" }

      expect(response).to redirect_to(new_password_reset_path)
    end

    it "accepts a valid code and advances to the password step" do
      post "/forgot_password", params: { email: "admin@example.com" }

      post "/forgot_password/verify", params: { code: sent_code }

      expect(response).to redirect_to(edit_password_reset_path)
    end

    it "rejects an incorrect code" do
      post "/forgot_password", params: { email: "admin@example.com" }

      post "/forgot_password/verify", params: { code: "000000" }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /forgot_password/edit" do
    def complete_up_to_verified
      post "/forgot_password", params: { email: "admin@example.com" }
      post "/forgot_password/verify", params: { code: sent_code }
    end

    it "redirects to the start if the code hasn't been verified" do
      patch "/forgot_password/edit", params: { admin: { password: "NewPassword123!", password_confirmation: "NewPassword123!" } }

      expect(response).to redirect_to(new_password_reset_path)
    end

    it "resets the password, notifies the admin, and sends them to login" do
      complete_up_to_verified

      patch "/forgot_password/edit", params: { admin: { password: "NewPassword123!", password_confirmation: "NewPassword123!" } }

      expect(response).to redirect_to(login_path)
      expect(admin.reload.authenticate("NewPassword123!")).to be_truthy
      expect(ActionMailer::Base.deliveries.last.subject).to eq("Your password was changed")
    end

    it "re-renders with errors for a weak password" do
      complete_up_to_verified

      patch "/forgot_password/edit", params: { admin: { password: "weak", password_confirmation: "weak" } }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
```

- [ ] **Step 2: Run the spec and confirm it fails**

Run: `bundle exec rspec spec/requests/password_resets_spec.rb`
Expected: FAIL with routing errors (`forgot_password` routes don't exist yet).

- [ ] **Step 3: Add the routes**

Modify `config/routes.rb` — insert directly after the existing `delete 'logout', to: 'sessions#destroy'` line:

```ruby
  get   'forgot_password',        to: 'password_resets#new',     as: 'new_password_reset'
  post  'forgot_password',        to: 'password_resets#create'
  get   'forgot_password/verify', to: 'password_resets#verify',  as: 'verify_password_reset'
  post  'forgot_password/verify', to: 'password_resets#confirm'
  get   'forgot_password/edit',   to: 'password_resets#edit',    as: 'edit_password_reset'
  patch 'forgot_password/edit',   to: 'password_resets#update'
```

- [ ] **Step 4: Create the controller**

Create `app/controllers/password_resets_controller.rb`:

```ruby
class PasswordResetsController < Web::BaseController
  before_action :require_reset_admin, only: %i[verify confirm]
  before_action :require_verified_reset, only: %i[edit update]

  def new; end

  def create
    admin = ::Admin.find_by(email: params[:email]&.downcase)

    if admin
      _record, code = PasswordResetCode.generate_for(admin)
      PasswordMailer.reset_code(admin, code).deliver_now
      session[:password_reset_admin_id] = admin.id
    end

    redirect_to verify_password_reset_path, notice: 'If that email is registered, a code has been sent.'
  end

  def verify; end

  def confirm
    reset_code = current_reset_code

    if reset_code && !reset_code.expired? && reset_code.matches?(params[:code])
      reset_code.update!(used_at: Time.current)
      session[:password_reset_verified] = true
      redirect_to edit_password_reset_path
    else
      flash.now[:alert] = 'That code is invalid or has expired.'
      render :verify, status: :unprocessable_entity
    end
  end

  def edit
    @admin = reset_admin
  end

  def update
    @admin = reset_admin

    if @admin.update(password_params)
      PasswordMailer.password_changed(@admin).deliver_now
      session.delete(:password_reset_admin_id)
      session.delete(:password_reset_verified)
      redirect_to login_path, notice: 'Password reset successfully. Please sign in.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def reset_admin
    ::Admin.find(session[:password_reset_admin_id])
  end

  def current_reset_code
    PasswordResetCode.where(admin_id: session[:password_reset_admin_id], used_at: nil)
                      .order(created_at: :desc)
                      .first
  end

  def require_reset_admin
    return if session[:password_reset_admin_id]

    redirect_to new_password_reset_path, alert: 'Please request a new code.'
  end

  def require_verified_reset
    return if session[:password_reset_admin_id] && session[:password_reset_verified]

    redirect_to new_password_reset_path, alert: 'Please verify your code first.'
  end

  def password_params
    params.require(:admin).permit(:password, :password_confirmation)
  end
end
```

- [ ] **Step 5: Create the views**

Create `app/views/password_resets/new.html.erb`:

```erb
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Portfolio API — Forgot Password</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
  <%= stylesheet_link_tag 'sessions', media: 'all' %>
</head>
<body style="background-color: #000";>
  <div class="wrap">
    <%= image_tag 'logo.png', alt: '', class: 'login-logo' %>
    <h1>Forgot Password</h1>
    <p class="subtitle">Enter your admin email to receive a reset code</p>

    <% if flash[:alert] %>
      <div class="result error"><%= flash[:alert] %></div>
    <% end %>
    <% if flash[:notice] %>
      <div class="result ok"><%= flash[:notice] %></div>
    <% end %>

    <%= form_tag new_password_reset_path, method: :post do %>
      <label for="email">Email</label>
      <%= email_field_tag :email, nil, id: 'email', required: true, autocomplete: 'username' %>

      <%= submit_tag 'Send reset code', class: 'primary full-width' %>
    <% end %>

    <p class="form-links"><%= link_to 'Back to login', login_path %></p>
  </div>
</body>
</html>
```

Create `app/views/password_resets/verify.html.erb`:

```erb
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Portfolio API — Verify Code</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
  <%= stylesheet_link_tag 'sessions', media: 'all' %>
</head>
<body style="background-color: #000";>
  <div class="wrap">
    <%= image_tag 'logo.png', alt: '', class: 'login-logo' %>
    <h1>Enter Code</h1>
    <p class="subtitle">Enter the 6-digit code we emailed you</p>

    <% if flash[:alert] %>
      <div class="result error"><%= flash[:alert] %></div>
    <% end %>
    <% if flash[:notice] %>
      <div class="result ok"><%= flash[:notice] %></div>
    <% end %>

    <%= form_tag verify_password_reset_path, method: :post do %>
      <label for="code">Code</label>
      <%= text_field_tag :code, nil, id: 'code', required: true, autocomplete: 'one-time-code', inputmode: 'numeric', maxlength: 6 %>

      <%= submit_tag 'Verify code', class: 'primary full-width' %>
    <% end %>

    <p class="form-links"><%= link_to 'Start over', new_password_reset_path %></p>
  </div>
</body>
</html>
```

Create `app/views/password_resets/edit.html.erb`:

```erb
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Portfolio API — Reset Password</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
  <%= stylesheet_link_tag 'sessions', media: 'all' %>
</head>
<body style="background-color: #000";>
  <div class="wrap">
    <%= image_tag 'logo.png', alt: '', class: 'login-logo' %>
    <h1>Set New Password</h1>
    <p class="subtitle">Min 8 characters, with upper, lower, number, and special character</p>

    <% if @admin.errors.any? %>
      <div class="result error">
        <ul>
          <% @admin.errors.full_messages.each do |m| %>
            <li><%= m %></li>
          <% end %>
        </ul>
      </div>
    <% end %>

    <%= form_with model: @admin, url: edit_password_reset_path, method: :patch, local: true do |f| %>
      <label for="admin_password">New password</label>
      <%= f.password_field :password, id: 'admin_password', required: true, autocomplete: 'new-password' %>

      <label for="admin_password_confirmation">Confirm new password</label>
      <%= f.password_field :password_confirmation, id: 'admin_password_confirmation', required: true, autocomplete: 'new-password' %>

      <%= f.submit 'Reset password', class: 'primary full-width' %>
    <% end %>
  </div>
</body>
</html>
```

- [ ] **Step 6: Style the code input and the back-links**

Modify `app/assets/stylesheets/sessions.scss` — extend the existing input selector to include the text code field, and add link styling:

```scss
.wrap input[type="email"],
.wrap input[type="password"],
.wrap input[type="text"] {
  width: 100%;
  padding: 10px;
  border: 1px solid var(--line-strong);
  border-radius: var(--radius);
  margin-top: 6px;
  font-family: inherit;
  font-size: 15px;
  background: var(--ink);
  color: var(--text);
}
.wrap input[type="email"]:focus,
.wrap input[type="password"]:focus,
.wrap input[type="text"]:focus { outline: 2px solid var(--accent); outline-offset: 1px }

.wrap .form-links { margin-top: 16px; font-size: 13px; text-align: center }
.wrap .form-links a { color: var(--accent) }
```

Replace the existing (now-duplicate) `.wrap input[type="email"], .wrap input[type="password"]` block and its `:focus` block further up the file with these two, rather than keeping both — there should be exactly one rule per selector group.

- [ ] **Step 7: Add the "Forgot password?" link to the login page**

Modify `app/views/sessions/new.html.erb` — after the closing `<% end %>` of the login `form_tag` block, add:

```erb
<p class="form-links"><%= link_to 'Forgot password?', new_password_reset_path %></p>
```

- [ ] **Step 8: Run the spec and confirm it passes**

Run: `bundle exec rspec spec/requests/password_resets_spec.rb`
Expected: all 8 examples PASS.

- [ ] **Step 9: Run the full suite**

Run: `bundle exec rspec`
Expected: all examples PASS.

- [ ] **Step 10: Commit**

```bash
git add config/routes.rb app/controllers/password_resets_controller.rb \
  app/views/password_resets/ app/views/sessions/new.html.erb \
  app/assets/stylesheets/sessions.scss spec/requests/password_resets_spec.rb
git commit -m "Add forgot-password flow: email code, verify, reset"
```

---

### Task 5: Change-password flow (authenticated)

**Files:**
- Modify: `config/routes.rb`
- Create: `app/controllers/web/admin/passwords_controller.rb`
- Create: `app/views/web/admin/passwords/edit.html.erb`
- Modify: `app/views/shared/_admin_header.html.erb`
- Test: `spec/requests/web/admin/passwords_spec.rb`

**Interfaces:**
- Consumes: `Admin` strength validation (Task 1), `PasswordMailer.password_changed` (Task 3), `Web::BaseController#current_admin`/`authenticate_admin!`/`reset_session` (existing).
- Produces: routes `edit_admin_password_path` (GET `/admin/password/edit`), `admin_password_path` (PATCH `/admin/password`).

- [ ] **Step 1: Write the failing request spec**

Create `spec/requests/web/admin/passwords_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe "Web::Admin::Passwords", type: :request do
  let!(:admin) { create(:admin, email: "admin@example.com", password: "Password123!") }

  def sign_in
    post "/login", params: { email: "admin@example.com", password: "Password123!" }
  end

  describe "PATCH /admin/password" do
    it "requires authentication" do
      patch "/admin/password", params: {
        current_password: "Password123!",
        admin: { password: "NewPassword123!", password_confirmation: "NewPassword123!" }
      }

      expect(response).to redirect_to(login_path)
    end

    it "rejects an incorrect current password" do
      sign_in

      patch "/admin/password", params: {
        current_password: "wrong",
        admin: { password: "NewPassword123!", password_confirmation: "NewPassword123!" }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(admin.reload.authenticate("Password123!")).to be_truthy
    end

    it "rejects a weak new password" do
      sign_in

      patch "/admin/password", params: {
        current_password: "Password123!",
        admin: { password: "weak", password_confirmation: "weak" }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "changes the password, notifies the admin, and logs them out" do
      sign_in

      patch "/admin/password", params: {
        current_password: "Password123!",
        admin: { password: "NewPassword123!", password_confirmation: "NewPassword123!" }
      }

      expect(response).to redirect_to(login_path)
      expect(admin.reload.authenticate("NewPassword123!")).to be_truthy
      expect(ActionMailer::Base.deliveries.last.subject).to eq("Your password was changed")

      get "/dashboard"
      expect(response).to redirect_to(login_path)
    end
  end
end
```

- [ ] **Step 2: Run the spec and confirm it fails**

Run: `bundle exec rspec spec/requests/web/admin/passwords_spec.rb`
Expected: FAIL with routing errors (`/admin/password` doesn't exist yet).

- [ ] **Step 3: Add the route**

Modify `config/routes.rb` — inside the `namespace :admin, path: '/admin', module: 'web/admin' do ... end` block, add directly after the existing `resource :profile, only: %i[show edit update]` line:

```ruby
    resource :password, only: %i[edit update], controller: 'passwords'
```

- [ ] **Step 4: Create the controller**

Create `app/controllers/web/admin/passwords_controller.rb`:

```ruby
module Web
  module Admin
    class PasswordsController < Web::BaseController
      layout 'admin'
      before_action :authenticate_admin!

      def edit; end

      def update
        unless current_admin.authenticate(params[:current_password])
          flash.now[:alert] = 'Current password is incorrect.'
          return render :edit, status: :unprocessable_entity
        end

        if current_admin.update(password_params)
          PasswordMailer.password_changed(current_admin).deliver_now
          reset_session
          redirect_to login_path, notice: 'Password changed. Please sign in again.'
        else
          render :edit, status: :unprocessable_entity
        end
      end

      private

      def password_params
        params.require(:admin).permit(:password, :password_confirmation)
      end
    end
  end
end
```

- [ ] **Step 5: Create the view**

Create `app/views/web/admin/passwords/edit.html.erb`:

```erb
<div class="profile-grid">
  <section class="card hero">
    <h2>Change Password</h2>

    <% if flash[:alert] %>
      <div class="card form-errors">
        <p><%= flash[:alert] %></p>
      </div>
    <% end %>

    <%= form_with model: current_admin, url: admin_password_path, method: :patch, local: true do |f| %>
      <% if current_admin.errors.any? %>
        <div class="card form-errors">
          <p>Please fix the following errors:</p>
          <ul>
            <% current_admin.errors.full_messages.each do |m| %>
              <li><%= m %></li>
            <% end %>
          </ul>
        </div>
      <% end %>

      <div class="form-grid">
        <div class="full">
          <label for="current_password">Current password</label>
          <%= password_field_tag :current_password, nil, id: 'current_password', class: 'input', required: true, autocomplete: 'current-password' %>
        </div>

        <div>
          <%= f.label :password, 'New password' %>
          <%= f.password_field :password, class: 'input', required: true, autocomplete: 'new-password' %>
        </div>

        <div>
          <%= f.label :password_confirmation, 'Confirm new password' %>
          <%= f.password_field :password_confirmation, class: 'input', required: true, autocomplete: 'new-password' %>
        </div>
      </div>

      <p class="small mt">Min 8 characters, with an uppercase letter, lowercase letter, number, and special character.</p>

      <div class="form-actions">
        <%= f.submit 'Change password', class: 'primary' %>
      </div>
    <% end %>
  </section>
</div>
```

- [ ] **Step 6: Link it from the admin header**

Modify `app/views/shared/_admin_header.html.erb` — add the link before the existing Logout button:

```erb
    <div class="right actions">
      <%= link_to 'Change password', edit_admin_password_path, class: 'btn' %>
      <%= button_to 'Logout', logout_path, method: :delete, class: 'btn logout' %>
    </div>
```

- [ ] **Step 7: Run the spec and confirm it passes**

Run: `bundle exec rspec spec/requests/web/admin/passwords_spec.rb`
Expected: all 4 examples PASS.

- [ ] **Step 8: Run the full suite**

Run: `bundle exec rspec`
Expected: all examples PASS.

- [ ] **Step 9: Commit**

```bash
git add config/routes.rb app/controllers/web/admin/passwords_controller.rb \
  app/views/web/admin/passwords/ app/views/shared/_admin_header.html.erb \
  spec/requests/web/admin/passwords_spec.rb
git commit -m "Add authenticated change-password page with logout-on-change"
```
