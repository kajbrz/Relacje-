# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#Tworzenie super_uzytkownika
#Uzytkownicy.delete_all
#Przedmioty.delete_all
#Projekty.delete_all
#ProjektyUzytkownicy.delete_all
#Szafki.delete_all

#NIE EDYTOWAĆ -> potrzebne do działania aplikacji
unless (@sz = Szafki.where(id: 1).first)
  Szafki.create!(
    id: 1,
    miejsce: 'nieznane',
    numer: 0,
    uzytkownicy_id: 0
    )
else
  @sz.update_columns(
    miejsce: 'nieznane',
    numer: 0,
    uzytkownicy_id: 0
    )
end
@uzytkownik = Hash.new
################ END #####################

#TUTAJ NADAJEMY HASŁO
@uzytkownik[:haslo] = "Synergia"   
############# NIE EDYTOWAĆ ###############
unless (@uz = Uzytkownicy.where(id: 1).first)
  Uzytkownicy.create!(
    id: 1,
    nick: "Synergia",
    email: "synergia@synergia.pl",
    haslo: @uzytkownik[:haslo],
    status_czlonka: 'SuperAdministrator',
    ostatnie_logowanie: Time.zone.now,
    poziom_dostepu: 3
  )
else
  @uz.update_columns(
    nick: "Synergia",
    email: "synergia@synergia.pl",
    haslo: @uzytkownik[:haslo],
    status_czlonka: 'SuperAdministrator',
    ostatnie_logowanie: Time.zone.now,
    poziom_dostepu: 3 
    )
  @uz.zakoduj_haslo
  @uz.save
end
################ END #####################
#Tworzenie domyślny przedmioties



