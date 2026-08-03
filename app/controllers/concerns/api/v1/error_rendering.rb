module Api
  module V1
    # Um formato de erro só, para a API inteira.
    #
    #   { "error": { "code": "...", "message": "...", "details": [...] } }
    #
    # `code` é para o cliente decidir o que fazer (é estável, não muda).
    # `message` é para o usuário ler (pode mudar, pode ser traduzida).
    # `details` diz qual campo falhou, para o app marcar o input em vermelho.
    module ErrorRendering
      extend ActiveSupport::Concern

      private

      def render_error(code:, message:, status:, details: nil)
        body = { error: { code:, message: } }
        body[:error][:details] = details if details.present?

        render json: body, status:
      end

      def render_validation_errors(details)
        render_error(
          code: "validation_failed",
          message: "Falha na validação",
          status: :unprocessable_content,
          details:
        )
      end

      def render_user(user, status: :ok, wrapper: nil)
        payload = { user: UserSerializer.as_json(user) }
        payload = wrapper.merge(payload) if wrapper
        render json: payload, status:
      end
    end
  end
end
