class Przedmioty < ActiveRecord::Base
  validates :nazwa, presence:true, length: {minimum:3}
  validates :model, presence:true, length: {minimum:3}
  validates :typ, presence:true, length: {minimum:3}
  validates :szafki_id, presence:true
  validates :uzytkownicy_id, presence:true

  belongs_to :szafki
  belongs_to :uzytkownicy
  belongs_to :projekty  
  
 
end
