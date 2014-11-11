class CreateProjektyUzytkownicies < ActiveRecord::Migration
  def change
    create_table :projekty_uzytkownicies, id: false do |t|
      t.integer :uzytkownicy_id
      t.integer :projekty_id
      t.string :rola
      t.timestamps 
    end
  end
end
