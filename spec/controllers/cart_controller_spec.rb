require 'rails_helper'

RSpec.describe CartController, type: :controller do
  context "Success Post" do
    request = {  
      "articles": [
        { "id": 1, "name": "water", "price": 100 },
        { "id": 2, "name": "honey", "price": 200 },
        { "id": 3, "name": "mango", "price": 400 },
        { "id": 4, "name": "tea", "price": 1000 }
      ],
      "carts": [
        {
          "id": 1,
          "items": [
            { "article_id": 1, "quantity": 6 },
            { "article_id": 2, "quantity": 2 },
            { "article_id": 4, "quantity": 1 }
          ]
        },
        {
          "id": 2,
          "items": [
            { "article_id": 2, "quantity": 1 },
            { "article_id": 3, "quantity": 3 }
          ]
        },
        {
          "id": 3,
          "items": []
        }
      ]
    }

    it "should return json to total amount cart by id" do
      post :levelOne, params: request

      expect(response.status).to eq(200)
      expect(response.body).to eq("{\"carts\":[{\"id\":\"1\",\"total\":2000},{\"id\":\"2\",\"total\":1400},{\"id\":\"3\",\"total\":0}]}")
    end

    it "should return json to total amount cart by id with delivery fees" do
      delivery_fees_request = {
        "delivery_fees": [
          {
            "eligible_transaction_volume": {
              "min_price": 0,
              "max_price": 1000
            },
            "price": 800
          },
          {
            "eligible_transaction_volume": {
              "min_price": 1000,
              "max_price": 2000
            },
            "price": 400
          },
          {
            "eligible_transaction_volume": {
              "min_price": 2000,
              "max_price": nil
            },
            "price": 0
          }
        ]
      }

      post :levelTwo, params: request.merge(delivery_fees_request)

      expect(response.status).to eq(200)
      expect(response.body).to eq("{\"carts\":[{\"id\":\"1\",\"total\":2400},{\"id\":\"2\",\"total\":1800},{\"id\":\"3\",\"total\":800}]}")
    end

    it "should return json to total amount cart by id with delivery fees and discount items" do
      another_request = {
        "delivery_fees": [
          {
            "eligible_transaction_volume": {
              "min_price": 0,
              "max_price": 1000
            },
            "price": 800
          },
          {
            "eligible_transaction_volume": {
              "min_price": 1000,
              "max_price": 2000
            },
            "price": 400
          },
          {
            "eligible_transaction_volume": {
              "min_price": 2000,
              "max_price": nil
            },
            "price": 0
          }
        ],
        "discounts": [
          { "article_id": 2, "type": "amount", "value": 25 },
          { "article_id": 5, "type": "percentage", "value": 30 },
          { "article_id": 6, "type": "percentage", "value": 30 },
          { "article_id": 7, "type": "percentage", "value": 25 },
          { "article_id": 8, "type": "percentage", "value": 10 }
        ]
      }

      post :levelThree, params: request.merge(another_request)

      expect(response.status).to eq(200)
      expect(response.body).to eq("{\"carts\":[{\"id\":\"1\",\"total\":2350},{\"id\":\"2\",\"total\":1775},{\"id\":\"3\",\"total\":800}]}")

    end
  end

  context "POST /level1" do
    it "should return error message because not contain articles - 404" do
      request = {
        "carts": [
          {
            "id": 1,
            "items": [
              { "article_id": 1, "quantity": 6 },
              { "article_id": 2, "quantity": 2 },
              { "article_id": 4, "quantity": 1 }
            ]
          },
          {
            "id": 2,
            "items": [
              { "article_id": 2, "quantity": 1 },
              { "article_id": 3, "quantity": 3 }
            ]
          },
          {
            "id": 3,
            "items": []
          }
        ]
      }
      post :levelOne, params: request

      expect(response.status).to eq(404)
      expect(response.body).to include(CartHelper::ERROR_MESSAGE)
    end

    it "should return error message because not contain carts - 404" do
      request = {
        "articles": [
          { "id": 1, "name": "water", "price": 100 },
          { "id": 2, "name": "honey", "price": 200 },
          { "id": 3, "name": "mango", "price": 400 },
          { "id": 4, "name": "tea", "price": 1000 }
        ],
      }
      post :levelOne, params: request

      expect(response.status).to eq(404)
      expect(response.body).to include(CartHelper::ERROR_MESSAGE)
    end
  end

  context "POST /level2" do
    it "should return error message because not contain delivery fees - 404" do
      request = {
        "articles": [
          { "id": 1, "name": "water", "price": 100 },
          { "id": 2, "name": "honey", "price": 200 },
          { "id": 3, "name": "mango", "price": 400 },
          { "id": 4, "name": "tea", "price": 1000 }
        ],
        "carts": [
          {
            "id": 1,
            "items": [
              { "article_id": 1, "quantity": 6 },
              { "article_id": 2, "quantity": 2 },
              { "article_id": 4, "quantity": 1 }
            ]
          },
          {
            "id": 2,
            "items": [
              { "article_id": 2, "quantity": 1 },
              { "article_id": 3, "quantity": 3 }
            ]
          },
          {
            "id": 3,
            "items": []
          }
        ]
      }

      post :levelTwo, params: request

      expect(response.status).to eq(404)
      expect(response.body).to include(CartHelper::DELIVERY_FEES_ERROR_MESSAGE)
    end

    it "should return error message because not contain articles - 404" do
      request = {
        "carts": [
          {
            "id": 1,
            "items": [
              { "article_id": 1, "quantity": 6 },
              { "article_id": 2, "quantity": 2 },
              { "article_id": 4, "quantity": 1 }
            ]
          },
          {
            "id": 2,
            "items": [
              { "article_id": 2, "quantity": 1 },
              { "article_id": 3, "quantity": 3 }
            ]
          },
          {
            "id": 3,
            "items": []
          }
        ]
      }
      
      post :levelTwo, params: request

      expect(response.status).to eq(404)
      expect(response.body).to include(CartHelper::ERROR_MESSAGE)
    end

    it "should return error message because not contain carts - 404" do
      request = {
        "articles": [
          { "id": 1, "name": "water", "price": 100 },
          { "id": 2, "name": "honey", "price": 200 },
          { "id": 3, "name": "mango", "price": 400 },
          { "id": 4, "name": "tea", "price": 1000 }
        ],
      }

      post :levelTwo, params: request

      expect(response.status).to eq(404)
      expect(response.body).to include(CartHelper::ERROR_MESSAGE)
    end
  end

  context "POST /level3" do
    it "should return error message because not contain delivery fees - 404" do
      request = {
        "articles": [
          { "id": 1, "name": "water", "price": 100 },
          { "id": 2, "name": "honey", "price": 200 },
          { "id": 3, "name": "mango", "price": 400 },
          { "id": 4, "name": "tea", "price": 1000 }
        ],
        "carts": [
          {
            "id": 1,
            "items": [
              { "article_id": 1, "quantity": 6 },
              { "article_id": 2, "quantity": 2 },
              { "article_id": 4, "quantity": 1 }
            ]
          },
          {
            "id": 2,
            "items": [
              { "article_id": 2, "quantity": 1 },
              { "article_id": 3, "quantity": 3 }
            ]
          },
          {
            "id": 3,
            "items": []
          }
        ]
      }
      post :levelThree, params: request

      expect(response.status).to eq(404)
      expect(response.body).to include(CartHelper::DISCOUNT_ERROR_MESSAGE)
    end

    it "should return error message because not contain articles - 404" do
      request = {
        "carts": [
          {
            "id": 1,
            "items": [
              { "article_id": 1, "quantity": 6 },
              { "article_id": 2, "quantity": 2 },
              { "article_id": 4, "quantity": 1 }
            ]
          },
          {
            "id": 2,
            "items": [
              { "article_id": 2, "quantity": 1 },
              { "article_id": 3, "quantity": 3 }
            ]
          },
          {
            "id": 3,
            "items": []
          }
        ]
      }
      post :levelThree, params: request

      expect(response.status).to eq(404)
      expect(response.body).to include(CartHelper::ERROR_MESSAGE)
    end

    it "should return error message because not contain carts - 404" do
      request = {
        "articles": [
          { "id": 1, "name": "water", "price": 100 },
          { "id": 2, "name": "honey", "price": 200 },
          { "id": 3, "name": "mango", "price": 400 },
          { "id": 4, "name": "tea", "price": 1000 }
        ],
      }
      post :levelThree, params: request

      expect(response.status).to eq(404)
      expect(response.body).to include(CartHelper::ERROR_MESSAGE)
    end
  end
end
