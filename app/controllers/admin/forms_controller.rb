# Namespace para os controllers do painel administrativo do sistema
module Admin
end

# Controller para criação de formulários de avaliação pelo administrador
class Admin::FormsController < ApplicationController
  before_action :require_admin

  # Cria um formulário baseado em template e o envia para as turmas selecionadas
  #
  # Argumentos: params[:template_id], params[:turma_ids] (array)
  # Retorno: Nenhum (redireciona)
  # Efeitos colaterais: Cria Form e associações com turmas no banco
  def create
    return redirect_missing_template if params[:template_id].blank?

    turma_ids = Array(params[:turma_ids]).reject(&:blank?)
    return redirect_missing_turmas if turma_ids.empty?

    deliver_form(params[:template_id], turma_ids)
  end

  private

  # Redireciona com erro quando template não foi selecionado
  #
  # Argumentos: Nenhum
  # Retorno: ActionDispatch::Response (redirect)
  # Efeitos colaterais: Nenhum
  def redirect_missing_template
    redirect_to admin_management_path, alert: "Selecione um template para o formulário"
  end

  # Redireciona com erro quando nenhuma turma foi selecionada
  #
  # Argumentos: Nenhum
  # Retorno: ActionDispatch::Response (redirect)
  # Efeitos colaterais: Nenhum
  def redirect_missing_turmas
    redirect_to admin_management_path, alert: "Selecione ao menos uma turma"
  end

  # Cria o formulário e associa às turmas selecionadas
  #
  # Argumentos: template_id (String), turma_ids (Array)
  # Retorno: ActionDispatch::Response (redirect)
  # Efeitos colaterais: Cria Form e registros em forms_turmas
  def deliver_form(template_id, turma_ids)
    template = Template.find_by(id: template_id)
    form     = Form.create!(template: template, start_date: Time.current, end_date: 1.month.from_now)
    form.turmas << Turma.where(id: turma_ids)
    redirect_to admin_management_path, notice: "Formulário enviado com sucesso"
  end
end
