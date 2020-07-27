class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
            format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
            uniqueness: { case_sensitive: false }
  has_secure_password

  has_many :microposts
  has_many :relationships
  # 下記「through: 〜」はよく使うので予めまとめて使いやすくしておく
  # フォローしている人をまとめる
  has_many :followings, through: :relationships, source: :follow

  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  # フォローしてくれてる人をまとめる
  has_many :followers, through: :reverses_of_relationship, source: :user

  has_many :favorites
  # お気に入りしている投稿をまとめる
  has_many :favoritings, through: :favorites, source: :micropost

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
    self.favorites.find_or_create_by(micropost_id: micropost.id)
  end

  def unfavorite(micropost)
    favorites = self.favorites.find_by(micropost_id: micropost.id)
    favorites.destroy if favorites
  end

  def favoriting?(micropost)
    self.favoritings.include?(micropost)
  end
end