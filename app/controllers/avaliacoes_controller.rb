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
    return if @form.nil?

    @questions = @form.template.questions
    redirect_to avaliacoes_path, alert: "Você já respondeu esta avaliação" if ja_respondeu?
  end

  # Processa a submissão das respostas do discente
  #
  # Argumentos: params[:id] — id da Turma; params[:answers] — hash de respostas
  # Retorno: Nenhum (redireciona)
  # Efeitos colaterais: Cria FormResponse no banco
  def responder
    return if @form.nil?
    return if validacao_falhou?

    FormResponse.create!(
      form:    @form,
      user:    current_user,
      turma:   @turma,
      answers: build_answers
    )

    redirect_to avaliacoes_path, notice: "Avaliação enviada com sucesso"
  rescue => e
    flash.now[:alert] = "Erro ao enviar avaliação: #{e.message}"
    @questions = @form.template.questions
    render "avaliacoes/show", status: :unprocessable_entity
  end

  private

  def set_turma_and_form
    @turma = Turma.find(params[:id])
    @form  = @turma.forms.where("end_date > ?", Time.current).first
    redirect_to avaliacoes_path, alert: "Formulário não disponível" unless @form
  end

  # Realiza as validações necessárias antes de salvar a resposta.
  #
  # Argumentos: Nenhum
  # Retorno: Booleano indicando se alguma validação falhou (true) ou não (false)
  # Efeitos Colaterais: Configura alertas no flash e renderiza/redireciona a página em caso de falha.
  def validacao_falhou?
    return true if ja_respondeu_validacao?
    return true if questoes_obrigatorias_faltando?
    false
  end

  # Verifica se o usuário já respondeu este formulário.
  #
  # Argumentos: Nenhum
  # Retorno: Booleano
  def ja_respondeu?
    FormResponse.exists?(form: @form, user: current_user)
  end

  # Verifica se o usuário já respondeu este formulário e redireciona se sim.
  #
  # Argumentos: Nenhum
  # Retorno: Booleano
  # Efeitos Colaterais: Redireciona e gera alerta se já respondeu.
  def ja_respondeu_validacao?
    if ja_respondeu?
      redirect_to avaliacoes_path, alert: "Você já respondeu esta avaliação"
      true
    else
      false
    end
  end

  # Verifica se falta alguma resposta a questão obrigatória.
  #
  # Argumentos: Nenhum
  # Retorno: Booleano
  # Efeitos Colaterais: Renderiza erro com status unprocessable_entity se faltar resposta.
  def questoes_obrigatorias_faltando?
    @questions = @form.template.questions
    missing = @questions.where(obrigatoria: true).any? do |question|
      params[:answers].blank? || params[:answers][question.id.to_s].blank?
    end

    if missing
      flash.now[:alert] = "Por favor, responda todas as questões obrigatórias"
      render "avaliacoes/show", status: :unprocessable_entity
      true
    else
      false
    end
  end

  # Monta o array de respostas a partir dos params, no formato
  # { "question_id" => ..., "value" => ... } usado por FormResponse#answers
  # (e consumido, por exemplo, na exportação de CSV dos resultados).
  #
  # Argumentos: Nenhum
  # Retorno: Array de Hash
  def build_answers
    return [] unless params[:answers].is_a?(ActionController::Parameters)

    params[:answers].map do |question_id, value|
      {
        "question_id" => question_id.to_i,
        "value"       => value.is_a?(String) ? value : value.to_unsafe_h
      }
    end
  end
end
