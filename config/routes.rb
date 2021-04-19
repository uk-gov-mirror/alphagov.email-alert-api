Rails.application.routes.draw do
  scope format: false, defaults: { format: :json } do
    root "welcome#index"
    resources :subscriber_lists, path: "subscriber-lists", only: %i[create]
    get "/subscriber-lists", to: "subscriber_lists#index"
    get "/subscriber-lists/:slug", to: "subscriber_lists#show"

    resources :content_changes, only: %i[create], path: "content-changes"
    resources :messages, only: %i[create]
    resources :spam_reports, path: "spam-reports", only: %i[create]
    resources :status_updates, path: "status-updates", only: %i[create]
    resources :subscriptions, only: %i[create show update]

    get "/subscriptions/:id/latest", to: "subscriptions#latest_matching"

    patch "/subscribers/:id", to: "subscribers#change_address"
    delete "/subscribers/:id", to: "unsubscribe#unsubscribe_all"
    get "/subscribers/:id/subscriptions", to: "subscribers#subscriptions"

    post "/subscribers/auth-token", to: "subscribers_auth_token#auth_token"
    post "/subscriptions/auth-token", to: "subscriptions_auth_token#auth_token"

    post "/unsubscribe/:id", to: "unsubscribe#unsubscribe"

    get "/healthcheck", to: GovukHealthcheck.rack_response(
      GovukHealthcheck::SidekiqRedis,
      GovukHealthcheck::ActiveRecord,
    )
  end
end
