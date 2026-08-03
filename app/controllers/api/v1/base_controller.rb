module Api
  module V1
    # Pai de todos os controllers da API. Concentra autenticação, formato de
    # erro e o tratamento de exceções.
    class BaseController < ApplicationController
      include Authentication
      include ErrorRendering

      # O ActiveSupport casa os handlers de baixo para cima (o último registrado
      # ganha). StandardError vem primeiro justamente para ser o pega-tudo de
      # menor prioridade; os específicos abaixo são avaliados antes dele.
      rescue_from StandardError, with: :internal_server_error
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActionController::ParameterMissing, with: :parameter_missing
      rescue_from ActionDispatch::Http::Parameters::ParseError, with: :parameter_missing

      private

      def internal_server_error(exception)
        raise exception if Rails.env.local?

        Rails.error.report(exception, handled: false, source: "Api::V1::BaseController")

        render_error(
          code: "internal_server_error",
          message: "Erro interno do servidor",
          # Nunca devolva a mensagem da exceção: ela entrega nome de tabela,
          # caminho de arquivo e às vezes o próprio dado do usuário.
          status: :internal_server_error
        )
      end

      def record_not_found
        render_error(code: "not_found", message: "Recurso não encontrado", status: :not_found)
      end

      def parameter_missing
        render_error(code: "bad_request", message: "Requisição inválida", status: :bad_request)
      end

      # params.expect exige as chaves e recusa o resto — é o strong parameters
      # do Rails 8. Sem ele, alguém manda "role": "admin" no cadastro e vira
      # admin (isso tem nome: mass assignment).
      def expect_root_params(*keys)
        extraidos = params.expect(*keys)
        valores = keys.one? ? [ extraidos ] : extraidos
        keys.zip(valores).to_h.with_indifferent_access
      end
    end
  end
end
