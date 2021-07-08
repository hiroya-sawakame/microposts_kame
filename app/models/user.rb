class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
            uniqueness: { case_sensitive: false }
  has_secure_password

  has_many :microposts

  # 中間テーブル「relationships」は左側が自分のuser_id。右側がフォローしたユーザーのid(follow_id)
  has_many :relationships

  # 下記「through: 〜」は「〜を使って」の意味
  # 中間テーブルの右半分をまとめたもの。「自分がフォローしているUser」への参照
  # relationships を使って、follow_idを集めてfollowingsを作ります。
  has_many :followings, through: :relationships, source: :follow

  #Rails の命名規則により、User から Relationship を取得するとき、user_id が使用されるので逆方向では、foreign_key: 'follow_id' と指定して、 user_id 側ではないことを明示する
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'

  # 中間テーブルの左半分をまとめたもの。「自分をフォローしているUser」への参照
  has_many :followers, through: :reverses_of_relationship, source: :user

  # お気に入りしている投稿をまとめる
  has_many :favorites
  has_many :my_favorites, through: :favorites, source: :micropost
  # お気に入りされている投稿をまとめる必要がないので左側のみ

  # 自分以外のユーザーであることを確認しfollow_idを作成する
  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end

  # 後ifでrelationshipの値が存在するときのみunfollowにする
  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end

  # self.followings内にother_userが含まれているとtureを返す
  def following?(other_user)
    self.followings.include?(other_user)
  end

  # following_idsはhas_many :followings, ... によって自動的に生成されるメソッド
  # Micropost.where(user_id: フォローユーザ + 自分自身) となる Micropost を全て取得しています。
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end

  def favorite(micropost)
    # find_or_create_by は見つかればモデル（クラス）のインスタンスを返し、見つからなければ作成
    self.favorites.find_or_create_by(micropost_id: micropost.id)
  end

  def unfavorite(micropost)
    favorites = self.favorites.find_by(micropost_id: micropost.id)
    favorites.destroy if favorites
  end

  def my_favorite?(micropost)
    self.my_favorites.include?(micropost)
  end
end