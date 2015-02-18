# encoding: UTF-8
class ProjektyController < ApplicationController  
  before_action :poziom1

  def index
    if params[:szukaj] 
      @projekty = Projekty.where('nazwa LIKE ?', "%#{params[:szukaj]}").pluck(:id)
      @projekty += Projekty.where('stan LIKE ?', "%#{params[:szukaj]}").pluck(:id)
      #@projekty += Projekty.where('opis LIKE ?', "%#{params[:szukaj]}").pluck(:id)
      #@projekty += Projekty.includes(params[:szukaj]).pluck(:id)
      Projekty.all.each { |p| @projekty += [p.id.to_s] if p.opis.to_s.include? params[:szukaj].to_s }
    
      @projekty = Projekty.where(id: @projekty)
    else
      @projekty = Projekty.all
    end  
  end

  def show
    if @projekt = Projekty.where(id: params[:id]).first
      if @projekt.uzytkownicies.where(id: @uzytkownik_id).first || @poziom_dostepu > 1
        @edycja = true
      end
    else
      flash[:error] = 'nie znaleziono rekordu'
      redirect_to projekty_path
    end
  end

  def edit
    if @projekt = Projekty.where(id: params[:id]).first
      if @projekt.uzytkownicies.where(id: @uzytkownik_id) || @poziom_dostepu > 1
        
      else
        flash[:error] = "brak dostępu"         
        redirect_to projekty_path(id: @projekt)
      end
    else
      redirect_to projekty_path
    end
  end

  def update
    if @projekt = Projekty.where(id: params[:id]).first
      if @projekt.uzytkownicies.where(id: @uzytkownik) || @poziom_dostepu > 2
        if @projekt.update(params.require(:projekty).permit(:nazwa, :stan, :opis))
        else
          flash[:error] = @user.errors.messages
          render action: :edit, id: @projekt.id and return
        end
      else
        flash[:error] = "brak dostępu"        
      end
    else
      flash[:error] = "nie ma takiego projektu"
      redirect_to action: :index and return
    end
    redirect_to action: :show, id: @projekt.id
  end

  def create
    if @uzytkownik = Uzytkownicy.where(id: params[:projekty][:uzytkownik_id]).first
      unless @poziom_dostepu > 1
        if @uzytkownik.id != @uzytkownik_id
          flash[:error] = "tylko administrator ma prawo wyboru użytkownika"
          redirect_to projekty_path and return
        end
      end
      @uzytkownik.projekties.create(params.require(:projekty).permit(:nazwa, :opis, :stan))
      flash[:notice] = "stworzono projekt"
    else
      flash[:error] = "nie znaleziono użytkownika"
    end
    redirect_to projekty_path
  end

  def destroy
    if @projekt = Projekty.where(id: params[:id]).first
      if ((@projekt.uzytkownicies.where(id: @uzytkownik_id)) || (@poziom_dostepu > 1 ))
        @projekt.delete
        flash[:notice] = "pomyślnie usunięto"
      else
        flash[:error] = "brak dostępu do operacji"
      end    
    else
      flash[:error] = "nie znaleziono projektu"
    end
    redirect_to action: :index
  end

  def dodaj_uzytkownika

    blad = false
    unless @uzytkownik = Uzytkownicy.where(id: @uzytkownik_id).first
      blad = true
      flash[:error] = "nie znaleziono uzytkownika"
    end
    if @poziom_dostepu > 2
      unless @projekt = Projekty.where(id: params[:projekt_id]).first
        blad = true
        flash[:error] = "nie znaleziono projektu"
      end
    else
      unless @projekt = @uzytkownik.projekties.where(id: params[:projekt_id]).first
        blad = true
        flash[:error] = "nie znaleziono projektu, lub nie należysz do projektu"
      end
    end

    unless @uzytkownik_do_dodania = Uzytkownicy.where(id: params[:uzytkownik_id]).first
      blad = true
      flash[:error] = "nie znaleziono uzytkownika"
    end

    if @projekt.uzytkownicies.where(id: @uzytkownik_do_dodania.id).first
      blad = true      
      flash[:notice] = "ten użytkownik już należy do projektu" 
    end 

    unless blad      
      @projekt.uzytkownicies << @uzytkownik_do_dodania
      flash[:notice] = "dodano uzytkownika"     
      redirect_to projekty_show_path(id: @projekt.id) and return
    else
      redirect_to projekty_path
    end
  end
  
  def usun_uzytkownika
    if @projekt = Projekty.where(id: params[:projekt_id]).first
      if @uzytkownik = Uzytkownicy.where(id: params[:uzytkownik_id]).first
        if ((@poziom_dostepu > 1) || ( @projekt.uzytkownicies.include? Uzytkownicy.where(id: @uzytkownik_id).first)) 
          @projekt.uzytkownicies.delete(@uzytkownik)
          flash[:notice] = "usunięto użytkownika" + @uzytkownik.nick + ' z projektu '+ @projekt.nazwa
        else
          flash[:error] = "nie masz dostępu do tej operacji"          
        end
      else
        flash[:error] = "nie znaleziono użytkownika"
      end
    else
      flash[:error] = "nie znaleziono projektu"
    end
    redirect_to action: :show, id: params[:projekt_id]
  end

  def edytuj_role
  
    blad = false

    unless @uzytkownik = Uzytkownicy.where(id: @uzytkownik_id).first
      blad = true
      flash[:error] = "brak takiego uzytkownika"
    end

    unless @uzytkownik_rola = Uzytkownicy.where(id: params[:uzytkownik_id]).first
      blad = true
      flash[:error] = "brak takiego uzytkownika"
    end

    unless @projekt = Projekty.where(id: params[:projekt_id]).first
      blad = true
      flash[:error] = "brak takiego projektu"
    end

    unless @uzytkownik.projekties.where(id: @projekt.id).first || @poziom_dostepu > 2
      blad = true
      flash[:error] = "nie masz uprawnien do zmian w tym projekcie"
    end

    unless (@pr = ProjektyUzytkownicy.where(uzytkownicy_id: @uzytkownik_rola, projekty_id: @projekt.id)).size > 0
      blad = true
      flash[:error] = "wybrany użytkownik nie należy do projektu"
    end


    unless blad
      @pr.update_all(rola: params[:rola])
      flash[:notice] = "pomyślnie zmieniono rolę w projekcie"
      redirect_to projekty_show_path(id: @projekt.id) and return
    end
    redirect_to projekty_path
  end

  def zmien_role
    blad = false

    unless @projekt = Projekty.where(id: params[:projekt_id]).first
      blad = true
    end

    unless @uzytkownik = Uzytkownicy.where(id: params[:uzytkownik_id]).first
      blad = true
    end

    if blad
      redirect_to projekty_path and return
    end
  end

  def usun_przedmiot
    blad = false
    if (@przedmiot = Przedmioty.where(id: params[:id]).first) == nil
      flash[:error] = "brak przedmiotów"
      blad = true
    end

    if (@projekt = Projekty.where(id: params[:projekt_id]).first) == nil
      flash[:error] = "brak projektu"
      blad = true
    end

    if (@uzytkownik = Uzytkownicy.where(id: @uzytkownik_id).first.projekties.where(id: @projekt.id)) == nil
      flash[:error] = "nie należysz do projektu"
      blad = true
    end


    if (@projekt.przedmioties.where(id: @przedmiot.id)).size < 1      
      flash[:error] = "brak przedmiotów"
      blad = true
    end

    unless blad
      flash[:notice] = "zwrócono przedmiot"
      @przedmiot.projekty_id = 0
      @przedmiot.szafki_id = @przedmiot.szafka_pierwotna
      @przedmiot.save
    end
    redirect_to projekty_show_path(id: @projekt.id)
  end

  def umiesc_w_szafce
    @projekt_id = params[:id]

    if @poziom_dostepu > 2
      @lista = Szafki.all
    else
      @lista = Szafki.where(uzytkownicy_id: [0, @uzytkownik_id])
    end
  end

  def schowaj_do_szafki
    blad = false

    unless @uzytkownik = Uzytkownicy.where(id: @uzytkownik_id).first
      blad = true
    end

    unless @projekt = @uzytkownik.projekties.where(id: params[:projekt_id]).first
      blad = true

    end

    unless @szafka = Szafki.where(uzytkownicy_id: [0, @uzytkownik_id]).where(id: params[:szafka_id]).first
      flash[:error] = "nie możesz skorzystać z tej szafki"
      blad = true
    end

    unless blad
      flash[:notice] = "umieszczono w szafce"
      @projekt.szafki_id = @szafka.id
      @projekt.save
    end

    redirect_to projekty_show_path(id: params[:projekt_id])
  end

  def dodaj_osobe
    blad = false

    unless @projekt = Projekty.where(id: params[:id]).first
      flash[:error] = "nie znaleziono projektu"
      blad = true
    end

    unless @uzytkownik = Uzytkownicy.where(id: @uzytkownik_id).first
      flash[:error] = "nie znaleziono uzytkownika"
      blad = true
    end


    unless @uzytkownik.projekties.where(id: @projekt.id).first || @poziom_dostepu > 2
        flash[:error] = "nie należysz do tego projektu"
        blad = true
    end

    unless blad
      @lista = Uzytkownicy.all
    else    
        redirect_to projekty_show_path(id: @projekt.id) and return
    end
  end
private   
  def poziom1
    wejscie(1, root_path)
  end


end
