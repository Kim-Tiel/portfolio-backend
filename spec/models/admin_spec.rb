require 'rails_helper'

RSpec.describe Admin, type: :model do
  subject { build(:admin) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email) }
  it { is_expected.to have_secure_password }

  it "downcases the email before saving" do
    admin = create(:admin, email: "Admin@Example.com")
    expect(admin.reload.email).to eq("admin@example.com")
  end
end
