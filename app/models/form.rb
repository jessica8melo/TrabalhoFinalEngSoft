# Formulário de avaliação baseado em um Template, enviado para turmas
class Form < ApplicationRecord
  belongs_to :template
  has_and_belongs_to_many :turmas

  validates :template, presence: true

  # Retorna true se o formulário ainda está disponível para resposta
  #
  # Argumentos: Nenhum
  # Retorno: Boolean
  # Efeitos colaterais: Nenhum
  def active?
    end_date.nil? || end_date > Time.current
  end
end
