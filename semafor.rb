if $semaforClass == nil
	$semaforClass = true
	
	class Semafor
		@@watki = []
		@@semaforInit = false
		@@zabij = false
		@@mojwatek = nil
		def initialize
			if @@semaforInit == false
				@@semaforInit = true
				stworzWatek
			end
		end

		def self.zyjace
			return @@watki
		end

		def self.zabijSie
			@@zabij = true
			if @@mojwatek
				@@mojwatek.join
				@@mojwatek = nil
			end
			@@zabij = false
			@@watki.each {|wat| wat.kill}
			@@semaforInit = false
		end

		def self.dodajWatek(watek)
			if @@mojwatek == nil
				watek.kill
				raise "Blad inicjalizacji: Zainicjalizuj klase: Semafor.new"
			else
				@@watki << watek
			end
		end

		def self.getWlasnyWatek

			return @@mojwatek
		end
		private
		def stworzWatek
			@@mojwatek = Thread.new do |tr|
				while true do
					sprawdzWatki
					sleep(5)	
					if @@zabij == true
						break
					end
				end
			end
		end
		def sprawdzWatki
			@@watki.each do |watek|
				if watek.alive? == false
					@@watki.delete(watek)
				end
			end
		end
	end
	puts "Tworzenie semafora..."
	Semafor.new
else 
end

