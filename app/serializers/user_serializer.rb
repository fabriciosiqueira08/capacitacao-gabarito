# Decide o que do User vai para o JSON — e, mais importante, o que NÃO vai.
#
# `render json: user` mandaria o objeto inteiro, incluindo password_digest e os
# digests dos códigos. O serializer é a lista de convidados.
class UserSerializer
  def self.as_json(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      email_verified: user.email_verified?,
      course: user.course,
      matricula: user.matricula,
      created_at: user.created_at.iso8601
    }
  end
end
