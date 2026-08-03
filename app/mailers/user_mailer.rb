# Um mailer é um controller cujas "views" são e-mails: cada método público
# monta um e-mail e o template correspondente vive em app/views/user_mailer/.
class UserMailer < ApplicationMailer
  def email_verification(user, code)
    @user = user
    @code = code

    mail(to: @user.email, subject: "Ative sua conta — #{app_name}")
  end

  def password_reset(user, code)
    @user = user
    @code = code

    mail(to: @user.email, subject: "Redefina sua senha — #{app_name}")
  end

  private

  def app_name
    ENV.fetch("APP_NAME", "Automic Auth API")
  end
end
