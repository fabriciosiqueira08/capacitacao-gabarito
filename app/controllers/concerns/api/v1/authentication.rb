module Api
  module V1
    # Descobre quem está chamando, a partir do token.
    #
    # Dois clientes, dois transportes:
    # - app nativo → cabeçalho `Authorization: Bearer <token>`
    # - painel web → cookie assinado e httpOnly (JavaScript não lê, então um XSS
    #   não rouba o token)
    module Authentication
      extend ActiveSupport::Concern

      AUTH_COOKIE = :automic_auth

      included do
        include ActionController::Cookies
      end

      private

      def current_user
        @current_user ||= user_from_bearer || user_from_cookie
      end

      def authenticate_user!
        return if current_user

        render_error(
          code: "unauthorized",
          message: "Autenticação necessária",
          status: :unauthorized
        )
      end

      def user_from_bearer
        token = bearer_token
        user_from_token(token) if token.present?
      end

      def user_from_cookie
        token = cookie_token
        user_from_token(token) if token.present?
      end

      def bearer_token
        header = request.headers["Authorization"].to_s
        return unless header.start_with?("Bearer ")

        header.delete_prefix("Bearer ").strip
      end

      def cookie_token
        cookies.signed[AUTH_COOKIE].presence
      end

      def current_token
        bearer_token.presence || cookie_token
      end

      # Três perguntas, nesta ordem: a assinatura confere? o token foi revogado
      # no logout? a versão de sessão ainda é a mesma?
      def user_from_token(token)
        payload = Auth::DecodeToken.call(token)
        return if Auth::TokenDenylist.revoked?(payload[:jti])

        user = User.find_by(id: payload[:sub])
        user if user&.token_version_matches?(payload[:ver])
      rescue Auth::DecodeToken::InvalidToken
        nil
      end

      # Idempotente: sem token (já deslogado) ou token inválido, não faz nada.
      def revoke_current_token
        token = current_token
        return if token.blank?

        Auth::TokenDenylist.revoke(Auth::DecodeToken.call(token))
      rescue Auth::DecodeToken::InvalidToken
        nil
      end

      def set_auth_cookie(token)
        cookies.signed[AUTH_COOKIE] = {
          value: token,
          httponly: true,                    # JavaScript não enxerga
          secure: Rails.env.production?,     # só trafega em HTTPS
          same_site: :lax                    # mitiga CSRF
        }
      end

      def clear_auth_cookie
        cookies.delete(AUTH_COOKIE)
      end
    end
  end
end
