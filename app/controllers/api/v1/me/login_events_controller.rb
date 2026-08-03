module Api
  module V1
    module Me
      # GET /api/v1/me/login_events — os últimos acessos da própria conta.
      #
      # É a rota que existe para exercitar a associação: `current_user` já tem
      # `login_events`, e o scope `recentes` ordena.
      class LoginEventsController < BaseController
        before_action :authenticate_user!

        LIMITE = 10

        def index
          eventos = current_user.login_events.recentes.limit(LIMITE)

          render json: { login_events: eventos.map { |e| LoginEventSerializer.as_json(e) } }
        end
      end
    end
  end
end
