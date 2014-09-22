require 'spec_helper' 

describe Spree::Gateway::EncryptedBraintreeGateway do

  before do
    @gateway = Spree::Gateway::EncryptedBraintreeGateway.create!(:name => "Encrypted Braintree Gateway", :environment => "sandbox", :active => true)

    @credit_card = Spree::EncryptedCreditCard.new

    @payment = Spree::Payment.new

    @payment.source = @credit_card
  end

  describe '#payment_source' do
    it 'should be Spree::EncryptedCreditCard' do
      expect(@gateway.payment_source_class).to eql(Spree::EncryptedCreditCard)
    end
  end

  describe '#update_cc_data' do
    let(:credit_card_response) do
      { 'token' => 'testing', 'last_4' => '1234', 'masked_number' => '5555**5555', 'expiration_date' => '01/2015' }
    end

    before do
      @gateway.should_receive(:update_card_number).once.with(@payment.source, credit_card_response)
    end
  
    subject { @gateway.update_cc_data(@payment.source, credit_card_response) }

    it "updates expiry" do
      subject
      @payment.source.month.to_i.should == 1
      @payment.source.year.to_i.should == 2015
    end

    it "sets encrypted_values to false" do
      subject
      @payment.source.encrypted_values.should be_false
    end
  end

  describe "#map_billing_address" do
    it "works correctly with US addresses and their state info" do
      address = Spree::Address.new(address1: '123 Pleasant Lane', city: 'Montreal', state: Spree::State.new(abbr: 'NY'), zipcode: '12345', country: Spree::Country.new(name: 'United States'))
      @gateway.send(:map_billing_address, address)[:state].should == 'NY'
    end

    it "works correctly with international addresses and their state info" do
      address = Spree::Address.new(address1: '123 Pleasant Lane', city: 'Montreal', state_name: 'Quebec', zipcode: '12345', country: Spree::Country.new(name: 'Canada'))
      @gateway.send(:map_billing_address, address)[:state].should == 'Quebec'
    end
  end
end
