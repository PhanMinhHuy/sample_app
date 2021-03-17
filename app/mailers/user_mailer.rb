class UserMailer < ApplicationMailer
  def account_activation user
    @user = user
    mail to: user.email, subject: t("email.activation_title")
  end

  def password_reset user
    @user = user
    mail to: user.email, subject: t("email.password_reset_title")
  end
end
