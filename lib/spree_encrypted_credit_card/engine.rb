module SpreeEncryptedCreditCard
  class Engine < Rails::Engine
    require 'spree/core'

    isolate_namespace Spree
    engine_name 'spree_encrypted_credit_card'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
    end

    config.to_prepare &method(:activate).to_proc

    initializer "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << Spree::Gateway::EncryptedBraintreeGateway
    end
  end
end
