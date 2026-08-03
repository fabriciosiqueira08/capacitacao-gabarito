module Auth
  # Decodifica e valida a assinatura do JWT.
  #
  # O `true` no terceiro argumento é o que importa: sem ele, o JWT.decode aceita
  # qualquer token e qualquer um forja o próprio acesso trocando o `sub`.
  class DecodeToken
    class InvalidToken < StandardError; end

    def self.call(token)
      new(token).call
    end

    def initialize(token)
      @token = token
    end

    def call
      payload, = JWT.decode(@token, TokenSecret.call, true, { algorithm: "HS256" })
      payload.with_indifferent_access
    rescue JWT::DecodeError
      # Token inválido, adulterado ou expirado — para nós é tudo a mesma coisa.
      raise InvalidToken
    end
  end
end
