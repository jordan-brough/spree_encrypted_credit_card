require 'spec_helper'

describe Spree::EncryptedCreditCard do
  let(:credit_card) { 
    Spree::EncryptedCreditCard.new(valid_credit_card_attributes) 
  }

  let(:valid_credit_card_attributes) do
    { 
      number: '4111111111111111',
      verification_value: '123',
      month: 1,
      year: 2019,
      first_name: 'Spree',
      last_name: 'Commerce'
    }
  end

  describe '#valid?' do
    let(:credit_card) do
      Spree::EncryptedCreditCard.new(valid_credit_card_attributes.merge(
        month: 'i am a month',
        year: 'i am a year',
        encrypted_values: true
      ))
    end
  
    subject { credit_card.valid? }

    it 'should not validate month' do
      credit_card.month = 'i am a month'
      credit_card.valid?
      expect(subject).to be_true
    end

    it 'should not validate year' do
      credit_card.month = 'i am a year'
      expect(subject).to be_true
    end

    it 'should restore month' do
      subject
      expect(credit_card.month).to eq('i am a month')
    end

    it 'should restore year' do
      subject
      expect(credit_card.year).to eq('i am a year')
    end
  end

  describe 'save' do
    let(:credit_card) do
      Spree::EncryptedCreditCard.new(valid_credit_card_attributes.merge(
        month: 'i am a month',
        year: 'i am a year',
        encrypted_values: true
      ))
    end

    subject { credit_card.save }

    it 'should not store encrypted month' do
      subject
      expect(Spree::CreditCard.last.month).to be_nil 
    end

    it 'should not store encrypted year' do
      subject
      expect(Spree::CreditCard.last.year).to be_nil
    end

    it 'should restore month' do
      subject
      expect(credit_card.month).to eq('i am a month')
    end

    it 'should restore year' do
      subject
      expect(credit_card.year).to eq('i am a year')
    end
  end

  describe '#number' do
    context 'when encrypted_values is true' do
      it 'should not strip non numbers' do
        credit_card.encrypted_values = true 
        credit_card.number = 'i am not a number'      
        expect(credit_card.number).to eq('i am not a number')
      end
    end

    context 'when encrypted_values is false' do
      it 'should not strip non numbers' do
        credit_card.encrypted_values = false
        credit_card.number = 'i am not a number'    
        expect(credit_card.number).to eq('')
      end
    end
  end
end
