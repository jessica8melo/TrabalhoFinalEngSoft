# encoding: utf-8

# ==================== CONTEXTO ====================

def assign_user_to_turma(user, turma)
  if user.discente?
    Discente.find_or_create_by!(matricula: user.matricula, turma: turma) do |discente|
      discente.nome = user.nome || user.email
      discente.email = user.email
    end
  elsif user.docente?
    Docente.find_or_create_by!(usuario: user.matricula, turma: turma) do |docente|
      docente.nome = user.nome || user.email
      docente.email = user.email
    end
  else
    raise "Usuário #{user.email} não pode ser associado à turma #{turma.classCode}"
  end
end

Então('vejo uma seção com os formulários não respondidos das minhas turmas') do
  expect(page).to have_selector('.formularios-nao-respondidos')
end

# ==================== CENÁRIOS FELIZES - AÇÕES ====================

Quando('acesso a página {string}') do |pagina|
  case pagina
  when 'Avaliações'
    visit avaliacoes_path
  else
    visit '/'
  end
end

Então('vejo uma lista com cards de formulários não respondidos') do
  expect(page).to have_selector('.card')
end

Então('o formulário é removido da lista') do
  expect(page).not_to have_selector("#formulario_#{@form.id}")
end

Então('cada card exibe {string}, {string}, {string} e um botão {string}') do |info1, info2, info3, botao|
  card = find('.card')
  expect(card).to have_content(info1) # Turma
  expect(card).to have_content(info2) # Template
  expect(card).to have_content(info3) # Data de Término
  expect(card.has_link?(botao) || card.has_button?(botao)).to be(true)
end

Então('os formulários são agrupados por turma') do
  expect(page).to have_content('Turma:')
end

Dado('que existem formulários não respondidos') do
  @class = Turma.create!(
    classCode:     'CIC0105',
    nome:     'Engenharia de Software',
    semester: '2026.1'
  )
  
  assign_user_to_turma(@user, @class)
  
  @form = Formulario.create!(
    titulo: 'Avaliação de Engenharia de Software',
    deadline: 1.day.from_now
  )
  
  @form.update!(turma: @class)
end

Quando('clico no card de um formulário') do
  within(first('.card')) do
    click_link 'Responder'
  end
end

Quando('clico no card do formulário') do
  within(first('.card')) do
    click_link 'Responder'
  end
end

Então('vejo os detalhes completos como {string}, {string}, {string}, {string}') do |info1, info2, info3, info4|
  expect(page).to have_content(info1) # Turma
  expect(page).to have_content(info2) # Template
  expect(page).to have_content(info3) # Data de Início
  expect(page).to have_content(info4) # Data de Término
end

Então('vejo a quantidade de questões do formulário') do
  expect(page).to have_content('questões')
end

Dado('que estou matriculado em múltiplas turmas com formulários') do
  @class1 = Turma.create!(
    classCode:     'CIC0105',
    nome:     'Engenharia de Software',
    semester: '2026.1'
  )
  @class2 = Turma.create!(
    classCode:     'CIC0202',
    nome:     'Banco de Dados',
    semester: '2026.1'
  )
  
  assign_user_to_turma(@user, @class1)
  assign_user_to_turma(@user, @class2)
  
  @form1 = Formulario.create!(
    titulo: 'Avaliação 1',
    deadline: 1.day.from_now
  )
  @form1.update!(turma: @class1)
  
  @form2 = Formulario.create!(
    titulo: 'Avaliação 2',
    deadline: 1.day.from_now
  )
  @form2.update!(turma: @class2)
end

Quando('seleciono a turma {string} no filtro') do |turma|
  select turma, from: 'filtro_turma'
end

Então('a lista exibe apenas os formulários da turma {string}') do |turma|
  expect(page).to have_content(turma)
end

Então('os formulários de outras turmas deixam de aparecer') do
  expect(page).not_to have_selector('.card', count: 2)
end

Dado('que sou um Dicente com formulários para dicentes e também Docente com formulários para docentes') do
  @user_dicente = User.create!(
    email:                 'user_dicente@gmail.com',
    matricula:             '190084011',
    password:              'senha',
    password_confirmation: 'senha',
    role:                  'discente'
  )
  
  @user_docente = User.create!(
    email:                 'user_docente@gmail.com',
    matricula:             '190084012',
    password:              'senha',
    password_confirmation: 'senha',
    role:                  'docente'
  )
  
  @class = Turma.create!(
    classCode:     'CIC0105',
    nome:     'Engenharia de Software',
    semester: '2026.1'
  )
  
  assign_user_to_turma(@user_dicente, @class)
  assign_user_to_turma(@user_docente, @class)
  
  @form_dicente = Formulario.create!(
    titulo: 'Avaliação para Dicentes',
    deadline: 1.day.from_now
  )
  @form_dicente.update!(turma: @class)
  
  @form_docente = Formulario.create!(
    titulo: 'Avaliação para Docentes',
    deadline: 1.day.from_now
  )
  @form_docente.update!(turma: @class)
end

Quando('seleciono {string} no filtro {string}') do |opcao, filtro|
  select opcao, from: filtro
end

Então('a lista exibe apenas os formulários destinados a dicentes') do
  expect(page).to have_content('Avaliação para Dicentes')
end

Então('os formulários para docentes deixam de aparecer') do
  expect(page).not_to have_content('Avaliação para Docentes')
end

Dado('que existem múltiplos formulários com datas diferentes') do
  @class = Turma.create!(
    classCode:     'CIC0105',
    nome:     'Engenharia de Software',
    semester: '2026.1'
  )
  
  assign_user_to_turma(@user, @class)
  
  @form1 = Formulario.create!(
    titulo: 'Formulário 1',
    deadline: 5.days.from_now
  )
  
  @form2 = Formulario.create!(
    titulo: 'Formulário 2',
    deadline: 2.days.from_now
  )
end

Quando('clico no filtro {string}') do |filtro|
  click_button filtro
end

Quando('seleciono {string}') do |opcao|
  click_link opcao
end

Então(/os formulários aparecem ordenados por data de término/) do
  cards = all('.card')
  expect(cards.first).to have_content('2 dias') # Mais próximo
end

Dado('que existe um formulário com deadline em 2 dias') do
  @class = Turma.create!(
    classCode:     'CIC0105',
    nome:     'Engenharia de Software',
    semester: '2026.1'
  )
  
  assign_user_to_turma(@user, @class)
  
  @form = Formulario.create!(
    titulo: 'Avaliação',
    deadline: 2.days.from_now
  )
  
  @form.update!(turma: @class)
end

Quando('visualizo o card do formulário') do
  visit avaliacoes_path
end

Então('o card exibe uma barra de progresso de tempo em cor verde') do
  expect(page).to have_selector('.progress-bar.verde')
end

Dado('que existe um formulário vencendo em 1 hora') do
  @class = Turma.create!(
    classCode:     'CIC0105',
    nome:     'Engenharia de Software',
    semester: '2026.1'
  )
  
  assign_user_to_turma(@user, @class)
  
  @form = Formulario.create!(
    titulo: 'Avaliação Urgente',
    deadline: 1.hour.from_now
  )
  
  @form.update!(turma: @class)
end

Então('vejo a mensagem de alerta {string}') do |mensagem|
  expect(page).to have_selector('.alert', text: mensagem)
end

Então('o card exibe uma barra de progresso de tempo em cor vermelha') do
  expect(page).to have_selector('.progress-bar.vermelha')
end

Dado('que estou visualizando um formulário não respondido') do
  @class = Turma.create!(
    classCode:     'CIC0105',
    nome:     'Engenharia de Software',
    semester: '2026.1'
  )
  
  assign_user_to_turma(@user, @class)
  
  @form = Formulario.create!(
    titulo: 'Avaliação',
    deadline: 1.day.from_now
  )
  
  @form.update!(turma: @class)
  
  visit avaliacoes_path
  click_button 'Responder'
end

# Removed duplicate click step

Então('sou redirecionado para a página de preenchimento do formulário') do
  expect(page).to have_current_path(responder_form_path(@form), wait: 10)
end

Então('vejo todas as questões do template') do
  expect(page).to have_selector('.questao')
end

Dado('que estou preenchendo um formulário') do
  @class = Turma.create!(
    classCode:     'CIC0105',
    nome:     'Engenharia de Software',
    semester: '2026.1'
  )
  
  assign_user_to_turma(@user, @class)
  
  @form = Formulario.create!(
    titulo: 'Avaliação',
    deadline: 1.day.from_now
  )
  
  @form.update!(turma: @class)
  
  visit responder_form_path(@form)
end

Quando('preencho algumas questões') do
  fill_in 'Questão 1', with: 'Resposta 1'
end

Então('sou redirecionado para a lista de formulários') do
  expect(page).to have_current_path(avaliacoes_path, wait: 10)
end

Então('o card do formulário exibe {string}') do |status|
  expect(page).to have_content(status)
end

Dado('que salvei um formulário como rascunho anteriormente') do
  @class = Turma.create!(
    classCode:     'CIC0105',
    nome:     'Engenharia de Software',
    semester: '2026.1'
  )
  
  assign_user_to_turma(@user, @class)
  
  @form = Formulario.create!(
    titulo: 'Avaliação',
    deadline: 1.day.from_now
  )
  
  @form.update!(turma: @class)
  
  @draft = Resposta.create!(
    formulario: @form,
    user: @user,
    status: 'draft',
    answers: { 'q1' => 'Resposta anterior' }
  )
end

Então('vejo o formulário com os dados previamente preenchidos') do
  expect(page).to have_field(with: 'Resposta anterior')
end

Então('as respostas anteriores estão mantidas') do
  expect(page).to have_field(with: 'Resposta anterior')
end

Então('vejo um resumo no topo da página') do
  expect(page).to have_selector('.resumo-avaliacoes')
end

Então('vejo a informação {string}') do |informacao|
  expect(page).to have_content(informacao)
end

Então('vejo um percentual de progresso') do
  expect(page).to have_selector('.progress-percentage')
end

Então('vejo a aba {string} selecionada por padrão') do |aba|
  expect(page).to have_selector(".nav-tabs .active", text: aba)
end

Então('vejo a aba {string} com formulários salvos como rascunho') do |aba|
  click_link aba
  expect(page).to have_selector('.form-card')
end

Então('vejo a aba {string} com formulários já submetidos') do |aba|
  click_link aba
  expect(page).to have_selector('.form-card')
end

Então('posso clicar para mudar entre abas') do
  all('.nav-tabs a').each do |aba|
    aba.click
    expect(page).to have_selector('.tab-pane.active')
  end
end

# ==================== CENÁRIOS TRISTES ====================

Dado('que respondeu todos os formulários das suas turmas') do
  @class = Turma.create!(
    classCode:     'CIC0105',
    nome:     'Engenharia de Software',
    semester: '2026.1'
  )
  
  assign_user_to_turma(@user, @class)
  
  @form = Formulario.create!(
    titulo: 'Avaliação',
    deadline: 1.day.from_now
  )
  
  @form.update!(turma: @class)
  
  # Marca como respondido
  Resposta.create!(
    formulario: @form,
    user: @user,
    status: 'submitted'
  )
end

Então('a lista está vazia') do
  expect(page).not_to have_selector('.form-card')
end

Dado('que tentei acessar um formulário através de um link antigo') do
  # Simula tentativa de acesso
  true
end

Quando('abro o link de um formulário da turma {string} em que não estou matriculado') do |turma|
  @other_class = Turma.create!(
    classCode:     turma,
    nome:     'Outra Turma',
    semester: '2026.1'
  )
  
  @other_form = Formulario.create!(
    titulo: 'Avaliação',
    deadline: 1.day.from_now
  )
  
  @other_form.update!(turma: @other_class)
  
  visit responder_form_path(@other_form)
end

Então('sou redirecionado para a página {string}') do |pagina|
  case pagina
  when 'Avaliações'
    expect(page).to have_current_path(avaliacoes_path, wait: 10)
  end
end

Dado('que existe um formulário com deadline já vencido há 1 dia') do
  @class = Turma.create!(
    classCode:     'CIC0105',
    nome:     'Engenharia de Software',
    semester: '2026.1'
  )
  
  assign_user_to_turma(@user, @class)
  
  @expired_form = Formulario.create!(
    titulo: 'Avaliação Expirada',
    deadline: 1.day.ago
  )
  
  @expired_form.update!(turma: @class)
end

Então('o formulário expirado não aparece na lista') do
  expect(page).not_to have_content('Avaliação Expirada')
end

Dado('que tentei abrir um formulário após seu deadline') do
  @class = Turma.create!(
    classCode:     'CIC0105',
    nome:     'Engenharia de Software',
    semester: '2026.1'
  )
  
  assign_user_to_turma(@user, @class)
  
  @expired_form = Formulario.create!(
    titulo: 'Avaliação Expirada',
    deadline: 1.day.ago
  )
  
  @expired_form.update!(turma: @class)
end

Então('não consigo acessar o formulário') do
  expect(page).not_to have_selector('.questao')
end

Quando('acesso a página {string} e o servidor retorna erro') do |pagina|
  # Simula erro no servidor
  allow(Form).to receive(:for_user).and_raise(StandardError)
  visit avaliacoes_path
end

Então('nenhum formulário é exibido') do
  expect(page).not_to have_selector('.form-card')
end

Dado('que cliquei em um formulário para responder') do
  @class = Turma.create!(
    classCode:     'CIC0105',
    nome:     'Engenharia de Software',
    semester: '2026.1'
  )
  
  assign_user_to_turma(@user, @class)
  
  @form = Formulario.create!(
    titulo: 'Avaliação',
    deadline: 1.day.from_now
  )
  
  @form.update!(turma: @class)
end

Quando('a conexão com o servidor é perdida') do
  # Simula perda de conexão
  allow(page).to receive(:current_path).and_raise(Capybara::CapybaraError)
end

Então('o botão {string} é exibido') do |botao|
  expect(page).to have_button(botao)
end

Dado('que estava visualizando os detalhes de um formulário') do
  @class = Turma.create!(
    classCode:     'CIC0105',
    nome:     'Engenharia de Software',
    semester: '2026.1'
  )
  
  assign_user_to_turma(@user, @class)
  
  @form = Formulario.create!(
    titulo: 'Avaliação',
    deadline: 1.day.from_now
  )
  
  @form.update!(turma: @class)
  visit avaliacoes_path
  click_link @form.template_name
end

Quando('o administrador deleta o formulário') do
  @form.destroy
end

Quando('atualizo a página') do
  page.evaluate_script('location.reload()')
end

Dado('que estava preenchendo um formulário') do
  @class = Turma.create!(
    classCode:     'CIC0105',
    nome:     'Engenharia de Software',
    semester: '2026.1'
  )
  
  assign_user_to_turma(@user, @class)
  
  @form = Formulario.create!(
    titulo: 'Avaliação',
    deadline: 1.day.from_now
  )
  
  @form.update!(turma: @class)
  visit responder_form_path(@form)
  fill_in 'Questão 1', with: 'Minha resposta'
end

Quando('fecho a aba do navegador sem clicar em {string}') do |acao|
  # Simula fechamento sem salvar
  @saved = false
end

Quando('abro novamente o formulário') do
  visit responder_form_path(@form)
end

Então('o formulário começa vazio novamente') do
  expect(page).to have_field('Questão 1', with: '')
end

Dado('que estou preenchendo um formulário') do
  @class = Turma.create!(
    classCode:     'CIC0105',
    nome:     'Engenharia de Software',
    semester: '2026.1'
  )
  
  assign_user_to_turma(@user, @class)
  
  @form = Formulario.create!(
    titulo: 'Avaliação',
    deadline: 1.day.from_now
  )
  
  @form.update!(turma: @class)
  visit responder_form_path(@form)
end

Quando('clico em {string} e o servidor retorna erro') do |acao|
  # Simula erro no servidor ao salvar
  allow(Resposta).to receive(:create!).and_raise(StandardError)
  click_button acao
end

Então('permaneço na página de preenchimento') do
  expect(page).to have_current_path(responder_form_path(@form))
end

Então('meus dados continuam no formulário') do
  expect(page).to have_field('Questão 1', with: '')
end

Dado('que salvei 10 formulários como rascunho') do
  @class = Turma.create!(
    classCode:     'CIC0105',
    nome:     'Engenharia de Software',
    semester: '2026.1'
  )
  
  assign_user_to_turma(@user, @class)
  
  10.times do |i|
    form = Formulario.create!(
      titulo: "Avaliação #{i}",
      deadline: 1.day.from_now,
      turma: @class
    )

    pergunta = Pergunta.create!(
      formulario: form,
      enunciado: "Questão #{i + 1}",
      tipo_pergunta: 'texto',
      obrigatoria: false
    )

    Resposta.create!(
      formulario: form,
      user: @user,
      pergunta: pergunta,
      conteudo: 'Rascunho'
    )
  end
end

Quando('tento salvar outro formulário como rascunho') do
  @new_form = Formulario.create!(
    titulo: 'Avaliação Extra',
    deadline: 1.day.from_now
  )
  @new_form.update!(turma: @class)
  
  visit responder_form_path(@new_form)
  click_button 'Salvar como Rascunho'
end

Então('preciso deletar um rascunho anterior') do
  expect(page).to have_content('deletar')
end

Então('o formulário não é salvo') do
  expect(Resposta.where(formulario: @new_form).count).to eq(0)
end

Dado('que sou um Dicente') do
  @user = User.create!(
    email:                 'dicente@gmail.com',
    matricula:             '190084013',
    password:              'senha',
    password_confirmation: 'senha',
    role:                  'discente'
  )
  
  visit login_path
  fill_in 'email', with: 'dicente@gmail.com'
  fill_in 'password', with: 'senha'
  click_button 'Entrar'
end

Quando('um formulário é enviado especificamente para Docentes') do
  @class = Turma.create!(
    classCode:     'CIC0105',
    nome:     'Engenharia de Software',
    semester: '2026.1'
  )
  
  assign_user_to_turma(@user, @class)
  
  @form_docente = Formulario.create!(
    titulo: 'Avaliação para Docentes',
    deadline: 1.day.from_now
  )
  
  @form_docente.update!(turma: @class)
end

Então('esse formulário não aparece na minha lista de não respondidos') do
  visit avaliacoes_path
  expect(page).not_to have_content('Avaliação para Docentes')
end

Então('não consigo acessá-lo mesmo tendo o link direto') do
  visit responder_form_path(@form_docente)
  expect(page).to have_content('Acesso não autorizado')
end