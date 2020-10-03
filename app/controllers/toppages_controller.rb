class ToppagesController < ApplicationController
  before_action :require_user_logged_in, only: [:index]
  def index
    @micropost = current_user.microposts.build
    @microposts = current_user.feed_microposts.order(id: :desc).page(params[:page])
  end
end
