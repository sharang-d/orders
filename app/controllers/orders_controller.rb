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
    api_response = PaypalRestApi.new.create_order(email: nil, return_url: pay_orders_url,
                                                  cancel_url: root_url, amount_cents: "1.11")

    render json: { approval_url: api_response.parsed_response["links"].find { |link| link["rel"] == "approval_url" }["href"] }
  end

  def pay
    PaypalRestApi.new.pay(order_id: params["paymentToken"])

    render json: { message: "Success" }
  end
end
