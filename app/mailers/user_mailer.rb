class UserMailer < ApplicationMailer
    default from: 'shankarhurpude249@gmail.com'
    def order_mail
        mail(to:params[:email],subject:"#{params[:service].shop_name} confirmed your mail")
    end

    def order_cancel_mail
        debugger
        mail(to:params[:email],subject:"#{params[:service].shop_name} has cancelled your Request")
    end

    
end
