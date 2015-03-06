# encoding: UTF-8
class UzytkownicyController < ApplicationController
  before_action :poziom1, except: [:wyloguj, :logowanie, :zaloguj, :zarejestruj, :rejestracja, :resetuj_haslo, :odzyskaj_haslo, :nowe_haslo, :zapomnialem, :zmien_haslo]
  before_action :poziom2, only: [:administracja, :edit, :administruj, :administruj_odrzuc, :lista, :pobierz, :zaladuj, :kopia]
  before_action :poziom3, only: [:destroy]

  def index
    @uzytkownicy = Uzytkownicy.all
  end
  
  def update 
    begin
      @uzytkownik = Uzytkownicy.find(params[:id])
      
      @uzytkownik.update_attributes(params.require(:uzytkownik).permit(:status_czlonka, :komentarz))
    rescue
      flash[:error] = "Nie znaleziono uzytkownika"
      redirect_to root_path and return
    end
    redirect_to root_path
  end
  
  def edit
    begin
      @uzytkownik = Uzytkownicy.find(params[:id])
    rescue
      flash[:error] = "Nie znaleziono uzytkownika"
      redirect_to root_path and return
    end
  end

  def show
    begin
      @uzytkownik = Uzytkownicy.find(params[:id])
    rescue
      flash[:error] = "Nie znaleziono uzytkownika"
      redirect_to root_path and return
    end
  end 

  def destroy
    if @uzytkownik = Uzytkownicy.where(id: params[:id]).first
      if @uzytkownik.delete 
        flash[:notice] = "usunięto użytkownika"
      end
    else
      flash[:error] = "nie znaleziono użytkownika"      
    end
    redirect_to uzytkownicy_path
  end

  def logowanie
    redirect_to root_path and return if Sesja.sprawdz(session[:session_id])
  end

  def rejestracja
    redirect_to root_path and return if Sesja.sprawdz(session[:session_id])
  end

  def zaloguj
    if @uzytkownik = Uzytkownicy.autoryzacja(params[:logowanie][:email],params[:logowanie][:haslo])
      reset_session
      Sesja.utworz_sesje(@uzytkownik. id, session[:session_id])
      flash[:notice] = "Witamy!"           
    else
      flash[:error] = "Nieprawidłowa nazwa użytkownika bądź hasło"
    end
    
    redirect_to root_path
  end

  def zarejestruj   
    if params[:rejestracja][:haslo] != params[:rejestracja][:haslo2]
      flash[:error] = "Hasla sa niezgodne"
      redirect_to :rejestracja and return
    end
    uzytkownik = Uzytkownicy.create(
        nick: params[:rejestracja][:nick],
        email: params[:rejestracja][:email],
        haslo: params[:rejestracja][:haslo],
        status_czlonka: 'rekrut',
        ostatnie_logowanie: Time.zone.now,
        poziom_dostepu: 0)
    if uzytkownik.invalid?
      flash[:error] = uzytkownik.errors.full_messages
      redirect_to :rejestracja and return    
    end
    redirect_to action: :logowanie
  end


  def wyloguj
    Sesja.zakoncz_sesje(session[:session_id])
    redirect_to root_path
  end

  def administracja
    @uzytkownicy = Uzytkownicy.where(poziom_dostepu: 0)
    
  end

  def administruj_odrzuc
    if @uzytkownik = Uzytkownicy.where(id: params[:id]).first
      if @uzytkownik.poziom_dostepu == 0 
        @uzytkownik.delete
        flash[:notice] = "odrzucono uzytkownika"       
      else
        flash[:error] = "ten uzytkownik zostal juz odrzucony"
      end
    else
      flash[:error] = "brak uzytkownika o podanym ID"
    end
    redirect_to administracja_path
  end

  def administruj
    if @uzytkownik = Uzytkownicy.where(id: params[:id]).first
      if @uzytkownik.poziom_dostepu == 0 
        @uzytkownik.update(poziom_dostepu: 1)
        @uzytkownik.utworz_szafke
        flash[:notice] = "zaakceptowano uzytkownika"       
      else
        flash[:error] = "ten uzytkownik zostal juz zaakceptowany"
      end
    else
      flash[:error] = "brak uzytkownika o podanym ID"
    end
    redirect_to administracja_path
  end  

  def odzyskaj_haslo
    if @uzytkownik = Uzytkownicy.where(id: params[:id]).where(haslo_salt: params[:salt]).first
     
    else
      flash[:error] = "nie znaleziono użytkownika"      
      redirect_to root_path
    end    
  end


  def nowe_haslo 
    if @uzytkownik = Uzytkownicy.where(id: params[:odzyskaj_haslo][:uzytkownik]).where(haslo_salt: params[:odzyskaj_haslo][:salt]).first
      if params[:odzyskaj_haslo].length >=3
        if params[:odzyskaj_haslo][:haslo2] == params[:odzyskaj_haslo][:haslo]
         @uzytkownik.haslo = params[:odzyskaj_haslo][:haslo]
         @uzytkownik.zakoduj_haslo
         if @uzytkownik.save
          flash[:notice] = "pomyślnie zmieniono hasło"
         end
        else
          flash[:error] = "hasła są różne"
        end    
      else
        flash[:error] = "hasło było za krótkie"
      end   
    else
      flash[:error] = "nie znaleziono użytkownika"      
    end
    redirect_to root_path   
  end

  def zapomnialem

  end


  def zmien_haslo 
    if @uzytkownik = Uzytkownicy.where(email: params[:zapomnialem][:email]).first
      @link = request.protocol + request.host + ":" + request.port.to_s + "/odzyskaj_haslo/" + @uzytkownik.id.to_s + '/' + @uzytkownik.haslo_salt

      param = {id: @uzytkownik.id, link: @link }
      puts "#" * 3000 + param.to_s
      if resetuj_haslo(param)
        flash[:notice] = "w ciągu kilku sekund powinieneś dostać link ze zmianą hasła"     
      else
        flash[:error] = "błąd wysyłania emaila"
      end
    else
      flash[:error] = "nie znaleziono uzytkownika"
      redirect_to uzytkownicy_zapomnialem_path and return
    end
    redirect_to root_path
  end

  def kopia
    flash[:notice] = "Tworzenie kopii w toku" 
 
    t = Thread.new do
      utworz_kopie(params[:metoda])
    end
    Semafor.dodajWatek(t)

    redirect_to administracja_path
  end

  def zaladuj
    if (params[:plik] == nil)
      flash[:error] = "nie wybrano pliku"
      redirect_to administracja_path and return
    end
    flash[:notice] = "Trwa ładowanie "
    
    case params[:wartosc].to_i
    when 1
      flash[:notice] += " przedmiotów"
      t = Thread.new do
        dodaj_przedmioty(params[:plik])
      end
    when 2
      flash[:notice] += " projektów"
      t = Thread.new do
        dodaj_projekty(params[:plik])
      end
    when 3
      flash[:notice] += " całej bazy danych (wymaga ponownego logowania)"
      #t = Thread.new do
         odzyskaj_baze_danych(params[:plik])
      #end
    end
   #Semafor.dodajWatek(t)
    redirect_to administracja_path
  end


  def lista
    unless params[:link]
      params[:link] = ""
    end
    params[:link].slice!("kopie")
    linkTemp = "kopie" + params[:link] + "/*"
    flash[:notice] = "Link: " + linkTemp
    if (@listaFP = Dir.glob(linkTemp)).size == 0 
      @listaFP = Dir.glob('kopie/*')
    end
    @listaFP.reverse!
    #@linkpowrot = File.expand_path("..", linkTemp)
    @linkpowrot = Pathname.new(linkTemp).parent.parent
    puts "$"*100 + @linkpowrot.to_s
  end

  def pobierz
    flash[:notice] = "Pobieranie: " + params[:link]

    send_file(File.new(params[:link], "r"))

    #redirect_to uzytkownicy_lista_path and return
  end

  private   
  def poziom1
    wejscie(1, root_path)
  end
  def poziom2
    wejscie(2, uzytkownicy_path)
  end
  def poziom3
    wejscie(3, uzytkownicy_path)
  end

  
  def resetuj_haslo(param)
    if @uzytkownik = Uzytkownicy.where(id: param[:id]).first  
      param[:user] = @uzytkownik
      Thread.new do
	     ResetMail.reset(param).deliver  
      end
	    return true
    else
      return false
    end
  end

  def utworz_kopie(param)
    case param
      when "przedmioty" 
        nazwa_pliku = Time.now.inspect.split
        nazwa_pliku = "kopie/przedmioty/"+ nazwa_pliku[0]+ " " + nazwa_pliku[1].delete(":") + ".txt"
        dirname = File.dirname(nazwa_pliku)
        unless File.directory?(dirname)
         FileUtils.mkdir_p(dirname)
        end 

        f = File.new(Pathname.new(nazwa_pliku), "w")
        Przedmioty.all.each do |pt|
         ciag = pt.id.to_s + "|" +pt.typ + "|" + pt.nazwa + "|" +pt.model + "|" +pt.stan.to_s + "|" +pt.uzytkownicy_id.to_s + "|" +pt.szafki_id.to_s + "|" + pt.szafka_pierwotna.to_s + "|" + pt.projekty_id.to_s + "|" +pt.komentarz.to_s.delete("|") + "\n"
      
         ciag = ciag.delete("\r").gsub(/\n/, ' ')
         ciag += "\n"

         f.write(ciag)  
        end
        f.close
      when "projekty" 
        nazwa_pliku = Time.now.inspect.split
        nazwa_pliku = "kopie/projekty/"+ nazwa_pliku[0]+ " " + nazwa_pliku[1].delete(":") + ".txt"
        dirname = File.dirname(nazwa_pliku)
        unless File.directory?(dirname)
         FileUtils.mkdir_p(dirname)
        end 

        f = File.new(Pathname.new(nazwa_pliku), "w")
        Projekty.all.each do |pt|
         ciag = pt.id.to_s + "|" +pt.nazwa + "|" +pt.stan + "|" +pt.opis.to_s + "|" +pt.szafki_id.to_s + "\n"
         
         ciag = ciag.delete("\r").gsub(/\n/, ' ')
         ciag += "\n"
         f.write(ciag)  
        end
        f.close
      when "uzytkownicy" 
        nazwa_pliku = Time.now.inspect.split
        nazwa_pliku = "kopie/uzytkownicy/"+ nazwa_pliku[0]+ " " + nazwa_pliku[1].delete(":") + ".txt"
        dirname = File.dirname(nazwa_pliku)
        unless File.directory?(dirname)
         FileUtils.mkdir_p(dirname)
        end 

        f = File.new(Pathname.new(nazwa_pliku), "w")
        Uzytkownicy.all.each do |pt|
         ciag = pt.id.to_s + "|" +pt.nick + "|" +pt.email + "|" +pt.haslo + "|" +pt.haslo_salt.to_s + "|" +pt.reset_hasla.to_s + "|" +pt.status_czlonka + "|" + pt.poziom_dostepu.to_s + "|" +pt.komentarz.to_s.delete("|") + "\n"        
         
         ciag = ciag.delete("\r").gsub(/\n/, ' ')
         ciag += "\n"
         f.write(ciag)            
        end
        f.close
      when "cala"
        nazwa_pliku = Time.now.inspect.split
        nazwa_pliku = "kopie/cala_baza/"+ nazwa_pliku[0]+ " " + nazwa_pliku[1].delete(":") + ".txt"
        dirname = File.dirname(nazwa_pliku)
        unless File.directory?(dirname)
         FileUtils.mkdir_p(dirname)
        end 

        f = File.new(Pathname.new(nazwa_pliku), "w")
        ##########################
        f.write("\n////PRZEDMIOTY" + "\n")
        Przedmioty.all.each do |pt|
         ciag = pt.id.to_s + "|" +pt.typ + "|" +pt.nazwa + "|" +pt.model + "|" +pt.stan.to_s + "|" +pt.uzytkownicy_id.to_s + "|" +pt.szafki_id.to_s + "|" + pt.projekty_id.to_s + "|" +pt.komentarz.to_s.delete("|") + "\n"
         #ciag = ciag.delete("\r").gsub(/\n/, ' ')
         ciag += "\n"
         puts ciag
         f.write(ciag)  
        end

        f.write("////UZYTKOWNICY"+ "\n")
        Uzytkownicy.all.each do |pt|
         ciag = pt.id.to_s + "|" +pt.nick + "|" +pt.email + "|" +pt.haslo + "|" +pt.haslo_salt.to_s + "|" +pt.reset_hasla.to_s + "|" +pt.status_czlonka + "|" + pt.poziom_dostepu.to_s + "|" +pt.komentarz.to_s.delete("|") + "\n"        
         ciag = ciag.delete("\r").gsub(/\n/, ' ')
         ciag += "\n"
         f.write(ciag)            
        end

        f.write("////PROJEKTY" + "\n")
        Projekty.all.each do |pt|
         ciag = pt.id.to_s + "|" +pt.nazwa + "|" +pt.stan + "|" +pt.opis.to_s + "|" +pt.szafki_id.to_s + "\n"
         ciag = ciag.delete("\r").gsub(/\n/, ' ')
         ciag += "\n"
         
         f.write(ciag)  
        end

        f.write("////PROJEKTY_UZYTKOWNICY" + "\n")
        ProjektyUzytkownicy.all.each do |pt|
         ciag = pt.uzytkownicy_id.to_s + "|" +pt.projekty_id.to_s + "|" +pt.rola + "\n" 
         
         ciag = ciag.delete("\r").gsub(/\n/, ' ')
         ciag += "\n"
         
         f.write(ciag)            
        end

        f.write("////SZAFKI" + "\n")
        Szafki.all.each do |pt|
         ciag = pt.id.to_s + "|" +pt.miejsce + "|" +pt.numer.to_s + "|" +pt.uzytkownicy_id.to_s + "|" +pt.komentarz.to_s.delete("|")
         
         ciag = ciag.delete("\r").gsub(/\n/, ' ')
         ciag += "\n"
         
         f.write(ciag)  
        end
        #############################
        f.close
      end
    end
  end

  def dodaj_przedmioty(param)
    param.read.lines do |line| 
      podzielonaLinia = line.delete("\n").delete("\r").split("|")

      a = Przedmioty.new

      #a.id = podzielonaLinia[0]
      a.typ = podzielonaLinia[1]
      a.nazwa = podzielonaLinia[2]
      a.model = podzielonaLinia[3]
      a.stan = podzielonaLinia[4]
      a.uzytkownicy_id = podzielonaLinia[5]
      a.szafki_id = podzielonaLinia[6]
      a.projekty_id = podzielonaLinia[7]
      a.komentarz = podzielonaLinia[8]

      a.save!  
    end
  end

  def dodaj_projekty(param)
    param.read.lines do |line|
      podzielonaLinia = line.delete("\n").split("|")
      if podzielonaLinia.size != 5
        next
      end
      a = Projekty.new
      #ciag = pt.id.to_s + "|" +pt.nazwa + "|" +pt.stan + "|" +pt.opis.to_s + "|" +pt.szafki_id.to_s + "\n"
         
      #a.id = podzielonaLinia[0]
      a.nazwa = podzielonaLinia[1]
      a.stan = podzielonaLinia[2]
      a.opis = podzielonaLinia[3]
      a.szafki_id = podzielonaLinia[4]

      a.save!  
    end
  end

  def odzyskaj_baze_danych(param)
    utworz_kopie("cala")
    load "#{Rails.root}/db/seeds.rb"

    Przedmioty.delete_all

    Projekty.delete_all

    Uzytkownicy.delete_all

    ProjektyUzytkownicy.delete_all

    Szafki.delete_all
    aktualny_stan = "none" ## Opisać to
    param.read.lines do |line|
      if(line[0] == "/" && line[1] == "/" && line[2] == "/" && line[3] == "/" )
        aktualny_stan = line[4..30].chop.delete(" ")
        next
      else
        next if(aktualny_stan == "none")
        podzielonaLinia = line.delete("\n").split("|")
        
        if (aktualny_stan == "PRZEDMIOTY")
          puts "#"*80 + podzielonaLinia.count.to_s
          a = Przedmioty.new(
            #id: podzielonaLinia[0].to_i,
            typ: podzielonaLinia[1],
            nazwa: podzielonaLinia[2],
            model: podzielonaLinia[3],
            stan: podzielonaLinia[4].to_i,
            uzytkownicy_id: podzielonaLinia[5].to_i,
            szafki_id: podzielonaLinia[6].to_i,
            projekty_id: podzielonaLinia[7].to_i,
            komentarz: podzielonaLinia[8]
          )
          a.update(id: podzielonaLinia[0])
        elsif (aktualny_stan == "PROJEKTY")    
          a = Projekty.new(
            #id: podzielonaLinia[0].to_i,
            nazwa: podzielonaLinia[1],
            stan: podzielonaLinia[2],
            opis: podzielonaLinia[3],
            szafki_id: podzielonaLinia[4].to_i,
          )
          a.update(id: podzielonaLinia[0])
        elsif (aktualny_stan == "UZYTKOWNICY")
          if(podzielonaLinia[0].to_i == 1)
            next
          end
          a = Uzytkownicy.new(
            #id: podzielonaLinia[0].to_i,
            nick: podzielonaLinia[1],
            email: podzielonaLinia[2],
            haslo: podzielonaLinia[3],
            haslo_salt: podzielonaLinia[4],
            reset_hasla: podzielonaLinia[5],
            status_czlonka: podzielonaLinia[6],
            poziom_dostepu: podzielonaLinia[7].to_i,
            komentarz: podzielonaLinia[8]
          ) 
          a.update(id: podzielonaLinia[0])
        elsif (aktualny_stan == "PROJEKTY_UZYTKOWNICY")
          a = ProjektyUzytkownicy.new(
            uzytkownicy_id:  podzielonaLinia[0].to_i,
            projekty_id:  podzielonaLinia[1].to_i,
            rola:  podzielonaLinia[2]
          )
          a.update(id: podzielonaLinia[0])
        elsif (aktualny_stan == "SZAFKI")
          if(podzielonaLinia[0].to_i == 1)
            next
          end
          a = Szafki.new(
            #id: podzielonaLinia[0].to_i,
            miejsce: podzielonaLinia[1],
            numer: podzielonaLinia[2].to_i,
            uzytkownicy_id: podzielonaLinia[3].to_i,
            komentarz: podzielonaLinia[4]
          )
          a.update(id: podzielonaLinia[0])
        end
        a.save 
      end
    end
  end
