module Api
  module V1
    # Recuperação de senha — rota 4 de 4. Pública: quem esqueceu a senha não
    # consegue se autenticar para pedir a troca.
    #
    #   POST /api/v1/password_resets/request   pede o código
    #   POST /api/v1/password_resets/confirm   troca a senha
    class PasswordResetsController < BaseController
      # Sempre 200, sempre a mesma mensagem — ver Users::RequestPasswordReset.
      def request_reset
        result = Users::RequestPasswordReset.call(email: request_params[:email])
        render json: { message: result.message }, status: :ok
      end

      def confirm
        result = Users::CompletePasswordReset.call(
          email: confirm_params[:email],
          code: confirm_params[:code],
          password: confirm_params[:password],
          confirm_password: confirm_params[:confirm_password]
        )

        if result.success?
          render json: { message: result.message }, status: :ok
        else
          render_validation_errors(result.errors)
        end
      end

      private

      def request_params
        expect_root_params(:email)
      end

      def confirm_params
        expect_root_params(:email, :code, :password, :confirm_password)
      end
    end
  end
end
