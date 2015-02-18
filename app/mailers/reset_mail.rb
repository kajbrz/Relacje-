# encoding: UTF-8
class ResetMail < ActionMailer::Base
  default from: "synergia"
  def reset(param) 
    @params = param 
    @user = param[:user]
    user = @user.email    
    puts "#"*1000
    puts param[:user] 
    puts "\n"
    puts param[:link]
    puts "\n"

    puts "#"*3000 + "Hej siemka" + param.to_s
    @link = param[:link]
    mail(to: user, subject: '[Synergia][Relacje]Zmiana hasła', link: param[:link])
   
  end 
end
