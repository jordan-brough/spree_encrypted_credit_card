require 'spec_helper' 

describe Spree::Gateway::BraintreeGateway do

  before do
    @gateway = Spree::Gateway::BraintreeGateway.create!(:name => "Braintree Gateway", :environment => "sandbox", :active => true)

    @credit_card = FactoryGirl.create(:credit_card, :verification_value => '123', :number => '5105105105105100', :month => 9, :year => Time.now.year + 1, :first_name => 'John', :last_name => 'Doe', :cc_type => 'mastercard')

    @payment = FactoryGirl.create(:payment, :source => @credit_card)
    @payment.payment_method.environment = "test"
  end

  describe '#update_card_number' do
    let(:credit_card_response) do
      { 'token' => 'testing', 'last_4' => '1234', 'masked_number' => '5555**5555', 'expiration_date' => '01/2015' }
    end
  
    subject { @gateway.update_card_number(@payment.source, credit_card_response) }

    it "passes through gateway_payment_profile_id" do
      subject
      @payment.source.gateway_payment_profile_id.should == "testing"
    end

    it "updates expiry" do
      subject
      @payment.source.month.should == '01'
      @payment.source.year.should == '2015'
    end

    it "sets encrypted_values to false" do
      subject
      @payment.source.encrypted_values.should be_false
    end
  end
end
