class CreatePrzedmioties < ActiveRecord::Migration
  def change
    create_table :przedmioties do |t|
      t.string :typ
      t.string :nazwa
      t.string :model
      t.integer :stan  # 1-zajety 2-wypozyczalny 3-utylizacja      
      t.integer :uzytkownicy_id
      t.integer :szafki_id
      t.integer :szafka_pierwotna
      t.integer :projekty_id
      t.text :komentarz
      t.timestamps 
    end
  end
end
