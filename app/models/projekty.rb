class Projekty < ActiveRecord::Base   
	validates :nazwa, presence:true, length: {minimum:3}  
	validates :stan, presence:true, length: {minimum:3}


	has_many :projekty_uzytkownicies
	has_many :uzytkownicies, :through => :projekty_uzytkownicies

	has_many :przedmioties
	belongs_to :szafki

	before_create   :ustaw_w_szafce
	before_update   :ustaw_w_szafce
	before_save		:ustaw_w_szafce
	def ustaw_w_szafce
		if (self.szafki_id == 0) || (self.szafki_id == nil)
		  self.szafki_id = 1
		end
	end


end
