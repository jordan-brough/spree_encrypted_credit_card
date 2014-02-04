require 'spec_helper'

describe SpreeEncryptedCreditCard::Configuration do

  it "returns configured configurations" do
    SpreeEncryptedCreditCard::Configuration.set(auto_capture?: true)
    expect(SpreeEncryptedCreditCard::Configuration.auto_capture?).to be_true
  end

  it "does not respond to other configurations" do
    SpreeEncryptedCreditCard::Configuration.set(other_config: true)
    expect { SpreeEncryptedCreditCard::Configuration.other_config }.to raise_error NoMethodError
  end
end
