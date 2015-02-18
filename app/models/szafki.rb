class Szafki < ActiveRecord::Base  
  validates :miejsce, presence:true, length: {minimum:3}
  validates :numer, presence:true, length: {minimum:1}

  has_many :przedmioties 
  has_many :projekties
  belongs_to :uzytkownicy 

  before_destroy :sprzatanie
  def sprzatanie
  	przedmioties.each do |p|
      if p.szafki_id == p.szafka_pierwotna
        p.szafki_id = 1
        p.szafka_pierwotna = 1
      else
        p.szafki_id = p.szafka_pierwotna
      end
      p.uzytkownicy_id = 0
      p.save
    end

    projekties.update_all(szafki_id: 1)

  end
  

  before_save :popraw
  before_create :popraw
  def popraw
  	if self.uzytkownicy_id == nil
  		self.uzytkownicy_id = 0
  	end

  end
end
