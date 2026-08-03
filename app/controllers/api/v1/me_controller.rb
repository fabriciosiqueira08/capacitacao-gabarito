module Api
  module V1
    # GET /api/v1/me — a rota que prova que a autenticação funciona.
    #
    # Com token válido devolve o usuário; sem token, 401. É o que o app chama ao
    # abrir para saber se a sessão ainda vale.
    class MeController < BaseController
      before_action :authenticate_user!

      def show
        render_user(current_user)
      end
    end
  end
end
