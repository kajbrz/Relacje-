class CreateSzafkis < ActiveRecord::Migration
  def change
    create_table :szafkis do |t|
      t.string :miejsce #
      t.integer :numer  #
      t.integer :uzytkownicy_id
      t.text :komentarz 
      t.timestamps
    end
  end
end
