class Advertisement < ActiveRecord::Base
  validates_presence_of :image_url, :link_url, :alt_text
end
