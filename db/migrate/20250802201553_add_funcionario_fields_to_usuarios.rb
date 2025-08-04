class AddFuncionarioFieldsToUsuarios < ActiveRecord::Migration[7.1]
  def change
    add_column :usuarios, :likes, :integer
    add_column :usuarios, :dislikes, :integer
    add_column :usuarios, :especialidades, :text
    add_column :usuarios, :data_inicio_funcao, :date
  end
end
