class Usuario < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_validation :set_default_perfil, on: :create

  has_many :horarios_funcionarios, dependent: :destroy


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
    Agendamento.where(cliente: self, status: :concluido)
  end

  def ultimos_servicos
    Agendamento.where(cliente: self, status: :concluido)
               .includes(:servico)
               .order(created_at: :desc)
               .limit(5)
  end

  def agendamentos_do_dia
    Agendamento.where(funcionario: self, data: Date.current)
  end

  def horarios_disponiveis_para(dia = Date.current)
    horarios_funcionarios
      .where(dia_da_semana: dia.wday, ativo: true)
      .order(:hora)
  end

  def cliente?
    perfil == "cliente"
  end

  def funcionario?
    perfil == "funcionario"
  end

  def administrador?
    perfil == "admin"
  end

  private

  def set_default_perfil
    self.perfil ||= "cliente"
  end

end
