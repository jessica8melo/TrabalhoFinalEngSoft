# Questão pertencente a um Template de formulário
class Question < ApplicationRecord
  belongs_to :template

  validates :kind, presence: true, inclusion: { in: %w[radio text] }
  validates :text, presence: true
end
