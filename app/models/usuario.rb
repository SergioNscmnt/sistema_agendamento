class Usuario < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  before_validation :set_default_perfil, on: :create

  enum perfil: { cliente: "cliente", funcionario: "funcionario", administrador: "admin" }

  validates :perfil, presence: true

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
