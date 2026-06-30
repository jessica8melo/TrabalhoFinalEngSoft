class TemplatesController < ApplicationController
  before_action :require_login
  before_action :require_admin
  before_action :set_template, only: [:show, :edit, :update, :destroy]

  def index
    @templates = Template.order(:nome)

    if params[:simulate_error] == "true"
      raise StandardError, "Falha simulada no servidor"
    end

    if params[:q].present?
      if ActiveRecord::Base.connection.adapter_name.downcase.include?("sqlite")
        @templates = @templates.where(
          "lower(nome) LIKE ?",
          "%#{params[:q].downcase}%"
        )
      else
        @templates = @templates.where(
          "nome ILIKE ?",
          "%#{params[:q]}%"
        )
      end
    end

    per_page = 5
    page = params[:page].to_i
    page = 1 if page < 1

    @has_previous_page = page > 1
    @has_next_page = @templates.offset(page * per_page).limit(1).exists?
    @current_page = page
    @templates = @templates.offset((page - 1) * per_page).limit(per_page)
  rescue StandardError
    flash.now[:alert] = "Erro ao carregar a lista de templates"
    @templates = Template.none
    @has_previous_page = false
    @has_next_page = false
    @current_page = 1
  end

  def show
  end

  def edit
  end

  def update
    # Cria uma nova versão do template em vez de alterar o original
    novo = @template.dup

    if novo.respond_to?(:parent_template=)
      novo.parent_template = @template
    end

    novo.user = current_user if novo.respond_to?(:user=)
    novo.version = @template.version + 1 if novo.respond_to?(:version=)

    if novo.update(template_params)
      redirect_to templates_path,
                  notice: "Nova versão do template criada com sucesso."
    else
      flash[:alert] = novo.errors.full_messages.to_sentence
      redirect_to edit_template_path(@template)
    end
  end

  def destroy
    if @template.forms.exists?
      redirect_to templates_path,
                alert: "Template está em uso por formulários"
      return
    end

    if @template.destroy
      redirect_to templates_path,
                notice: "Template removido com sucesso."
    else
      redirect_to templates_path,
                alert: @template.errors.full_messages.to_sentence
    end
  end

  private

  def set_template
    @template = Template.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to templates_path,
                alert: "Template não encontrado."
  end

  def template_params
    params.require(:template)
          .permit(:nome, :descricao)
  end

  def require_login
    redirect_to login_path unless current_user
  end

  def require_admin
    unless current_user&.admin?
      redirect_to root_path,
                  alert: "Acesso negado."
    end
  end
end