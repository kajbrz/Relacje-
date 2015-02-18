# encoding: UTF-8
class SzafkiController < ApplicationController
  #before_action :poziom_dostepu

  before_action :poziom1
  before_action :poziom2, only: [:new, :create]
  
  def index   
    if params[:szukaj] 
      @szafki = Szafki.where('miejsce LIKE ?', "%#{params[:szukaj]}").pluck(:id)
      @szafki += Szafki.where('numer LIKE ?', "%#{params[:szukaj]}").pluck(:id)
        
      if uzytkownik = Uzytkownicy.where('nick LIKE ?', "%#{params[:szukaj]}").first          
        @szafki += Szafki.where('uzytkownicy_id LIKE ?', uzytkownik.id).pluck(:id)
      end

      @szafki = Szafki.where(id: @szafki)
    else
      @szafki = Szafki.all
    end  
  end

  def show
    unless @szafka = Szafki.where(id: params[:id]).first
      flash[:error] = "nie ma takiej szafki"
      redirect_to action: :index and return
    end

    @opt = (@szafka.uzytkownicy_id != 0 && @szafka.uzytkownicy_id == @uzytkownik_id)

  end

  def edit
    if @szafka = Szafki.where(id: params[:id]).first
      stworz_tablice
      if id = Sesja.sprawdz(session[:session_id])
        @uzytkownik = Uzytkownicy.find(id)    
        unless @uzytkownik.poziom_dostepu > 1 || @szafka.uzytkownicy_id == @uzytkownik.id 
          flash[:error] = "brak dostepu"
          redirect_to szafki_path
        end
      else
        flash[:error] = "brak dostepu"
      end
    else
        flash[:error] = "nie znaleziono szafki"
    end
  end
  

  def zwroc_przedmioty
    blad = false
    unless @przedmiot = Przedmioty.where(id: params[:id]).first
      flash[:error] = "nie znaleziono przedmiotu"
      blad = true
    end

    if @przedmiot.uzytkownicy_id == 0
      flash[:error] = "nie trzeba zwracać tego przedmiotu"
      blad = true      
    end

    unless @przedmiot.uzytkownicy_id == @uzytkownik_id
      flash[:error] = "nie trzeba zwracać tego przedmiotu"
      blad = true      
    end

    unless blad
      flash[:notice] = "pomyślnie zwrócono przedmiot"
      @przedmiot.uzytkownicy_id = 0
      @przedmiot.szafki_id = @przedmiot.szafka_pierwotna
      @przedmiot.save
    end


    if @szafka = Szafki.where(id: params[:szafka_id]).first
      redirect_to szafki_path(id: @szafka.id)
    else
      redirect_to szafki_path
    end

  end

  def update
    if @szafka = Szafki.where(id: params[:id]).first    
      if id = Sesja.sprawdz(session[:session_id])
        @uzytkownik = Uzytkownicy.find(id)
        if @uzytkownik.poziom_dostepu > 1 || @szafka.uzytkownicy_id == @uzytkownik.id 
          if @uzytkownik.poziom_dostepu > 1
            @szafka.update(params.require(:szafki).permit(:komentarz, :miejsce, :numer, :uzytkownicy_id))
          else
            @szafka.update(params.require(:szafki).permit(:komentarz, :miejsce, :numer))
          end
        else
          flash[:error] = "brak dostepu"
        end 
      else
        flash[:error] = "brak dostepu"
      end
    else
      flash[:error] = "nie znaleziono szafki"  
      redirect_to szafki_path    
    end
    redirect_to szafki_path(id: @szafka.id)
  end

  def new    
    stworz_tablice
  end

  def create
    @szafka = Szafki.create(params.require(:szafki).permit(:komentarz, :miejsce, :numer, :uzytkownicy_id))    
    unless @szafka.valid? 
      flash[:error] = @szafka.errors.full_messages
      redirect_to szafki_new_path and return
    end
    redirect_to szafki_path and return
  end

  def destroy
    if @szafka = Szafki.where(id: params[:id]).first
      if @szafka.id == 1
        flash[:error] = "tej szafki nie można usunąć"
        redirect_to szafki_path and return
      elsif @poziom_dostepu > 1 || @szafka.uzytkownicy_id == @uzytkownik_id           
        @szafka.destroy
        flash[:notice] = "szczesliwe usunieto" 
      else
        flash[:error] = "brak dostepu"
      end
    else
      flash[:error] = "nie znaleziono"
    end  
    redirect_to szafki_path
  end

  def stworz_tablice    
    @menu_stan = [['zajety',1],['wypozyczalny',2],['utylizacja',3]]

    @menu_szafki = [['brak', 0]]
    Szafki.all.each {|f| @menu_szafki+=[[f.miejsce.to_s + "(" + f.numer.to_s + "," +")" , f.id]]}

    @menu_uzytkownicy = [['brak', 0]]
    Uzytkownicy.all.each { |f| @menu_uzytkownicy+=[[f.nick, f.id]] }
    
    @menu_projekty = [['brak', 0]]
    Projekty.all.each { |f| @menu_projekty+=[[f.nazwa, f.id]] }
  end

  private

  def poziom1
    wejscie(1, root_path)
  end
  def poziom2
    wejscie(2, szafki_path)
  end
  def poziom3
    wejscie(3, szafki_path)
  end

end
