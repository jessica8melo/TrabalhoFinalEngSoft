class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    # renderizar a página de login
  end

  def create
    if params[:login].blank? || params[:password].blank?
      flash.now[:alert] = "Preencha todos os campos obrigatórios"
      return render :new, status: :unprocessable_entity
    end

    user = User.find_by_login(params[:login])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:notice] = "Login realizado com sucesso!"
      redirect_to login_path
    else
      flash.now[:alert] = "Credenciais inválidas"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: 'Logout realizado com sucesso'
  end
end
