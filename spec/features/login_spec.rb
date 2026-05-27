# encoding: utf-8
# language: pt

require 'rails_helper'

RSpec.feature "Login no sistema CAMAAR", type: :feature do
    background do
        # Usuário comum
        User.create!(
          email:           "user@gmail.com",
          matricula:       "190084006",
          password:        "senhaUser",
          password_confirmation: "senhaUser",
          role:            "discente"
        )

        # Administrador
        User.create!(
          email:           "admin@gmail.com",
          matricula:       "000000000",
          password:        "senhaAdmin",
          password_confirmation: "senhaAdmin",
          role:            "admin"
        )

        visit login_path
    end

    # ==================== CENÁRIOS FELIZES ====================

    scenario "Login bem-sucedido com e-mail válido" do
      fill_in "Email ou Matrícula", with: "user@gmail.com"
      fill_in "Senha",               with: "senhaUser"
      click_button "Entrar" 
      expect(page).to have_current_path(root_path)
      expect(page).to have_content("Login realizado com sucesso")
    end

    scenario "Login bem-sucedido com matrícula válida" do
      fill_in "Email ou Matrícula", with: "190084006"
      fill_in "Senha",               with: "senhaUser"
      click_button "Entrar"

      expect(page).to have_current_path(root_path)
      expect(page).to have_content("Login realizado com sucesso")
    end

    scenario "Login como administrador exibe menu de gerenciamento" do
      fill_in "Email ou Matrícula", with: "admin@gmail.com"
      fill_in "Senha",               with: "senhaAdmin"
      click_button "Entrar"

      expect(page).to have_current_path(root_path)
      expect(page).to have_css("nav", text: "Gerenciamento")
    end

    # ==================== CENÁRIOS TRISTES ====================

    scenario "Login com senha incorreta" do
      fill_in "Email ou Matrícula", with: "user@gmail.com"
      fill_in "Senha",               with: "senhaErrada"
      click_button "Entrar"

      expect(page).to have_current_path(login_path)
      expect(page).to have_content("Credenciais inválidas")
    end

    scenario "Login com usuário não cadastrado" do
      fill_in "Email ou Matrícula", with: "nao.cadastrado@gmail.com"
      fill_in "Senha",               with: "qualquerSenha"
      click_button "Entrar"

      expect(page).to have_current_path(login_path)
      expect(page).to have_content("Credenciais inválidas")
    end

    scenario "Login com campos vazios" do
      fill_in "Email ou Matrícula", with: ""
      fill_in "Senha",               with: ""
      click_button "Entrar"

      expect(page).to have_current_path(login_path)
      expect(page).to have_content("Preencha todos os campos obrigatórios")
    end

    scenario "Usuário comum não vê menu de gerenciamento" do
      fill_in "Email ou Matrícula", with: "user@gmail.com"
      fill_in "Senha",               with: "senhaUser"
      click_button "Entrar"

      expect(page).to have_current_path(root_path)
      expect(page).not_to have_css("nav", text: "Gerenciamento")
    end
end