class CreateHorarios < ActiveRecord::Migration[7.1]
  def change
    create_table :horarios do |t|
      t.string :hora

      t.timestamps
    end
  end
end
