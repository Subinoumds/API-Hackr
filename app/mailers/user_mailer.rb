class UserMailer < ApplicationMailer
    def welcome_email(user)
      @user = user
      mail(to: @user.email, subject: 'Welcome to My Awesome Site')
    end

    def spam_email(email, content)
      @content = content
      mail(to: email, subject: 'Spam Email') do |format|
        format.text { render plain: @content }
      end
    end
  end