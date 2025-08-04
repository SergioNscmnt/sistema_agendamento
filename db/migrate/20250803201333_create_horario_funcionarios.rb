class CreateHorarioFuncionarios < ActiveRecord::Migration[7.1]
  def change
    create_table :horario_funcionarios do |t|
      t.references :usuario, null: false, foreign_key: true
      t.integer :dia_da_semana
      t.time :hora
      t.boolean :ativo

      t.timestamps
    end
  end
end
