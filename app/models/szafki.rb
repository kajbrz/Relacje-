class Szafki < ActiveRecord::Base  
  validates :miejsce, presence:true, length: {minimum:3}
  validates :numer, presence:true, length: {minimum:1}

  has_many :przedmioties
  has_many :projekties
  belongs_to :uzytkownicy

  
end
