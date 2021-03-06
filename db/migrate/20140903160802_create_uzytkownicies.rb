class CreateUzytkownicies < ActiveRecord::Migration
  def change
    create_table :uzytkownicies do |t|
      t.string :nick      
      t.string :email
      t.string :haslo
      t.string :haslo_salt
      t.boolean :reset_hasla
      t.string :status_czlonka #dowolne
      t.datetime :ostatnie_logowanie
      t.integer :poziom_dostepu 
      t.text :komentarz 
        #1-uzytkownik 2-admin (edycja + dodawanie) 3-superAdmin(usuwanie uzytkownikow/reset hasel)
      t.timestamps
    end
  end
end
