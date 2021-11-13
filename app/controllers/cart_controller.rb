class CartController < ApplicationController
  before_action :validate_cart_params

  def levelOne
    log_info("[LEVEL][ONE][PARAMS]", { articles: params[:articles], carts: params[:carts] })
    articles = params[:articles]
    carts = params[:carts]

    result_price = CartHelper.cart_total_price(articles, carts)
    log_info("[LEVEL][ONE][RESULT]", { result: result_price })

    
    render json: { carts: result_price }, status: 200
  end

  def validate_cart_params
    if params[:articles].blank? || params[:carts].blank?
      return render json: {
        status: 'error',
        message: CartHelper::ERROR_MESSAGE
      }
    end
  end
end