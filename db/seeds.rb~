# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#Tworzenie super_uzytkownika
Uzytkownicy.delete_all
Przedmioty.delete_all
Projekty.delete_all
ProjektyUzytkownicy.delete_all
Szafki.delete_all

Szafki.create!(
  id: 1,
  miejsce: 'nieznane',
  numer: 0,
  uzytkownicy_id: 0
)

Przedmioty.create!(
  id: 1,
  typ: 'elektronika',
  nazwa: 'tranzystor',
  model: 'BC308',
  stan: 2,
  uzytkownicy_id: 0,#0 brak przynaleznosci do zadnego uzytkownika
  szafki_id: 0, #0 brak przynaleznosci do zadnej szafki
  projekty_id: 0 #0 brak przynaleznosci do zadnego projektu
)
@uzytkownik = Hash.new

@uzytkownik[:nick] = "Synergia"   
@uzytkownik[:email] = "synergia@synergia.pl"   
@uzytkownik[:haslo] = "Synergia"   
@uzytkownik[:ostatnie_logowanie] = Time.zone.now   
@uzytkownik[:poziom_dostepu] = "3" 
@uzytkownik[:status_czlonka] = "SuperAdministrator"


Uzytkownicy.create!(
  id: 1,
  nick: @uzytkownik[:nick],
  email: @uzytkownik[:email],
  haslo: @uzytkownik[:haslo],
  status_czlonka: @uzytkownik[:status_czlonka],
  ostatnie_logowanie: @uzytkownik[:ostatnie_logowanie],
  poziom_dostepu: @uzytkownik[:poziom_dostepu]
)

#Tworzenie domyślny przedmioties



