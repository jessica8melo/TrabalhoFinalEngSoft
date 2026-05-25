#language: pt

Funcionalidade: Gerar relatório do Administrador
    Como um Administrador
    Quero baixar um arquivo CSV contendo os resultados de um formulário
    A fim de avaliar o desempenho das turmas

    Contexto:
        Dado que estou logado como Administrador
        E estou na página de resultados de um formulário de avaliação
    
  # ==================== CENÁRIOS FELIZES ====================

    Cenário: Download do CSV com resultados de um formulário preenchido
        Dado que o formulário "Avaliação Engenharia de Software - 2026.1" possui respostas registradas
        Quando clico no botão "Baixar CSV"
        Então um arquivo CSV é baixado com o nome "relatorio_engenharia_software_2026_1.csv"
        E o arquivo contém as colunas "Turma", "Discente", "Docente", "Questão", "Resposta"
        E cada linha corresponde a uma resposta submetida
    
    Cenário: Download do CSV com resultados filtrados por turma
        Dado que o formulário "Avaliação Engenharia de Software - 2026.1" possui respostas de múltiplas turmas
        Quando seleciono a turma "Turma 01 - Engenharia de Software (2026.1)"
        E clico no botão "Baixar CSV"
        Então um arquivo CSV é baixado contendo apenas respostas da turma selecionada
        E o arquivo não contém respostas de outras turmas
    
    Cenário: Download do CSV contendo todos os campos do formulário
        Dado que o formulário "Avaliação Engenharia de Software - 2026.1" possui questões de múltiplos tipos
        Quando clico no botão "Baixar CSV"
        Então o arquivo CSV baixado contém uma coluna para cada questão do formulário
        E os valores de cada coluna correspondem às respostas dos discentes

  # ==================== CENÁRIOS TRISTES ====================

    Cenário: Tentativa de download de CSV de formulário sem respostas
        Dado que o formulário "Avaliação Engenharia de Software - 2026.1" não possui nenhuma resposta registrada
        Quando clico no botão "Baixar CSV"
        Então nenhum arquivo é baixado
        E vejo a mensagem de aviso "Este formulário ainda não possui respostas registradas"

    Cenário: Tentativa de acesso à geração de relatório por usuário não administrador
        Dado que estou logado como User
        Quando tento acessar a página de resultados de um formulário de avaliação
        Então sou redirecionado para o painel do usuário
        E vejo a mensagem de erro "Acesso não autorizado"

    Cenário: Erro ao gerar CSV por falha interna
        Dado que o formulário "Avaliação Engenharia de Software - 2026.1" possui respostas registradas
        E o sistema está com falha no serviço de exportação
        Quando clico no botão "Baixar CSV"
        Então nenhum arquivo é baixado
        E vejo a mensagem de erro "Não foi possível gerar o relatório. Tente novamente"
