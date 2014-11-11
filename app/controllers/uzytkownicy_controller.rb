# encoding: UTF-8
class UzytkownicyController < ApplicationController
  before_action :poziom1, except: [:wyloguj, :logowanie, :zaloguj, :zarejestruj, :rejestracja, :resetuj_haslo, :odzyskaj_haslo, :nowe_haslo, :zapomnialem, :zmien_haslo]
  before_action :poziom2, only: [:administracja, :administruj, :administruj_odrzuc]
  before_action :poziom3, only: [:destroy]

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
        flash[:notice] = "zaakceptowano uzytkownika"       
      else
        flash[:error] = "ten uzytkownik zostal juz zaakceptowany"
      end
    else
      flash[:error] = "brak uzytkownika o podanym ID"
    end
    redirect_to administracja_path
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
      @link = request.protocol + request.host + ":" + request.port.to_s + "/odzyskaj_haslo/" + Uzytkownicy.last.id.to_s + '/' + Uzytkownicy.last.haslo_salt

   
      params[id: @uzytkownik.id]
      params[link: @link]
      if resetuj_haslo(params)
        flash[:notice] = "na podany email wysłano link ze zmianą hasła"   
      else
        flash[:error] = "błąd wysyłania emaila"
      end
    else
      flash[:error] = "nie znaleziono uzytkownika"
      redirect_to uzytkownicy_zapomnialem_path and return
    end
    redirect_to root_path
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

  
  def resetuj_haslo(params)
      if @uzytkownik = Uzytkownicy.where(id: params[:id]).first  
        params[:user] = @uzytkownik
        if error = ResetMail.reset(params).deliver
          return true
        else

        end
      else

      end

      return false
  end

end
