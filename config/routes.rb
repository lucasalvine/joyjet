Rails.application.routes.draw do
  post '/cart/level1', to: 'cart#levelOne'
  post '/cart/level2', to: 'cart#levelTwo'
end
