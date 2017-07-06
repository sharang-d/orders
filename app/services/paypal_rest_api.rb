class PaypalRestApi
  include HTTParty

  base_uri PAYPAL_REST_ENDPOINT
  headers({
    "Accept"                        => "application/json",
    "Content-Type"                  => "application/json",
    "PayPal-Partner-Attribution-Id" => "Gumroad_SP",
    "Accept-Language"               => "en_US"
  })

  def create_order(email:, return_url:, cancel_url:, amount_cents:)
    tracking_id = timestamp
    Rails.logger.info timestamp
    Rails.logger.info "*******" * 100
    self.class.put("/v1/risk/transaction-contexts/#{PAYPAL_MERCHANT_ID}/#{tracking_id}",
      headers: {
        "Authorization"     => token,
        "PayPal-Request-Id" => timestamp
      }
    )

    amount = amount_cents
    self.class.post("/v1/checkout/orders",
      headers: {
        "Authorization"             => token,
        "Paypal-Client-Metadata-Id" => tracking_id,
        "PayPal-Request-Id"         => timestamp
      },
      body: {
        purchase_units: [
          {
            reference_id: "po11",
            amount: {
              currency: "USD",
              details: {
                shipping: "0",
                subtotal: amount,
                tax: "0"
              },
              total: amount
            },
            payee: {
              email: 'akshay.vishnoi+2-seller@bigbinary.com'
            },
            items: [
              {
                currency: "USD",
                name: "From Test App",
                price: amount,
                quantity: "1",
                sku: "Item2000"
              }
            ],
            payment_descriptor: "gumroad.com",
            notify_url: "http://marketplace.com/"
          }
        ],
        redirect_urls: {
          return_url: return_url,
          cancel_url: cancel_url
        }
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

  private

  def token
    "Bearer #{PayPal::SDK::Core::API::REST.new.token}"
  end

  def timestamp
    Time.current.to_i.to_s
  end
end
