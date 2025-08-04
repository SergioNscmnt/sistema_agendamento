class HorarioFuncionario < ApplicationRecord
  belongs_to :usuario

  validates :dia_da_semana, :hora, presence: true
  validates :dia_da_semana, inclusion: { in: 0..6 }

  enum dia_semana: {
    domingo: 0,
    segunda: 1,
    terca: 2,
    quarta: 3,
    quinta: 4,
    sexta: 5,
    sabado: 6
  }
end
