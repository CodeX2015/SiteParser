class Project < ActiveRecord::Base
  validates :link, uniqueness: true, length: {minimum: 10}
end
