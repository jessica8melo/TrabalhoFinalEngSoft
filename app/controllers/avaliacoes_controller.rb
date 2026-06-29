# Controller para o painel de avaliações do discente
class AvaliacoesController < ApplicationController
  layout "dashboard"
  before_action :set_turma_and_form, only: [:show, :responder]

  # Lista as turmas com formulários disponíveis para o usuário logado
  #
  # Argumentos: Nenhum
  # Retorno: Nenhum (renderiza view)
  # Efeitos colaterais: Nenhum
  def index
    turmas_ids = current_user.turmas.pluck(:id)
    @turmas_com_form = Turma
      .joins(:forms)
      .where(id: turmas_ids)
      .where("forms.end_date > ?", Time.current)
      .includes(:disciplina)
      .distinct
  end

  # Exibe o formulário de avaliação de uma turma para o discente responder
  #
  # Argumentos: params[:id] — id da Turma
  # Retorno: Nenhum (renderiza view)
  # Efeitos colaterais: Nenhum
  def show
    @questions = @form.template.questions
  end

  # Processa a submissão das respostas do discente
  #
  # Argumentos: params[:id] — id da Turma; params[:answers] — hash de respostas
  # Retorno: Nenhum (redireciona)
  # Efeitos colaterais: Cria FormResponse no banco
  def responder
    answers = build_answers

    FormResponse.create!(
      form:   @form,
      user:   current_user,
      turma:  @turma,
      answers: answers
    )

    redirect_to avaliacoes_path, notice: "Avaliação enviada com sucesso"
  end

  private

  def set_turma_and_form
    @turma = Turma.find(params[:id])
    @form  = @turma.forms.where("end_date > ?", Time.current).first
    redirect_to avaliacoes_path, alert: "Formulário não disponível" unless @form
  end

  def build_answers
    return [] unless params[:answers].is_a?(ActionController::Parameters)
    params[:answers].values.map { |a| a.is_a?(String) ? a : a.to_unsafe_h }
  end
end
