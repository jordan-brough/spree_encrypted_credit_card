module Spree
  CreditCard.class_eval do
    def has_encrypted_values?
      encrypted_values
    end

    def encrypted_values=(b)
      @encrypted_values = b
    end

    def encrypted_values
      false
    end
  end
end
