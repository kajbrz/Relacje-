class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :poziom_dostepu
private #section
  
  def initialize
    super
    load "semafor.rb"
  end

  def poziom_dostepu
    if id = Sesja.sprawdz(session[:session_id])
      if @uzytkownik_id = Uzytkownicy.where(id: id).first
        @uzytkownik_id = @uzytkownik_id.id
        @poziom_dostepu = Uzytkownicy.where(id: id).first.poziom_dostepu
      else 
        @poziom_dostepu = -1   
        @uzytkownik_id = nil  
      end
    else
      @poziom_dostepu = -1 
      @uzytkownik_id = nil  
    end
  end

  #wejscie jest metoda ktora okresla minimalny poziom dostepu do akcji
  #poziom_wejscia - minimalna ranga uzytkownika, 
  #przekierowanie - w przypadku niespelnienia zaleznosci
  def wejscie(poziom_wejscia, przekierowanie) 
    if @poziom_dostepu < poziom_wejscia
      flash[:error] = "nie masz odpowiednich uprawnien"
      redirect_to przekierowanie
    end  
  end
  
end
