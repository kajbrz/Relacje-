class Uzytkownicy < ActiveRecord::Base
  validates :nick, presence: true, uniqueness: true, length: { minimum: 3}
  validates :email, presence: true, uniqueness: true, length: { minimum: 3}, 
      format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :haslo, presence: true, length: { minimum: 3}

  has_many :projekty_uzytkownicies
  has_many :projekties, :through => :projekty_uzytkownicies

  has_many :przedmioties
  has_many :szafkis, :dependent => :destroy 

  

  before_create :zakoduj_haslo
  def zakoduj_haslo
    self.haslo_salt = BCrypt::Engine.generate_salt
    self.haslo = BCrypt::Engine.hash_secret(self.haslo,self.haslo_salt)  
    #tworzenie szafki dla uzytkownika 
  end
  

  def destroy
    self.szafkis.update_all(uzytkownicy_id: 0)
    puts "#" * 1000
  end  

  after_create :utworz_szafke
  def utworz_szafke
    @szafka = Szafki.create!(
      miejsce: 'dom',
      numer: 0
    )
    self.szafkis << @szafka
  end

  def self.autoryzacja(email, haslo)
    uzytkownik = find_by(:email => email)
    if uzytkownik && (uzytkownik.haslo == BCrypt::Engine.hash_secret(haslo, uzytkownik.haslo_salt))
      uzytkownik.update(ostatnie_logowanie: Time.zone.now)
      uzytkownik
    else
      nil
    end
  end

end
