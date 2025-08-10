# app/models/agendamento.rb
class Agendamento < ApplicationRecord
  belongs_to :cliente,     class_name: 'Usuario'
  belongs_to :funcionario, class_name: 'Usuario'
  belongs_to :servico

  enum status: { agendado: 0, concluido: 1, cancelado: 2 }

  # Presenças
  validates :horario, presence: true
  validate :slot_existe_no_template

  # No mesmo dia/hora p/ o mesmo funcionário, não pode duplicar (reforça o índice)
  validates :horario, uniqueness: {
    scope: :funcionario_id,
    conditions: -> { where.not(status: :cancelado) },
    message: "já está reservado para este funcionário neste horário"
  }

  # Scopes por dia (usando intervalo do dia)
  scope :do_dia, ->(date = Time.zone.today) {
    where(horario: date.beginning_of_day..date.end_of_day)
  }
  scope :agendados, -> { where(status: :agendado) }
  scope :concluidos, -> { where(status: :concluido) }
  scope :do_funcionario, ->(u) { where(funcionario: u) }
  scope :do_cliente,     ->(u) { where(cliente: u) }

  # Relatórios
  def self.concluidos_por(usuario)
    do_cliente(usuario).concluidos
  end

  def self.para_funcionario_no_dia(usuario, date = Time.zone.today)
    do_funcionario(usuario).do_dia(date)
  end

  def slot_existe_no_template
    return if horario.blank? || funcionario_id.blank?
  
    wday = horario.wday
    t     = horario.change(sec: 0) # garante :00
  
    existe = HorarioFuncionario
               .where(usuario_id: funcionario_id, ativo: true, dia_da_semana: wday, status: :livre)
               .where(hora: t) # AR faz cast correto para :time
               .exists?
  
    errors.add(:horario, "não corresponde a um slot disponível do funcionário") unless existe
  end


  # Horários disponíveis calculados a partir do template semanal (horario_funcionarios)
  # Retorna uma lista de datetimes possíveis para a data
  def self.disponiveis_para_funcionario_no_dia(funcionario, date)
    wday = date.wday

    # slots-base (template) ativos e livres no dia da semana
    base_horas = HorarioFuncionario
                   .where(usuario_id: funcionario.id, ativo: true, dia_da_semana: wday)
                   .where(status: :livre) # se você está usando o status no template
                   .order(:hora)
                   .pluck(:hora, :duracao_minutos)

    # ocupa: horários já reservados nesse dia
    ocupados = do_funcionario(funcionario)
                 .do_dia(date)
                 .where.not(status: :cancelado)
                 .pluck(:horario)

    # monta datetimes a partir das horas base
    candidatos = base_horas.map do |(hora, _duracao)|
       Time.zone.local(date.year, date.month, date.day, hora.hour, hora.min, hora.sec)
     end
     
    ocupados = do_funcionario(funcionario)
                 .do_dia(date)
                 .where.not(status: :cancelado)
                 .pluck(:horario)

    candidatos - ocupados
  end
end
