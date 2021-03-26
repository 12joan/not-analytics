Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  post '/', to: 'hits#create'
  get '/apps/:id', to: 'apps#show'
  get '/apps/:id/hits', to: 'hits#index'
end
