class CreateServicos < ActiveRecord::Migration[7.1]
  def change
    create_table :servicos do |t|
      t.string :nome
      t.integer :duracao
      t.decimal :preco

      t.timestamps
    end
  end
end
