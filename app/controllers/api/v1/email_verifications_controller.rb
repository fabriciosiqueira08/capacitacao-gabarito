module Api
  module V1
    # Ativação da conta pelo código de 6 dígitos enviado no cadastro.
    #
    #   POST /api/v1/email_verifications/confirm
    #   POST /api/v1/email_verifications/resend
    class EmailVerificationsController < BaseController
      def confirm
        result = Users::ConfirmEmailVerification.call(
          email: confirm_params[:email],
          code: confirm_params[:code]
        )

        if result.success?
          render_user(result.user, wrapper: { message: "E-mail confirmado. Você já pode entrar." })
        else
          render_validation_errors(result.errors)
        end
      end

      def resend
        result = Users::ResendEmailVerification.call(email: resend_params[:email])
        render json: { message: result.message }, status: :ok
      end

      private

      def confirm_params
        expect_root_params(:email, :code)
      end

      def resend_params
        expect_root_params(:email)
      end
    end
  end
end
