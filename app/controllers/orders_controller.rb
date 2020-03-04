class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def handle_paypal_webhooks
    if params[:event_type] == 'CHECKOUT.ORDER.PROCESSED'
      params[:resource][:purchase_units].each do |purchase_unit|
        capture_id = purchase_unit[:payment_summary][:captures][0][:id]

        PaypalRestApi.new.disburse_funds(capture_id)
      end
    end

    render json: {}
  end

  def create
    api_response = PaypalRestApi.new.create_order(email: "sharang.d-facilitator@gmail.com", return_url: root_url,
                                                  cancel_url: root_url, amount_cents: "1.11")
    Rails.logger.info api_response.inspect
    render json: { paymentID: api_response["id"] }
  end

  def pay
    PaypalRestApi.new.pay(order_id: params["paymentToken"])

    render json: { message: "Success" }
  end
end
