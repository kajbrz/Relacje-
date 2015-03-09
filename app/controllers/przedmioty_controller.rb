# encoding: UTF-8
class PrzedmiotyController < ApplicationController
  before_action :poziom1
  before_action :poziom2, only: [:new, :create, :destroy, :destroy_all, :update, :edit]

  def index    
    if params[:szukaj] 
      @przedmioty = Przedmioty.where('nazwa LIKE ?', "%#{params[:szukaj]}").pluck(:id)
      @przedmioty += Przedmioty.where('typ LIKE ?', "%#{params[:szukaj]}").pluck(:id)
      @przedmioty += Przedmioty.where('model LIKE ?', "%#{params[:szukaj]}").pluck(:id)

      @przedmioty = Przedmioty.where(id: @przedmioty).paginate(:page => params[:page], :per_page => 50) #group(:typ, :nazwa, :model)
    else
      if params[:wybrane]
        @przedmioty = Przedmioty.where(id: session[:wybrane_przedmioty]).paginate(:page => params[:page], :per_page => 50)       
      else
        @przedmioty = Przedmioty.paginate(:page => params[:page], :per_page => 50) #group(:typ, :nazwa, :model)
      end
    end  

    if (session[:grupuj] == true)
      @przedmioty = @przedmioty.select(:typ, :nazwa, :model, :stan).group(:typ, :nazwa, :model, :stan)
      @ilosc = @przedmioty.size
      #@przedmioty.group!(:typ, :nazwa, :model)
      #@przedmioty.group!(:id, :typ)
    end
  end

  def show
    begin
      @przedmiot = Przedmioty.find(params[:id])
      stworz_tablice     
    rescue
      flash[:error] = 'Nie znaleziono przedmiotu'
      redirect_to przedmioty_index_path
    end
  end

  
  def new
    stworz_tablice 
  end

  def edit
    stworz_tablice
    @przedmiot = Przedmioty.find(params[:id]) 
  end

  def update
    blad = false
    unless @przedmiot = Przedmioty.where(id: params[:id]).first
      blad = true
    end
    unless blad
      b= @przedmiot.update(params.require(:przedmioty).permit(:typ, :nazwa, :komentarz, :model, :stan, :uzytkownicy_id, :projekty_id, :szafki_id)) 
      if b == false
        flash[:error] = "nie możesz zostawić pustych pól"
      end
      redirect_to przedmioty_show_path(id: @przedmiot.id) and return
    end
    redirect_to przedmioty_index_path
  end     

  def create
    @param = params.require(:przedmiot).permit(:typ, :nazwa, :model, :stan, :komentarz)
    @param[:uzytkownicy_id] = 0
    @param[:szafki_id] = 0
    if @przedmiot = Przedmioty.create(@param)        
      if ((il = params[:przedmiot][:ilosc].to_i) > 0)
        @przedmiot_arr = []
        (il-1).times { @przedmiot_arr += [@param.dup] }
        #render plain: @przedmiot_arr and return
        Przedmioty.create(@przedmiot_arr)
      end
      flash[:notice] = "utworzono przedmioty"
    else
      flash[:error] = "nie mozna bylo utworzyc"
    end
    redirect_to przedmioty_index_path
  end

  def destroy
    if @przedmiot = Przedmioty.where(id: params[:id]).first
      @przedmiot.delete
    else
      flash[:error] = "Nie znaleziono przedmiotu"
    end
    redirect_to przedmioty_path
  end

  def destroy_all
    if @przedmioty = Przedmioty.where(id: session[:wybrane_przedmioty])
      @przedmioty.delete_all
    else
      flash[:error] = "Nie znaleziono przedmiotu"
    end
    redirect_to przedmioty_path
  end


  def wybierz
    if @przedmiot = Przedmioty.where(id: params[:id]).first
      unless session[:wybrane_przedmioty]
        session[:wybrane_przedmioty] = []
      end
      unless session[:wybrane_przedmioty].include? @przedmiot.id
        session[:wybrane_przedmioty] += [@przedmiot.id]
      else
        flash[:error] = 'nie mozesz ponownie dodac identycznego przedmiotu'  
      end
    else      
      flash[:error] = 'nie znaleziono przedmiotu'
    end
    if params[:pathC]
      #redirect_to_url(params[:path])
      redirect_to controller: params[:pathC], action: params[:pathA], id: params[:pathI]
    else
      params[:id] = nil
      redirect_to action: :index, params: params 
    end
  end
  def stworz_tablice    
    @menu_stan = [["zajęty",1],["wypożyczalny",2],['utylizacja',3]]

    @menu_szafki = [['brak', 0]]
    Szafki.all.each {|f| @menu_szafki+=[[f.miejsce.to_s + "(" + f.numer.to_s + "," +")" , f.id]]}

    @menu_uzytkownicy = [['brak', 0]]
    Uzytkownicy.all.each { |f| @menu_uzytkownicy+=[[f.nick, f.id]] }
    
    @menu_projekty = [['brak', 0]]
    Projekty.all.each { |f| @menu_projekty+=[[f.nazwa, f.id]] }
  end

  def dodaj_do_projektu
    @wybrane = Przedmioty.where(id: session[:wybrane_przedmioty], stan: 2)
    if @wybrane.size != session[:wybrane_przedmioty].size
      flash[:error] = "Nie wszystkie przedmioty można umieścić w projekcie"
    end

    if @poziom_dostepu > 2
      @lista = Projekty.all
    else
      @lista = Uzytkownicy.where(id: @uzytkownik_id).first.projekties
    end
  end

  def grupuj
    if session[:grupuj] != true;
      session[:grupuj] = true;
    else
      session[:grupuj] = false;
    end
    redirect_to action: :index
  end
  def dodaj_do_projektu_A
    blad = false
    
    if @poziom_dostepu < 2
      unless @projekt = Uzytkownicy.where(id: @uzytkownik_id).first.projekties.where(id: params[:id]).first
        flash[:error] = "brak projektu"
        blad = true
      end
    else
      unless @projekt = Projekty.where(id: params[:id]).first
        flash[:error] = "brak projektu"
        blad = true
      end
    end
    if (@wybrane = Przedmioty.where(id: session[:wybrane_przedmioty])).size < 1
      flash[:error] = "brak wybranych przedmiotów"
      blad = true
    end

    if (@wybrane = @wybrane.where(stan:2)).size < 1
      flash[:error] = "przedmioty są zablokowane"
      blad = true
    end
    if (@wybrane = @wybrane.where(uzytkownicy_id: 0)).size < 1     
      flash[:error] = "Przedmioty sa wypozyczone"
      blad = true
    end

    if (@wybrane = @wybrane.where(projekty_id: 0)).size < 1
      flash[:error] = "Przedmioty naleza już do jakiegoś projektu"
      blad = true
    end

    session[:wybrane_przedmioty] = nil
    
    unless blad
      flash[:notice] = "dodano do projektu: "
      @wybrane.all.each do |p|
        p.update(projekty_id: @projekt.id)
      end

      redirect_to projekty_show_path(id: @projekt.id) and return
    end

    redirect_to przedmioty_path
  end

  def wypozycz

    blad = false
    if (@przedmioty = Przedmioty.where(id: session[:wybrane_przedmioty])).size < 1
      flash[:error] += "nie zaznaczono żadnego przedmiotu"
      blad = true
    end

    if (@przedmioty = @przedmioty.where(stan: 2)).size < 1
      flash[:error] = "wybranych przedmiotow nie mozna wypozyczać"
      blad = true
    end

    if (@przedmioty = @przedmioty.where(uzytkownicy_id: 0)).size < 1
      flash[:error] = "te przedmioty sa wypozyczone"
      blad = true
    end

    if (@przedmioty = @przedmioty.where(projekty_id: 0)).size < 1
      flash[:error] = "te przedmioty naleza do projektu"
      blad = true
    end

    unless @uzytkownik = Uzytkownicy.where(id: @uzytkownik_id).first
      flash[:error] = "brak takiego użytkownika"
      blad = true
    end  

    unless @szafka = @uzytkownik.szafkis.first
      flash[:error] = "zakaz wypożyczania"
      blad = true
    end

    session[:wybrane_przedmioty] = nil
    unless blad
      flash[:notice] = "wypożyczono"

      @przedmioty.all.each do |p|
        p.szafki_id = @szafka.id
        p.uzytkownicy_id = @uzytkownik.id
        p.save
      end
      redirect_to  szafki_show_path(id: @szafka) and return
    end

    redirect_to przedmioty_path
  end
  def schowaj
    @lista = Szafki.where(uzytkownicy_id: 0)
    
  end

  def schowaj_A
    blad = false

    if (@przedmioty = Przedmioty.where(id: session[:wybrane_przedmioty])).size < 1
      flash[:error] = "nie zaznaczono żadnego przedmiotu"
      blad = true
    end

    if (@poziom_dostepu < 3)
      if (@przedmioty = @przedmioty.where(stan: 2)).size < 1
        flash[:error] = "wybranych przedmiotow nie mozna wypozyczać"
        blad = true
      end
    end

    if (@przedmioty = @przedmioty.where(uzytkownicy_id: 0)).size < 1
      flash[:error] = "te przedmioty sa wypozyczone"
      blad = true
    end

    if (@przedmioty = @przedmioty.where(projekty_id: 0)).size < 1
      flash[:error] = "te przedmioty naleza do projektu"
      blad = true
    end

    unless @uzytkownik = Uzytkownicy.where(id: @uzytkownik_id).first
      flash[:error] = "brak takiego użytkownika"
      blad = true
    end  

    unless @szafka = Szafki.where(id: params[:id]).first
      flash[:error] = "brak takiej szafki"
      blad = true
    end

    unless @szafka.uzytkownicy_id == 0
      flash[:error] = "to jest szafka innego użytkownika"
      blad = true
    end

    session[:wybrane_przedmioty] = nil
    
    unless blad
      flash[:notice] = "zaszufladkowano"
      @przedmioty.all.each do |p|
        p.szafki_id = @szafka.id
        p.szafka_pierwotna = @szafka.id
        p.save
      end
      redirect_to  szafki_show_path(id: @szafka) and return
    end

    redirect_to przedmioty_path
  end


  def wyczysc
    session[:wybrane_przedmioty] = nil
    redirect_to action: :index;
  end
private   
  def poziom1
    wejscie(1, root_path)
  end
  def poziom2
    wejscie(2, przedmioty_path)
  end
  def poziom3
    wejscie(3, przedmioty_path)
  end
  

end
