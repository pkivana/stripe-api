module StripeMocking
  def mock_stripe_customers_list
    stub_request(:get, "https://api.stripe.com/v1/customers?limit=50").
      with(
        headers: {'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Authorization'=>"Bearer #{Rails.application.credentials.stripe[:secret_key]}",
        'Content-Type' => 'application/x-www-form-urlencoded',
        'User-Agent' => 'Stripe/v1 RubyBindings/5.41.0',}).
       to_return(status: 200,
         body: JSON.generate(
           object: 'list',
           data: [
             { id: 'id1', email: 'id1@email.com', name: '', currency: 'EUR' },
             { id: 'id2', email: 'id2@email.com', name: '', currency: 'EUR' },
             { id: 'id3', email: 'id3@email.com', name: '', currency: 'EUR' },
           ],
           has_more: false,
           url: '/v1/customers'
         ),
         headers: {}
       )
  end
end

RSpec.configuration.include StripeMocking
