require  'rails_helper'

RSpec.describe AgreementKind, type: :model do
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name)
       .is_at_least(1)
       .is_at_most(100) }
end