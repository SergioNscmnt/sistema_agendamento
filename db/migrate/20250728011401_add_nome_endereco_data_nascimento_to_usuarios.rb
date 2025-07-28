class AddNomeEnderecoDataNascimentoToUsuarios < ActiveRecord::Migration[7.1]
  def change
    add_column :usuarios, :nome, :string
    add_column :usuarios, :endereco, :string
    add_column :usuarios, :data_nascimento, :date
  end
end
