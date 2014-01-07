module Spree
  return unless defined?(Gateway::BraintreeGateway)

  Gateway::BraintreeGateway.class_eval do
    alias_method :original_update_card_number, :update_card_number 

    def update_card_number(source, cc)
      source.encrypted_values = false if source.instance_of?(Spree::EncryptedCreditCard)
      source.expiry = cc['expiration_date']
      original_update_card_number(source, cc)
    end
  end
end
