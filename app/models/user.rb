class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: Relationship.name,
    foreign_key: :follower_id, dependent: :destroy
  has_many :passive_relationships, class_name: Relationship.name,
    foreign_key: :followed_id, dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  validates :name, presence: true,
                   length: {maximum: Settings.user.name.max_length}
  validates :email, presence: true,
                    length: {maximum: Settings.user.email.max_length},
                    format: {with: Settings.user.email.regex},
                    uniqueness: true
  validates :password, presence: true,
                       length: {minimum: Settings.user.password.min_length},
                       allow_nil: true
  before_save   :downcase_email
  before_create :create_activation_digest
  has_secure_password
  scope :where_activated, ->{where(activated: true)}
  scope :by_created_at, ->{order(created_at: :desc)}

  class << self
    # Returns the hash digest of the given string.
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    # Returns a random token.
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  # Returns true if the given token matches the digest.
  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  def forget
    update_column :remember_digest, nil
  end

  # Activates an account.
  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < Settings.user.password_reset_time.hours.ago
  end

  def feed
    # Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
    Micropost.load_feed(following_ids << id)
  end

  # Follows a user.
  def follow other_user
    following << other_user
  end

  # Unfollows a user.
  def unfollow other_user
    following.delete other_user
  end

  # Returns if the current user is following the other_user or not
  def following? other_user
    following.include? other_user
  end

  private

  # Converts email to all lower-case.
  def downcase_email
    email.downcase!
  end

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
