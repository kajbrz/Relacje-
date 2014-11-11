class CreateProjekties < ActiveRecord::Migration
  def change
    create_table :projekties do |t|
      t.string :nazwa
      t.string :stan
      t.text :opis      
      t.integer :szafki_id
      t.timestamps
    end
  end
end
