Rails.application.routes.draw do
  # Health check: devolve 200 se a aplicação sobe sem estourar exceção.
  # É o que load balancers e monitores de uptime chamam (ver Aula 4).
  get "up" => "rails/health#show", as: :rails_health_check

  # Toda a API vive sob /api/v1. A versão no caminho permite lançar uma /v2
  # sem quebrar quem já usa a /v1 — o app na loja demora a atualizar.
  namespace :api do
    namespace :v1 do
      get "status", to: "status#show"
    end
  end
end
