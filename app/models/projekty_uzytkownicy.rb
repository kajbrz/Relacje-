class ProjektyUzytkownicy < ActiveRecord::Base  
  validates_uniqueness_of :uzytkownicy_id, :scope => :projekty_id

  
  belongs_to :uzytkownicy
  belongs_to :projekty  

  before_create :utworz

  def utworz
    self.rola = "nieustalono"
  end
end
