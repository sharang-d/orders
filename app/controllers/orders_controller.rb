class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    api_response = PaypalRestApi.new.create_order(email: nil, return_url: root_url,
                                                  cancel_url: root_url, amount_cents: "1.11")
    Rails.logger.info "orderId"
    Rails.logger.info api_response["id"]
    render json: { paymentID: api_response["id"] }
  end

  def pay
    PaypalRestApi.new.pay(order_id: params["paymentID"])

    render json: { message: "Success" }
  end
end
