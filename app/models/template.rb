# Template de formulário, contendo questões reutilizáveis
class Template < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :parent_template, class_name: "Template", optional: true

  has_many :versions, class_name: "Template", foreign_key: "parent_template_id"
  has_many :questions, dependent: :destroy
  has_many :forms, dependent: :destroy

  validates :nome, presence: true

  # Permite usar :name como alias de :nome para compatibilidade com specs
  alias_attribute :name, :nome
end