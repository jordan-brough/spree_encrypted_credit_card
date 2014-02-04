module Spree
  class Gateway::EncryptedBraintreeGateway < Gateway::BraintreeGateway

    delegate :auto_capture?, to: SpreeEncryptedCreditCard::Configuration

    ##
    # Use our new Spree::EncryptedCreditCard vs Spree::CreditCard
    #
    def payment_source_class
      EncryptedCreditCard
    end

    ##
    # A bit of duplication but create_profile is consistent across all gateways.
    # Let's override here rather than update_card_number which feels more brittle.
    #
    # God I miss Java @Overrides and abstract :)
    #
    def create_profile(payment)
      if payment.source.gateway_customer_profile_id.nil?
        response = provider.store(payment.source, {billing_address: map_billing_address(payment.order.bill_address)})
        if response.success?
          payment.source.update_attributes!(:gateway_customer_profile_id => response.params['customer_vault_id'])
          cc = response.params['braintree_customer'].fetch('credit_cards',[]).first

          # Call our new update logic
          update_cc_data(payment.source, cc) if cc
        else
          payment.send(:gateway_error, response.message)
        end
      end
    end

    ##
    # Updates expiry and card_number
    #
    def update_cc_data(source, cc)
      # Indicate we're no longer encrypted to stop bypassing the validations.
      source.encrypted_values = false if source.instance_of?(Spree::EncryptedCreditCard)

      # Set the expiration date from Braintree
      source.expiry = cc['expiration_date']

      # Call the old logic
      update_card_number(source, cc)
    end

    private

    def map_billing_address(address)
      return {} if address.nil?
      {
        :address1 => address.address1,
        :address2 => address.address2,
        :city => address.city,
        :state => address.state.abbr,
        :zip => address.zipcode,
        :country_name => address.country.name
      }
    end
  end

end
