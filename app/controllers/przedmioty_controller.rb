# encoding: UTF-8
class PrzedmiotyController < ApplicationController
  before_action :poziom1
  before_action :poziom2, only: [:new, :create, :destroy, :destroy_all, :update, :edit]

  def index    
    if params[:szukaj] 
      @przedmioty = Przedmioty.where('nazwa LIKE ?', "%#{params[:szukaj]}").pluck(:id)
      @przedmioty += Przedmioty.where('typ LIKE ?', "%#{params[:szukaj]}").pluck(:id)
      @przedmioty += Przedmioty.where('model LIKE ?', "%#{params[:szukaj]}").pluck(:id)

      @przedmioty = Przedmioty.where(id: @przedmioty)
    else
      if params[:wybrane]
        @przedmioty = Przedmioty.where(id: session[:wybrane_przedmioty])       
      else
        @przedmioty = Przedmioty.all
      end
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
      redirect_to action: :index      
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
    @przedmiot = Przedmioty.find(params[:id])
    @przedmiot.update(params.require(:przedmioty).permit(:typ, :nazwa, :model, :stan, :uzytkownicy_id, :projekty_id, :szafki_id)) 
    redirect_to przedmioty_index_path
  end     

  def create
    @param = params.require(:przedmiot).permit(:typ, :nazwa, :model, :stan, :uzytkownicy_id, :projekty_id, :szafki_id)
    if @przedmiot = Przedmioty.create(@param)       
      if ((il = params[:przedmiot][:ilosc].to_i) > 0)
        @przedmiot_arr = [@param]
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

  def stworz_tablice    
    @menu_stan = [['zajety',1],['wypozyczalny',2],['utylizacja',3]]

    @menu_szafki = [['brak', 0]]
    Szafki.all.each {|f| @menu_szafki+=[[f.miejsce.to_s + "(" + f.numer.to_s + "," +")" , f.id]]}

    @menu_uzytkownicy = [['brak', 0]]
    Uzytkownicy.all.each { |f| @menu_uzytkownicy+=[[f.nick, f.id]] }
    
    @menu_projekty = [['brak', 0]]
    Projekty.all.each { |f| @menu_projekty+=[[f.nazwa, f.id]] }
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
