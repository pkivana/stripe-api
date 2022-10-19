class StripeProvider::Base
  require 'stripe'
  Stripe.api_key = Rails.application.credentials.stripe[:secret_key]
end
