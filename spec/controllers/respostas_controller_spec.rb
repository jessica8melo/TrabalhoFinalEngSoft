require 'rails_helper'

RSpec.describe RespostasController, type: :controller do
  let(:admin_user) { User.create!(email: 'admin@test.com', matricula: '123', password: 'password', password_confirmation: 'password', role: 'admin') }
  
  let(:disciplina) { Disciplina.create!(name: 'Eng Soft', code: 'ES01') }
  let(:turma) { Turma.create!(classCode: 'T01', semester: '2024.1', time: '14h', disciplina_id: disciplina.id) }
  let(:formulario) { Formulario.create!(titulo: 'Avaliação', descricao: 'Desc', deadline: 1.day.from_now, turma_id: turma.id) }
  let(:pergunta_obrigatoria) { Pergunta.create!(enunciado: 'Q1', formulario_id: formulario.id, tipo_pergunta: 'texto', obrigatoria: true) }
  let(:pergunta_opcional) { Pergunta.create!(enunciado: 'Q2', formulario_id: formulario.id, tipo_pergunta: 'texto', obrigatoria: false) }

  before do
    session[:user_id] = admin_user.id
    pergunta_obrigatoria
    pergunta_opcional
  end

  describe "POST #create" do
    it "saves respostas successfully" do
      post :create, params: { 
        formulario_id: formulario.id, 
        respostas: { pergunta_obrigatoria.id.to_s => "Resposta Q1" }
      }
      expect(response).to redirect_to(formularios_path)
      expect(flash[:notice]).to eq("Avaliação submetida com sucesso!")
      expect(Resposta.count).to eq(1)
    end

    it "fails if deadline is past" do
      formulario.update!(deadline: 1.day.ago)
      post :create, params: { 
        formulario_id: formulario.id, 
        respostas: { pergunta_obrigatoria.id.to_s => "Resposta Q1" }
      }
      expect(response).to redirect_to(formularios_path)
      expect(flash[:alert]).to eq("Avaliação encerrada")
    end

    it "fails if already answered" do
      Resposta.create!(formulario: formulario, user: admin_user, pergunta: pergunta_obrigatoria, conteudo: "Antiga")
      post :create, params: { 
        formulario_id: formulario.id, 
        respostas: { pergunta_obrigatoria.id.to_s => "Resposta Q1" }
      }
      expect(response).to redirect_to(formularios_path)
      expect(flash[:alert]).to eq("Você já respondeu esta avaliação")
    end

    it "fails if missing mandatory answers" do
      post :create, params: { 
        formulario_id: formulario.id, 
        respostas: { pergunta_obrigatoria.id.to_s => "" }
      }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash[:alert]).to eq("Por favor, responda todas as questões obrigatórias")
    end

    it "handles unexpected errors" do
      allow(Resposta).to receive(:transaction).and_raise(StandardError.new("Database error"))
      post :create, params: { 
        formulario_id: formulario.id, 
        respostas: { pergunta_obrigatoria.id.to_s => "Resposta Q1" }
      }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash[:alert]).to eq("Erro ao enviar avaliação: Database error")
    end
  end
end
