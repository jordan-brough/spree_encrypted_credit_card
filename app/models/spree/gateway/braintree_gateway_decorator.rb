module Spree
  # Spree Gateway is a separate gem from Spree and may not be present :/
  return unless defined?(Gateway::BraintreeGateway)

  Gateway::BraintreeGateway.class_eval do
    alias_method :original_update_card_number, :update_card_number 

    def update_card_number(source, cc)
      # Indicate we're no longer encrypted to stop bypassing the validations.
      source.encrypted_values = false if source.instance_of?(Spree::EncryptedCreditCard)

      # Set the expiration date from Braintree
      source.expiry = cc['expiration_date']

      # Call the old logic
      original_update_card_number(source, cc)
    end
  end
end
