module Spree
  Payment.class_eval do
    alias_method :original_build_source, :build_source

    def build_source
      return if source_attributes.nil?
      # Create an Encrypted Credit Card instead of a Credit Card
      if payment_method and payment_method.payment_source_class == Spree::CreditCard and source_attributes[:encrypted_values] == true
        self.source = Spree::EncryptedCreditCard.new(source_attributes)
      else
        original_build_source 
      end
    end
  end
end
