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
    @szafka = Szafki.where(id: params[:id])
    if @szafka.count > 0
      @szafka = @szafka.first
    else
      flash[:error] = "nie ma takiej szafki"
      redirect_to action: :index and return
    end
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
  
  def schowaj
	  if @szafka = Szafki.where(id: params[:szafka_id]).first
      if session[:wybrane_przedmioty] && session[:wybrane_przedmioty].count > 0
				if ((@szafka.uzytkownicy_id == 0) || (@szafka.uzytkownicy_id == @uzytkownik_id) || (@poziom_dostepu > 2))
				  @id_err = []      
				  if @przedmioty = Przedmioty.where(id: session[:wybrane_przedmioty])
				    @przedmioty.each do |p|
              if ((p.stan == 2) || (@poziom_dostepu>2)) 
                if @szafka.uzytkownicy_id == @uzytkownik_id
                  p.update(szafki_id: params[:szafka_id], stan: 1, uzytkownicy_id: @uzytkownik_id) 
                else
                  p.update_attributes(szafki_id: params[:szafka_id], stan: 2, uzytkownicy_id: 0) 
                end
              else
                @id_err += [p.id]
              end
					 	end
            if @id_err.count > 0
							flash[:notice] = "\nnieschowano przedmiotow o id: " + @id_err.to_s
						else
							flash[:notice] = "\nschowano wszystkie przedmioty"	
						end
						session[:wybrane_przedmioty] = nil
				  else
				    flash[:notice] = "brak przedmiotow do dodania"
				  end  
				else
      		flash[:error] = "nie masz wystarczajacych uprawnien do skorzystania z tej szafki"
				end 
			else			
        flash[:error] = "nie mozna nic schowac"		
			end
    else
      flash[:error] = "nie znaleziono szafki"
    end
		redirect_to action: :show, id: @szafka 
  end

  def zwroc_przedmioty
    if session[:wybrane_przedmioty] && session[:wybrane_przedmioty].size > 0
      if @przedmioty = Przedmioty.where(id: session[:wybrane_przedmioty], 
          uzytkownicy_id: @uzytkownik_id)               
			  if @szafka = Szafki.where(id: params[:szafka_id], uzytkownicy_id: 0).first
          if true    
            @przedmioty.update_all(stan: 2, uzytkownicy_id: 0, szafki_id: params[:szafka_id])
            flash[:notice] = "udostepniono " + @przedmioty.size.to_s + 
              " przedmiotow"
            session[:wybrane_przedmioty] = nil
          else
            flash[:error] = "nie mozesz zwrocic przedmiotow do tej szafki"        
          end
        else
          flash[:error] = "nie znaleziono szafki lub nalezy do innego uzytkownika"        
        end
      else
        flash[:error] = "nie zaznaczyles zadnych przedmiotow"
      end
    else
      flash[:error] = "nie mozesz zwrocic tych przedmiotow"
    end
		redirect_to action: :show, id: @szafka
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
      if @poziom_dostepu > 1 || @szafka.uzytkownicy_id == @uzytkownik_id  
        @szafka.przedmioties.delete_all
        @szafka.projekties.delete_all
        @szafka.delete
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
