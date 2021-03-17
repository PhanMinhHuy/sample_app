class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    if user&.authenticate params[:session][:password]
      if user.activated?
        log_in_user user
      else
        flash[:warning] = t "flash.account_not_activated"
        redirect_to root_path
      end
    else
      flash.now[:danger] = t "flash.invalid_sign_in"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end
end
