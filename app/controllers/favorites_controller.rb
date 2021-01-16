class FavoritesController < ApplicationController
  before_action :require_user_logged_in

  #　お気に入りにされている投稿一覧を実装途中...
  # def index
  #   @microposts = Micropost.find(3)
  #   @favorites = @microposts.book_marked
  #   p "--test--"
  #   p @microposts
  #   p "--test_2--"
  #   p @favorites
  #   p "--test_3--"
  # end

  def create
    micropost = Micropost.find(params[:micropost_id])
    current_user.favorite(micropost)
    flash[:success] = 'お気に入りに追加しました。'
    redirect_back(fallback_location: "/")
  end

  def destroy
    micropost = Micropost.find(params[:micropost_id])
    current_user.unfavorite(micropost)
    flash[:success] = 'お気に入りから削除しました。'
    redirect_back(fallback_location: "/")
  end
end
