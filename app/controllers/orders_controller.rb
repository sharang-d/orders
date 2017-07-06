class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token
  def handle_paypal_webhooks
    if params[:event_type] == 'CHECKOUT.ORDER.PROCESSED'
      capture_id = params[:resource][:purchase_units][0][:payment_summary][:captures][0][:id]
      api_response = PaypalRestApi.new.disburse_funds(capture_id)
    end
    render json: {}
  end

  def create
    api_response = PaypalRestApi.new.create_order(email: nil, return_url: root_url,
                                                  cancel_url: root_url, amount_cents: "1.11")

    render json: { paymentID: api_response["id"] }
  end

  def pay
    PaypalRestApi.new.pay(order_id: params["paymentToken"])

    render json: { message: "Success" }
  end
end
