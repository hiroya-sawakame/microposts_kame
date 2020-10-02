class RelationshipsController < ApplicationController
  before_action :require_user_logged_in

  def create
    user = User.find(params[:follow_id])
    current_user.follow(user)
    flash[:success] = 'ユーザをフォローしました。'
    redirect_to user
  end

  def destroy
    user = User.find(params[:follow_id])
    current_user.unfollow(user)
    # Userモデルにインスタンスメソッドを書かない場合は下記でも対応可能
    # relationship = current_user.relationships.find_by(follow_id: user.id)
    # relationship.destroy if relationship
    flash[:success] = 'ユーザのフォローを解除しました。'
    redirect_to user
  end
end