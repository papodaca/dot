# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :rememberable,
    :validatable

  has_many :directories
  has_many :feeds, through: :directories
  has_many :articles, through: :feeds

  def password_salt
    'no salt'
  end

  def password_salt=(new_salt)
  end

  def root
    Directory.find_by(title: 'Root', user_id: id)
  end
end
