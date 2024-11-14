# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'bands/search', to: 'bands#search'
      get 'bands/location', to: 'bands#location'
    end
  end
end
