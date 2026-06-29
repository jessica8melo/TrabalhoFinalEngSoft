require "csv"

# Controller para visualização e download de resultados de formulários
class Admin::ResultsController < ApplicationController
  before_action :require_admin
  layout "dashboard"
  before_action :set_turma, only: [:show, :csv]

  # Lista turmas que possuem formulários com respostas
  #
  # Argumentos: Nenhum
  # Retorno: Nenhum (renderiza view)
  # Efeitos colaterais: Nenhum
  def index
    turma_ids = FormResponse.distinct.pluck(:turma_id)
    @turmas   = Turma.includes(:disciplina, :docentes).where(id: turma_ids)
  end

  # Exibe detalhes de resultados de uma turma específica
  #
  # Argumentos: params[:id] — id da Turma
  # Retorno: Nenhum (renderiza view)
  # Efeitos colaterais: Nenhum
  def show
    @responses = FormResponse.where(turma: @turma).includes(:user, form: { template: :questions })
  end

  # Gera e faz download de CSV com as respostas da turma
  #
  # Argumentos: params[:id] — id da Turma
  # Retorno: Arquivo CSV
  # Efeitos colaterais: Envia arquivo ao cliente
  def csv
    responses = FormResponse.where(turma: @turma).includes(:user, form: { template: :questions })
    send_data build_csv(responses),
      type:        "text/csv; charset=utf-8",
      filename:    "resultados_turma_#{@turma.id}.csv",
      disposition: "attachment"
  end

  private

  def set_turma
    @turma = Turma.includes(:disciplina, :docentes).find(params[:id])
  end

  # Gera CSV com colunas Turma, Discente, Questão, Resposta
  #
  # Argumentos: responses (ActiveRecord::Relation)
  # Retorno: String com conteúdo CSV
  # Efeitos colaterais: Nenhum
  def build_csv(responses)
    CSV.generate(headers: true) do |csv|
      csv << %w[Turma Discente Questão Resposta]
      responses.each { |fr| append_response_rows(csv, fr) }
    end
  end

  # Adiciona linhas de um FormResponse ao CSV
  #
  # Argumentos: csv (CSV), fr (FormResponse)
  # Retorno: Nenhum
  # Efeitos colaterais: Modifica csv in-place
  def append_response_rows(csv, fr)
    answers = Array(fr.answers)
    return csv << empty_row(fr) if answers.empty?

    questions = questions_for(fr)
    answers.each { |ans| csv << answer_row(fr, questions, ans) }
  end

  # Retorna linha vazia para respostas sem dados
  #
  # Argumentos: fr (FormResponse)
  # Retorno: Array com campos da linha
  # Efeitos colaterais: Nenhum
  def empty_row(fr)
    [@turma.classCode, fr.user&.nome.to_s, "", ""]
  end

  # Retorna linha preenchida para uma resposta
  #
  # Argumentos: fr (FormResponse), questions (Array), ans (Hash)
  # Retorno: Array com campos da linha
  # Efeitos colaterais: Nenhum
  def answer_row(fr, questions, ans)
    question = questions.find { |q| q.id == ans["question_id"] }
    [@turma.classCode, fr.user&.nome.to_s, question&.text.to_s, ans["value"].to_s]
  end

  # Retorna as questões associadas ao FormResponse
  #
  # Argumentos: fr (FormResponse)
  # Retorno: Array de Question
  # Efeitos colaterais: Nenhum
  def questions_for(fr)
    fr.form&.template&.questions || []
  end
end
