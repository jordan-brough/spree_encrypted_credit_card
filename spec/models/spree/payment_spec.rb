require 'spec_helper'

describe Spree::Payment do
  let(:order) { Spree::Order.create }

  let(:gateway) do
    gateway = Spree::Gateway::Bogus.new(:environment => 'test', :active => true)
    gateway.stub :source_required => true
    gateway.stub :payment_source_class => Spree::CreditCard
    gateway
  end

  let(:card) do
    mock_model(Spree::CreditCard, :number => "4111111111111111",
                                  :has_payment_profile? => true)
  end

  let(:payment) do
    payment = Spree::Payment.new
    payment.order = order
    payment.payment_method = gateway
    payment
  end

  describe '#build_source' do
    context 'when encrypted_values is false' do
      before do
        payment.source_attributes = {
          month: 1,
          year: 2012 
        }
      end

      subject { payment.build_source }

      it 'should have Spree::CreditCard' do
        subject
        expect(payment.source).to be_a(Spree::CreditCard)
      end

      it 'should have has_encrypted_values? false' do
        subject
        expect(payment.source.has_encrypted_values?).to be_false
      end
    end

    context 'when encrypted_values is true' do
      before do
        payment.source_attributes = {
          encrypted_values: true,
          month: 'foo',
          year: 'bar'
        }
      end

      subject { payment.build_source }

      it 'should have Spree::EncryptedCreditCard' do
        subject
        expect(payment.source).to be_a(Spree::EncryptedCreditCard)
      end

      it 'should have has_encrypted_values? true' do
        subject
        expect(payment.source.has_encrypted_values?).to be_true
      end

      it 'should have month' do
        subject
        expect(payment.source.month).to eql('foo')
      end
    end
  end
end

    def build_source
      return if source_attributes.nil?
      # Create an Encrypted Credit Card instead of a Credit Card
      if payment_method and payment_method.payment_source_class == Spree::CreditCard and source[:encrypted_values] == true
        self.source = Spree::EncryptedCreditCard.new(source_attributes)
      elsif payment_method and payment_method.payment_source_class
        self.source = payment_method.payment_source_class.new(source_attributes)
      end
    end
