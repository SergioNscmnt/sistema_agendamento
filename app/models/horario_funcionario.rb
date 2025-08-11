class HorarioFuncionario < ApplicationRecord
  belongs_to :usuario

  enum status: { livre: 0, reservado: 1, indisponivel: 2 }

  enum dia_da_semana: {
    domingo: 0,
    segunda: 1,
    terca:   2,
    quarta:  3,
    quinta:  4,
    sexta:   5,
    sabado:  6
  }

  validates :dia_da_semana, presence: true, inclusion: { in: dia_da_semanas.keys }
  validates :hora, :duracao_minutos, presence: true
  validates :duracao_minutos, numericality: { greater_than: 0 }
  validates :ativo, inclusion: { in: [true, false] }

  validates :hora, uniqueness: { scope: [:usuario_id, :dia_da_semana],
                                 message: "já existe um horário neste dia/horário para este funcionário" }

  scope :ativos,         -> { where(ativo: true) }
  scope :livres,         -> { where(status: :livre) }
  scope :do_dia_semana,  ->(wday) { where(dia_da_semana: wday) }

  def fim
    hora + duracao_minutos.minutes
  end

  def janela_em(data)
    inicio = Time.zone.local(data.year, data.month, data.day, hora.hour, hora.min, hora.sec)
    [inicio, inicio + duracao_minutos.minutes]
  end
end
