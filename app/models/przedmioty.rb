class Przedmioty < ActiveRecord::Base
  validates :nazwa, presence:true, length: {minimum:3}
  validates :model, presence:true, length: {minimum:3}
  validates :typ, presence:true, length: {minimum:3}
  validates :szafki_id, presence:true
  validates :uzytkownicy_id, presence:true

  belongs_to :szafki
  belongs_to :uzytkownicy
  belongs_to :projekty  

  before_create :ustaw_w_szafce
  before_update :ustaw_w_szafce
  before_save 	:ustaw_w_szafce
  def ustaw_w_szafce
    if (self.szafki_id == 0) || (self.szafki_id == nil)
      self.szafki_id = 1
    end
    if (self.szafka_pierwotna == nil)
      self.szafka_pierwotna = 1
    end

    if (self.projekty_id == nil)
      self.projekty_id = 0
    end
    if (self.uzytkownicy_id == nil)
      self.uzytkownicy_id = 0
    end
  end
end
