class Agendamento < ApplicationRecord
  belongs_to :cliente
  belongs_to :funcionario
  belongs_to :servico
end
