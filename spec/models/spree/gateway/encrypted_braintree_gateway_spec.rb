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
      @payment.source.month.should == '01'
      @payment.source.year.should == '2015'
    end

    it "sets encrypted_values to false" do
      subject
      @payment.source.encrypted_values.should be_false
    end
  end

  describe "#auto_capture?" do
    it "uses the configuration" do
      expected = "AUTO_CAPTURE_CONFIG"
      SpreeEncryptedCreditCard::Configuration.stub(:auto_capture?).and_return(expected)
      expect(subject.auto_capture?).to eq expected
    end
  end
end
