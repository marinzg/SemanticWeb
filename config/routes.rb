Rails.application.routes.draw do
  get 'home/index'

  post 'home/searchresults'

  get 'home/actor'

  get 'home/movie'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
