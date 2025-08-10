class AddStatusToHorarioFuncionarios < ActiveRecord::Migration[7.1]
  def change
    add_column :horario_funcionarios, :status, :integer
    add_column :horario_funcionarios, :duracao_minutos, :integer
  end
end
