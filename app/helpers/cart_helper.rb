module CartHelper
  ERROR_MESSAGE = 'Sorry, something went wrong. Please try again.'

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
end