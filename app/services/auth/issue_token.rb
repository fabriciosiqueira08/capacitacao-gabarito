module Auth
  # Emite o JWT do login.
  #
  # O payload é PÚBLICO: qualquer um decodifica em jwt.io. A assinatura garante
  # que ninguém alterou o conteúdo — não que ninguém leu. Nunca coloque aqui
  # nada que não possa ser lido.
  class IssueToken
    EXPIRATION = 24.hours

    def self.call(user)
      new(user).call
    end

    def initialize(user)
      @user = user
    end

    def call
      payload = {
        sub: @user.id,                    # subject: de quem é o token
        ver: @user.token_version,         # versão das sessões (ver User#invalidate_sessions!)
        jti: SecureRandom.uuid,           # id único do token, usado na denylist do logout
        exp: EXPIRATION.from_now.to_i,    # expiração (a lib valida sozinha)
        iat: Time.current.to_i            # emitido em
      }

      JWT.encode(payload, TokenSecret.call, "HS256")
    end
  end
end
