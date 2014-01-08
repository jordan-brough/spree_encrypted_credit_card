Spree Encrypted CreditCard
=========================

This gem modifies Spree to support end to end Credit Card encryption, as supported by Braintree. Currently, Spree does not work with Braintree's style of encryption due to all of the validations and table constraints for Spree::CreditCard.

About The Problem
-----------------

Braintree encourages developers to use their JS encryption library. This library encrypts the CC data at the time of keyboard entry in the user's browser. The values are decrypted on Braintree's side, and they return to the developer the decrypted values, month, year, last_4_digits, etc.

https://www.braintreepayments.com/docs/javascript/encryption/overview

This is very different from how Stripe works, where their encryption library sends the request to Stripe first, and all Spree sees is the token which then provides the decrypted values.

https://stripe.com/docs/stripe.js

The problem with Spree as it stands, is that it works only for the Stripe methodology; if encrypted values are passed through Spree::CreditCard, the validations will all fail, the encrypted credit card number gets stripped, and the record becomes un-saveable due to exceeding the column constraint when storing an encrypted string.

https://github.com/spree/spree/blob/master/core/app/models/spree/credit_card.rb#L9-L13

The Solution
------------

The solution this Gem tries is to create a Spree::EncryptedCreditCard that subclasses Spree::CreditCard. It hack-ily tries to bypass the validations and data insertion of Spree::CreditCard. The validations for month/year are bypassed by stashing the encrypted values, and providing dummy values to pass validation. On save, to avoid exceeding the varchar(255) limit of month and year, and to avoid a DB migration to increase the column size, we blank out the encrypted values before saving.

This is all performed by ActiveRecord callbacks. The data is all restored during the after_X phase of the relevant callback.

This allows the encrypted data to be passed through to Braintree as is and not be mangled by Spree.

Braintree than returns the decrypted values. This Gem also decorates the Braintree gateway provided by Spree Gateway to set both the decrypted CC number and decrypted epxiry date.

How To Use
----------

In order to use this Gem, you need to pass:

```
encrypted_values: true
```

As part of your payment source attributes. If the Payment is of type Spree::CreditCard and encrypted_values is set, then Spree will use Spree::EncryptedCreditCard isntead of Spree::CreditCard.

An example JS file using Braintree's JS is here:

https://gist.github.com/HoyaBoya/9e98c07e3ba84f51c952


Installation
------------

Add spree_encrypted_credit_card to your Gemfile:

```ruby
gem 'spree_encrypted_credit_card'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g spree_encrypted_credit_card:install
```

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

```shell
bundle
bundle exec rake test_app
bundle exec rspec spec
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_encrypted_credit_card/factories'
```

To Do
-----
* Work with Spree community to see if/how this can ever be merged back to Spree.
* Additional support for other gateways that do Braintree style end to end encryption/decryption.

Copyright (c) 2014 [name of extension creator], released under the New BSD License
