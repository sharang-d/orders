class PaypalRestApi
  include HTTParty

  base_uri PAYPAL_REST_ENDPOINT
  headers({
    "Content-Type"                  => "application/json",
    "PayPal-Partner-Attribution-Id" => "Gumroad_SP"
  })

  def create_order(email:, return_url:, cancel_url:, amount_cents:)
    amount = (amount_cents / 100.0).to_s
    tracking_id = timestamp
    self.class.post("/v2/checkout/orders",
      headers: {
        "Authorization"             => token,
        "PayPal-Request-Id"         => timestamp
      },
      body: {
        intent: "CAPTURE",
        purchase_units: [
          {
            reference_id: "po11",
            amount: {
              currency_code: "USD",
              value: amount
            },
            payee: {
              email: email
            },
            soft_descriptor: "gumroad.com"
          }
        ],
      }.to_json
    )
  end

  def capture(order_id:, tracking_id: nil)
    self.class.post("/v1/checkout/orders/#{order_id}/capture",
      headers: {
        "Authorization"             => token,
        "Paypal-Client-Metadata-Id" => tracking_id,
        "PayPal-Request-Id"         => timestamp
      },
      body: {}.to_json
    )
  end


  def refund(capture_id)
    self.class.post("/v1/payments/capture/#{ capture_id }/refund",
      headers: {
        'Authorization' => token,
        'PayPal-Request-Id' => timestamp
      },
      body: {}.to_json
    )

  end

  private

  def token
    PaypalPartnerRestCredentials.new.auth_token
  end

  def timestamp
    Time.current.to_i.to_s
  end
end
