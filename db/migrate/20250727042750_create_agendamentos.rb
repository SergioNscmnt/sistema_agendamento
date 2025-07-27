class CreateAgendamentos < ActiveRecord::Migration[7.1]
  def change
    create_table :agendamentos do |t|
      t.references :cliente, null: false, foreign_key: true
      t.references :funcionario, null: false, foreign_key: true
      t.references :servico, null: false, foreign_key: true
      t.datetime :horario
      t.string :status

      t.timestamps
    end
  end
end
