# == Schema Information
#
# Table name: tags
#
#  id         :uuid             not null, primary key
#  title      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Tag < ApplicationRecord
  has_and_belongs_to_many :articles

  def self.from_list(list)
    list.map { |item| item.split(',') }.flatten.map do |item|
      Tag.find_or_create_by(title: item)
    end
  end
end
