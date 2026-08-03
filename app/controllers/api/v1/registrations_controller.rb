module Api
  module V1
    # POST /api/v1/registrations — rota 1 de 4.
    class RegistrationsController < BaseController
      def create
        result = Users::Register.call(registration_params)

        if result.success?
          render_user(
            result.user,
            status: :created,
            wrapper: { message: "Cadastro realizado. Enviamos um código para o seu e-mail." }
          )
        else
          render_validation_errors(result.errors)
        end
      end

      private

      def registration_params
        expect_root_params(
          :name, :email, :password, :confirm_password, :course, :matricula, :check_terms_use
        ).to_h.symbolize_keys
      end
    end
  end
end
