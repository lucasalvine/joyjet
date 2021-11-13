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

  def levelTwo
    log_info("[LEVEL][TWO][PARAMS]", { articles: params[:articles], carts: params[:carts] })
    result = []
    articles = params[:articles]
    carts = params[:carts]

    if params[:delivery_fees].blank?
      log_error("[LEVEL][TWO][PARAMS]", { articles: params[:articles], carts: params[:carts] }) 

      return render json: {
        status: 'error',
        message: CartHelper::DELIVERY_FEES_ERROR_MESSAGE
      }, status: 404
    end

    delivery_fees = params[:delivery_fees]

    result_price = CartHelper.cart_with_delivery(carts, articles, delivery_fees)
    log_info("[LEVEL][TWO][RESULT]", { result: result_price })

    render json: { carts: result_price }, status: 200
  end

  def levelThree
    log_info("[LEVEL][THREE][PARAMS]", params)
    articles_with_discount = []
    articles = params[:articles]
    carts = params[:carts]

    if params[:delivery_fees].blank? || params[:discounts].blank?
      log_error("[LEVEL][TWO][PARAMS]", { articles: params[:articles], carts: params[:carts] })             

      return render json: {
        status: 'error',
        message: CartHelper::DISCOUNT_ERROR_MESSAGE
      }, status: 404
    end

    delivery_fees = params[:delivery_fees]
    discounts = params[:discounts]

    articles.each do |article|
      total_price = 0
      discounts.each do |discount|
        if article["id"] == discount["article_id"]
          case discount["type"]
          when "percentage"
            total_price = article["price"].to_f - (article["price"].to_f * discount["value"] / 100)
          when "amount"
            total_price = article["price"].to_f - discount["value"]
          else
            log_error("[LEVEL][THREE][ERROR]{DISCOUNT][TYPE]", { articles: params[:articles], carts: params[:carts] })
            total_price = article["price"]
          end
          break
        else
          total_price = article["price"]
        end
      end
      articles_with_discount.push({ "id" => article["id"], "price" => total_price.to_i })
    end

    result_price = CartHelper.cart_with_delivery(carts, articles_with_discount, delivery_fees)
    log_info("[LEVEL][THREE][RESULT]", result_price)

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