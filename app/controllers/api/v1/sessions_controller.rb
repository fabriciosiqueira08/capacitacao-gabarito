module Api
  module V1
    # Login e logout — rotas 2 e 3 de 4.
    #
    #   POST   /api/v1/sessions   entrar
    #   DELETE /api/v1/sessions   sair
    class SessionsController < BaseController
      ALLOWED_CLIENTS = %w[mobile web].freeze

      before_action :authenticate_user!, only: :destroy

      def create
        return render_invalid_client unless ALLOWED_CLIENTS.include?(session_params[:client])

        result = Auth::Login.call(
          email: session_params[:email],
          password: session_params[:password]
        )

        return render_login_error(result.error_code) unless result.success?

        entregar_token(Auth::IssueToken.call(result.user))
        render json: {
          message: "Login realizado com sucesso",
          user: UserSerializer.as_json(result.user)
        }, status: :ok
      end

      # Revoga o token apresentado (denylist por `jti`) e limpa o cookie. A
      # revogação é por token: os outros dispositivos do usuário seguem logados.
      def destroy
        revoke_current_token
        clear_auth_cookie
        render json: { message: "Logout realizado com sucesso" }, status: :ok
      end

      private

      def session_params
        expect_root_params(:email, :password, :client)
      end

      # O cliente diz quem é para receber o token do jeito certo: app no
      # cabeçalho, navegador no cookie httpOnly.
      def entregar_token(token)
        case session_params[:client]
        when "mobile" then response.headers["Authorization"] = "Bearer #{token}"
        when "web"    then set_auth_cookie(token)
        end
      end

      def render_invalid_client
        render_validation_errors([ { field: "client", message: "deve ser mobile ou web" } ])
      end

      def render_login_error(error_code)
        if error_code == "email_unverified"
          render_error(
            code: "email_unverified",
            message: "Confirme seu e-mail antes de entrar. Verifique sua caixa de entrada.",
            status: :forbidden          # 403: sabemos quem é você, mas ainda não pode
          )
        else
          render_error(
            code: "invalid_credentials",
            message: "E-mail ou senha inválidos",
            status: :unauthorized       # 401: não sabemos quem é você
          )
        end
      end
    end
  end
end
