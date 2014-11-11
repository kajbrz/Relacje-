# Preview all emails at http://localhost:3000/rails/mailers/reset_mail
class ResetMailPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/reset_mail/reset
  def reset
    ResetMail.reset
  end

end
