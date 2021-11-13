module CartHelper
  ERROR_MESSAGE = 'Sorry, something went wrong. Please try again.'
  DELIVERY_FEES_ERROR_MESSAGE = 'Delivery fees is required.'
  DISCOUNT_ERROR_MESSAGE = 'Discount is required.'

  def self.cart_total_price(articles, carts)
    Rails.logger.info("[data][log][CART][TOTAL_PRICE][PARAMS], #{articles}, #{carts}")

    result = []

    carts.each do |cart|
      total_price = 0
      cart["items"].each do |item|
        articles.each do |article|
          if article["id"] == item["article_id"]
            total_price += item["quantity"] * article["price"]
            break
          end
        end
      end
      result.push({ "id" => cart[:id], "total" => total_price })
    end

    Rails.logger.info("[data][log][CART][TOTAL_PRICE][RESULT], #{result}")
    result
  end

  def self.cart_with_delivery(carts, articles, delivery_fees)
    Rails.logger.info("[data][log][CART][WITH_DELIVERY][RESULT], #{carts}, #{articles}, #{delivery_fees}")
    
    result = []
    result_cart_total_price = cart_total_price(articles, carts)

    if result_cart_total_price.empty?
      result
    end

    result_cart_total_price.each do |cart|
      total_price = 0
      delivery_fees.each do |fee|
        eligible_transaction = fee["eligible_transaction_volume"]
        if (eligible_transaction["min_price"]..eligible_transaction["max_price"]).include? (cart["total"])
          total_price = cart["total"] + fee["price"]
          break
        end
      end
      result.push({ "id" => cart[:id], "total" => total_price })
    end

    Rails.logger.info("[data][log][CART][WITH_DELIVERY][RESULT], #{result}")
    result
  end
end