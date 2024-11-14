# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*' # Change to specific origin for production
    resource '*', headers: :any, methods: %i[get post options]
  end
end
