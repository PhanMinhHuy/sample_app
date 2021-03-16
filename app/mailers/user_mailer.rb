class UserMailer < ApplicationMailer
  def account_activation user
    @user = user
    mail to: user.email, subject: t("email.title")
  end

  def password_reset
    @greeting = t "email.hi"
    mail to: t("email.to")
  end
end
