# Steps genéricos compartilhados entre todas as features

Quando('preencho o campo {string} com {string}') do |campo, valor|
  fill_in campo, with: valor
end

Quando('deixo o campo {string} em branco') do |campo|
  fill_in campo, with: ''
end

Então('vejo a mensagem de sucesso {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('vejo a mensagem de erro {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

Então('vejo o botão {string}') do |botao|
  expect(page).to have_button(botao)
end