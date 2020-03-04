class PaypalRestApi
  include HTTParty

  base_uri PAYPAL_REST_ENDPOINT
  headers({
    "Content-Type"                  => "application/json",
    "PayPal-Partner-Attribution-Id" => "Gumroad_SP"
  })

  def create_order(email:, return_url:, cancel_url:, amount_cents:)
    tracking_id = timestamp
    amount = amount_cents
    self.class.post("/v2/checkout/orders",
      headers: {
        "Authorization"             => token,
        "PayPal-Request-Id"         => timestamp
      },
      body: {
        intent: "CAPTURE",
        application_context: {
          return_url: return_url,
          cancel_url: cancel_url,
          client_configuration: {
            integration_artifact: "PAYPAL_JS_SDK",
            experience: {
              user_experience_flow: "FULL_PAGE_REDIRECT",
              entry_point: "PAY_WITH_PAYPAL",
              channel: "WEB",
              product_flow: "HERMES"
            }
          },
        },
        # preferred_payment_source: {
        #   token: {
        #     type: "BILLING_AGREEMENT",
        #     id: "B-6282561050045662U"
        #   }
        # },
        purchase_units: [
          {
            reference_id: "po11",
            amount: {
              currency_code: "USD",
              value: "15.00"
            },
            payee: {
              email: email
            },
            payment_instruction: "INSTANT",
            items: [
              {
                name: "mobile",
                unit_amount: {
                  currency_code: "USD",
                  value: "15.00"
                },
                quantity: "1",
                sku: "Item2001"
              }
            ],
            soft_descriptor: "gumroad.com"
          }
        ],
      }.to_json
    )
  end

  def pay(order_id:, tracking_id: nil)
    self.class.post("/v1/checkout/orders/#{order_id}/pay",
      headers: {
        "Authorization"             => token,
        "Paypal-Client-Metadata-Id" => tracking_id,
        "PayPal-Request-Id"         => timestamp
      },
      body: {
        "disbursement_mode" => "DELAYED" # "INSTANT" will be avaible in 3 weeks as per PayPal
      }.to_json
    )
  end

  def disburse_funds(capture_id)
    self.class.post("/v1/payments/referenced-payouts-items",
      headers: {
        "Authorization"             => token,
        "PayPal-Request-Id"         => timestamp,
        "Prefer"                    => "respond-sync"
      },
      body: {
        "reference_type" => "TRANSACTION_ID",
        "reference_id"   => capture_id
      }.to_json
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
