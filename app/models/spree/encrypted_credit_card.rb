module Spree
  class EncryptedCreditCard < CreditCard

    ##
    # We can't (easily) override validations in Spree::CreditCard so we create callbacks to fake the data before valid?
    # https://github.com/spree/spree/blob/master/core/app/models/spree/credit_card.rb#L9-L13
    #
    before_validation :fake_encrypted_values!
    after_validation  :unfake_encrypted_values!

    ##
    # We don't store the encrypted values in the DB since they are too long for varchar(255) sometimes.
    #
    before_save       :stash_encrypted_values!
    after_save        :restore_encrypted_values!

    after_initialize :init_stash

    def init_stash
      @encrypted_values_stash = {}
      @encrypted_values_stash[:valid] = {}
      @encrypted_values_stash[:db] = {}
    end

    def number=(num)
      if has_encrypted_values?
        @number = num
      else
        super(num)
      end
    end

    def has_encrypted_values?
      encrypted_values
    end

    def encrypted_values=(b)
      @encrypted_values = b
    end

    def encrypted_values
      @encrypted_values
    end

    private

    REPLACEMENT_ENCRYPTED_VALUES = {
      month: 1,
      year: 2099
    } 

    def fake_encrypted_values!
      return unless has_encrypted_values?
      REPLACEMENT_ENCRYPTED_VALUES.each_pair do |k, v| 
        @encrypted_values_stash[:valid][k] = self[k]
        self[k] = v 
      end      
    end

    def unfake_encrypted_values!
      return unless has_encrypted_values?
      REPLACEMENT_ENCRYPTED_VALUES.keys.each do |k|
        self[k] = @encrypted_values_stash[:valid][k]
      end
    end

    PROTECTED_ENCRYPTED_VALUES = [:month, :year]

    def stash_encrypted_values!
      return unless has_encrypted_values?
      PROTECTED_ENCRYPTED_VALUES.each do |i|
        @encrypted_values_stash[:db][i] = self[i]
        self[i] = nil 
      end
    end

    def restore_encrypted_values!
      return unless has_encrypted_values?
      PROTECTED_ENCRYPTED_VALUES.each do |i|
        self[i] = @encrypted_values_stash[:db][i]
      end
    end
  end
end
