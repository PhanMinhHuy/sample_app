class Micropost < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :content, presence: true,
                      length: {maximum: Settings.micropost.content.max_length}
  validates :image, content_type: {in: %w(image/jpeg image/gif image/png),
                                   message: I18n.t("micropost.type_massage")},
                    size: {less_than:
                           Settings.micropost.image.max_size.megabytes,
                           message:
                           I18n.t("micropost.size_message",
                                  size: Settings.micropost.image.max_size)}
  has_one_attached :image
  scope :by_created_at, ->{order(created_at: :desc)}
  scope :load_feed, ->(user_ids){where("user_id IN (?)", user_ids)}

  def display_image
    image.variant resize_to_limit: [Settings.micropost.image.height,
                                    Settings.micropost.image.length]
  end
end
