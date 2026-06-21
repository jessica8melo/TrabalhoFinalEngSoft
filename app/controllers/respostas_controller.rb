class RespostasController < ApplicationController
  layout "dashboard"

  # Processa a submissão de um formulário pelo usuário.
  #
  # Argumentos: Nenhum argumento direto. Espera que `params[:formulario_id]` 
  # e `params[:respostas]` estejam presentes na requisição.
  # Retorno: Nenhum valor de retorno explícito.
  # Efeitos Colaterais: Cria registros no banco de dados para cada resposta e redireciona a página.
  def create
    @formulario = Formulario.find(params[:formulario_id])
    return if validacao_falhou?

    salvar_respostas
    redirect_to formularios_path, notice: "Avaliação submetida com sucesso!"
  rescue => e
    flash[:alert] = "Erro ao enviar avaliação: #{e.message}"
    @perguntas = @formulario.perguntas
    render "formularios/show", status: :unprocessable_entity
  end

  private

  # Realiza as validações necessárias antes de salvar as respostas.
  #
  # Argumentos: Nenhum
  # Retorno: Booleano indicando se alguma validação falhou (true) ou não (false)
  # Efeitos Colaterais: Configura alertas no flash e renderiza/redireciona a página em caso de falha.
  def validacao_falhou?
    return true if prazo_encerrado?
    return true if ja_respondeu?
    return true if respostas_obrigatorias_faltando?
    false
  end

  # Verifica se o prazo do formulário já encerrou.
  #
  # Argumentos: Nenhum
  # Retorno: Booleano
  # Efeitos Colaterais: Redireciona e gera alerta se encerrado.
  def prazo_encerrado?
    if @formulario.deadline < Time.current
      redirect_to formularios_path, alert: "Avaliação encerrada"
      true
    else
      false
    end
  end

  # Verifica se o usuário já respondeu este formulário.
  #
  # Argumentos: Nenhum
  # Retorno: Booleano
  # Efeitos Colaterais: Redireciona e gera alerta se já respondeu.
  def ja_respondeu?
    if Resposta.exists?(formulario: @formulario, user: current_user)
      redirect_to formularios_path, alert: "Você já respondeu esta avaliação"
      true
    else
      false
    end
  end

  # Verifica se falta alguma resposta obrigatória.
  #
  # Argumentos: Nenhum
  # Retorno: Booleano
  # Efeitos Colaterais: Renderiza erro com status unprocessable_entity se faltar resposta.
  def respostas_obrigatorias_faltando?
    missing = @formulario.perguntas.where(obrigatoria: true).any? do |p|
      params[:respostas].blank? || params[:respostas][p.id.to_s].blank?
    end

    if missing
      flash[:alert] = "Por favor, responda todas as questões obrigatórias"
      @perguntas = @formulario.perguntas
      render "formularios/show", status: :unprocessable_entity
      true
    else
      false
    end
  end

  # Salva todas as respostas associando ao formulário e usuário.
  #
  # Argumentos: Nenhum
  # Retorno: Nenhum
  # Efeitos Colaterais: Cria registros no banco de dados da tabela de Respostas.
  def salvar_respostas
    Resposta.transaction do
      params[:respostas].each do |pergunta_id, conteudo|
        Resposta.create!(
          formulario: @formulario,
          user: current_user,
          pergunta_id: pergunta_id,
          conteudo: conteudo
        )
      end
    end
  end
end
