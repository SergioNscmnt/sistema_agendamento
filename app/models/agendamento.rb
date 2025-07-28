class Agendamento < ApplicationRecord
  belongs_to :cliente, class_name: 'Usuario'
  belongs_to :funcionario, class_name: 'Usuario'
  belongs_to :servico
end
