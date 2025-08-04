class Agendamento < ApplicationRecord
  belongs_to :cliente, class_name: 'Usuario'
  belongs_to :funcionario, class_name: 'Usuario'
  belongs_to :servico

  enum status: { agendado: 0, concluido: 1, cancelado: 2 }

  # Escopos
  scope :do_dia, -> { where(data: Date.current) }
  scope :agendados, -> { where(status: :agendado) }
  scope :concluidos, -> { where(status: :concluido) }

  # Cliente
  def self.concluidos_por(usuario)
    where(cliente: usuario, status: :concluido)
  end

  # Funcionário
  def self.para_funcionario_no_dia(usuario)
    do_dia.where(funcionario: usuario)
  end

  def self.disponiveis_para_funcionario(usuario)
    horarios_ocupados = para_funcionario_no_dia(usuario).pluck(:horario)
    Horario.possiveis - horarios_ocupados
  end

  # Admin ou geral
  def self.quantidade_agendados_do_dia
    do_dia.agendados.count
  end

  def self.quantidade_concluidos
    concluido.count
  end
end
