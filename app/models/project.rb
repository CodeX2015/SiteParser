class Project < ActiveRecord::Base
  validates :link, :title, uniqueness: true, length: {minimum: 10}
end
