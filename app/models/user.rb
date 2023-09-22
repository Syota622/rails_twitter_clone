# frozen_string_literal: true

class User < ApplicationRecord
  # deviseの設定。userモデルでdeviseのすべてのmoduleを有効にする
  # ・database_authenticatable: パスワードのセキュアな保存と認証を担当します。
  # ・registerable: ユーザーの登録やアカウント削除などを扱います。
  # ・recoverable: パスワードリセット機能を提供します。
  # ・rememberable: ユーザーのセッションを長く保持する「Remember me」機能を提供します。
  # ・validatable: Eメールやパスワードのバリデーションを行います。
  # ・confirmable: メールアドレスの確認を行います。
  # ・lockable: 複数回のログイン失敗でアカウントをロックする機能を提供します。
  # ・timeoutable: 一定時間アクションがない場合、セッションをタイムアウトさせる機能を提供します。
  # ・trackable: ユーザーのサインインカウントや時刻、IPアドレスをトラックします。
  # ・omniauthable: OAuth 2.0を使用してのサードパーティ認証をサポートします。
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable, :lockable,
         :timeoutable, :trackable, :omniauthable, omniauth_providers: %i[github]

  # バリデーション
  validates :email, presence: true
  validates :phone_number, presence: true, unless: :omniauth_user?
  validates :birthdate, presence: true, unless: :omniauth_user?

  # UserモデルのオブジェクトからFollowRelationモデルのオブジェクトを取得する
  has_many :follower_relations, foreign_key: :followee_id, class_name: 'FollowRelation', dependent: :destroy,
                                inverse_of: :followee
  has_many :followers, through: :follower_relations, source: :follower

  has_many :followee_relations, foreign_key: :follower_id, class_name: 'FollowRelation', dependent: :destroy,
                                inverse_of: :follower
  has_many :followees, through: :followee_relations, source: :followee

  has_many :tweets, dependent: :destroy

  # active_storageの設定
  has_one_attached :profile_image
  has_one_attached :header_image

  # Omniauth認証時の処理
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.phone_number = 'N/A'
      user.birthdate = '2000-01-01'
      user.skip_confirmation!
      user.save!
    end
  end

  # Omniauthで認証されたユーザーかどうかを判定
  def omniauth_user?
    provider.present? && uid.present?
  end

  # フォローしているユーザーのツイートを取得
  # pluck：特定のカラムの値だけ取得する
  def following_tweets
    Tweet.where(user_id: followees.pluck(:id)).order(created_at: :desc)
  end
end
