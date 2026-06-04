require 'rails_helper'

RSpec.describe SigaaImporter do
  describe '.import_classes' do
    let(:json_content) do
      [
        {
          "code": "CIC0105",
          "name": "ENGENHARIA DE SOFTWARE",
          "class": {
            "classCode": "TA",
            "semester": "2021.2",
            "time": "35M12"
          }
        }
      ].to_json
    end

    it 'creates a new disciplina and turma' do
      expect {
        SigaaImporter.import_classes(json_content)
      }.to change(Disciplina, :count).by(1)
       .and change(Turma, :count).by(1)
      
      disciplina = Disciplina.find_by(code: 'CIC0105')
      expect(disciplina.name).to eq('ENGENHARIA DE SOFTWARE')
      
      turma = Turma.find_by(classCode: 'TA', disciplina: disciplina)
      expect(turma.semester).to eq('2021.2')
    end

    it 'returns success message' do
      result = SigaaImporter.import_classes(json_content)
      expect(result[:success]).to be true
      expect(result[:message]).to include("Dados de turmas importados com sucesso")
    end

    it 'returns error for invalid JSON' do
      result = SigaaImporter.import_classes("invalid json")
      expect(result[:success]).to be false
      expect(result[:message]).to include("Erro na estrutura do arquivo")
    end
  end
end
