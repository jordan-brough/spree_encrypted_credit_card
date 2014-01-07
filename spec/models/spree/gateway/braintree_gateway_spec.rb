require 'spec_helper' 

describe Spree::Gateway::BraintreeGateway do

  before do
    @gateway = Spree::Gateway::BraintreeGateway.create!(:name => "Braintree Gateway", :environment => "sandbox", :active => true)

    @credit_card = Spree::EncryptedCreditCard.new

    @payment = Spree::Payment.new

    @payment.source = @credit_card
  end

  describe '#update_card_number' do
    let(:credit_card_response) do
      { 'token' => 'testing', 'last_4' => '1234', 'masked_number' => '5555**5555', 'expiration_date' => '01/2015' }
    end

    before do
      @gateway.should_receive(:original_update_card_number).once
    end
  
    subject { @gateway.update_card_number(@payment.source, credit_card_response) }

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
