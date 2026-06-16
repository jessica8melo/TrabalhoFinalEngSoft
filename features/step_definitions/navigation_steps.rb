# encoding: utf-8

Dado('estou na página de {string}') do |pagina|
  case pagina
  when 'Gerenciamento - Usuários'
    visit admin_imports_path
  when 'página de login'
    visit login_path
  when 'Avaliações'
    visit formularios_path
  end
end
