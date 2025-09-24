require "sidekiq/web"

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  mount Sidekiq::Web, at: "/sidekiq"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get "metrics/endpoint_metrics", to: "metrics#endpoint_metrics"
      get "metrics/summary", to: "metrics#metrics_summary"
      get "rca/summary", to: "rca_events#summary"
      get "rca/org_alerts", to: "rca_events#org_alerts"
      get "rca/top_issues", to: "rca_events#top_issues"

      resources :rca_events, only: [ :index ] do
        collection do
          get :active
        end
      end

      resources :endpoint_configurations
      resources :endpoint_monitoring_groups
    end
  end
end
