module SpreeEncryptedCreditCard
  module Configuration
    class << self
      require 'ostruct'

      delegate :auto_capture?, to: :configs

      def set(options = {})
        @configs = OpenStruct.new(options)
      end

      private

      def configs
        @configs
      end
    end
  end
end
