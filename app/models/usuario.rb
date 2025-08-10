class Usuario < ApplicationRecord
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_validation :set_default_perfil, on: :create

  has_many :horarios_funcionarios, dependent: :destroy
  has_many :agendamentos_como_cliente,     class_name: "Agendamento", foreign_key: :cliente_id,     dependent: :nullify
  has_many :agendamentos_como_funcionario, class_name: "Agendamento", foreign_key: :funcionario_id, dependent: :nullify

  has_one_attached :avatar

  enum perfil: { cliente: "cliente", funcionario: "funcionario", administrador: "admin" }

  scope :funcionarios, -> { where(perfil: 'funcionario') }
  scope :clientes, -> { where(perfil: 'cliente') }
  scope :administradores, -> { where(perfil: 'admin') }

  with_options if: :funcionario? do
    validates :especialidades,
              presence: true

    validates :data_inicio_funcao,
              presence: true

    validates :likes, :dislikes,
              presence: true,
              numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  end

  validates :perfil, presence: true

  def agendamentos_concluidos
    Agendamento.where(cliente_id: id, status: :concluido)
  end

  def ultimos_servicos(limit = 5)
    Agendamento.where(cliente_id: id)
               .includes(:servico)
               .order(horario: :desc)
               .limit(limit)
  end

  def agendamentos_do_dia(data = Time.zone.today)
    Agendamento.where(funcionario_id: id, horario: data.beginning_of_day..data.end_of_day)
               .order(:horario)
  end

  def horarios_disponiveis(data = Time.zone.today)
    Agendamento.disponiveis_para_funcionario_no_dia(self, data)
  end

  def horarios_disponiveis_para(funcionario, data = Time.zone.today)
    Agendamento.disponiveis_para_funcionario_no_dia(funcionario, data)
  end
  def cliente?
    perfil == "cliente"
  end

  def funcionario?
    perfil == "funcionario"
  end

  def administrador?
    perfil == "administrador"
  end

  private

  def set_default_perfil
    self.perfil ||= "cliente"
  end

end
