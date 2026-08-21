Rails.application.routes.draw do
  # Health check: devolve 200 se a aplicação sobe sem estourar exceção.
  # É o que load balancers e monitores de uptime chamam (ver Aula 4).
  get "up" => "rails/health#show", as: :rails_health_check

  # A caixa de entrada de desenvolvimento: todo e-mail que a aplicação
  # "enviaria" fica em http://localhost:3000/letter_opener.
  #
  # Só existe em development — em produção esta linha nem é avaliada, e o
  # e-mail sai de verdade por SMTP (Aula 4).
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Toda a API vive sob /api/v1. A versão no caminho permite lançar uma /v2
  # sem quebrar quem já usa a /v1 — o app na loja demora a atualizar.
  namespace :api do
    namespace :v1 do
      get "status", to: "status#show"

      # --- Rotas públicas (sem token) ---
      post "registrations", to: "registrations#create"
      post "email_verifications/confirm", to: "email_verifications#confirm"
      post "email_verifications/resend",  to: "email_verifications#resend"
      post "password_resets/request", to: "password_resets#request_reset"
      post "password_resets/confirm", to: "password_resets#confirm"
      post "sessions", to: "sessions#create"

      # --- Rotas autenticadas ---
      # DELETE e POST no mesmo caminho: o recurso é a sessão. Criar é entrar,
      # apagar é sair. `as: nil` porque o helper de rota já nasceu no POST.
      delete "sessions", to: "sessions#destroy", as: nil
      get "me", to: "me#show"
      # Últimos acessos da própria conta — exercita a associação user 1—N login_events.
      get "me/login_events", to: "me/login_events#index"
    end
  end
end
