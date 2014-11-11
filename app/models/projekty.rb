class Projekty < ActiveRecord::Base   
  validates :nazwa, presence:true, length: {minimum:3}  
  validates :stan, presence:true, length: {minimum:3}


  has_many :projekty_uzytkownicies
  has_many :uzytkownicies, :through => :projekty_uzytkownicies

  has_many :przedmioties
  belongs_to :szafki


end
