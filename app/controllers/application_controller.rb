class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  private

  # 必ずログインさせるので新しいユーザー作成時もログインしないといけない
  def require_user_logged_in
    unless logged_in?
      redirect_to login_url
    end
  end
  #
  # def show
  #   @user = User.find(params[:id])
  # end

  def counts(user)
    @count_microposts = user.microposts.count
    @count_followings = user.followings.count
    @count_followers = user.followers.count
    @count_favoritings = user.favoritings.count
  end
end
