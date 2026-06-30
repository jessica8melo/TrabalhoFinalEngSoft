# Formulário de avaliação baseado em um Template, enviado para turmas
class Form < ApplicationRecord
  belongs_to :template
  has_and_belongs_to_many :turmas

  validates :template, presence: true
  validates :destinatario, inclusion: { in: %w[discente docente] }

  # Retorna true se o formulário ainda está disponível para resposta
  #
  # Argumentos: Nenhum
  # Retorno: Boolean
  # Efeitos colaterais: Nenhum
  def active?
    end_date.nil? || end_date > Time.current
  end

  # Verifica se o formulário é destinado ao papel (role) do usuário informado
  #
  # Argumentos: user (User)
  # Retorno: Boolean
  def destinado_a?(user)
    return false if user.nil?

    destinatario == user.role
  end
end
