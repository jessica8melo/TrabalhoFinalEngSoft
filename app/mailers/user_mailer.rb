class UserMailer < ApplicationMailer
  # Envia o email de convite com o link para o usuário definir sua senha.
  #
  # Uso (no controller de cadastro de usuários, feature #3):
  #
  #   user = User.create!(email: params[:email], matricula: params[:matricula], role: "discente")
  #   user.generate_invitation_token!
  #   UserMailer.invitation(user).deliver_later
  #
  # Não é necessário informar senha no cadastro — o usuário a define pelo link enviado.
  #
  def invitation(user)
    @user = user
    @url  = password_set_url(token: @user.invitation_token)
    mail(to: @user.email, subject: "Bem-vindo ao CAMAAR — Defina sua senha")
  end
end