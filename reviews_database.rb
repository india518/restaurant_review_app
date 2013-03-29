require 'singleton'
require 'sqlite3'

class ReviewsDatabase < SQLite3::Database

  include Singleton

  def initialize
    super("restaurant_reviews.db")
    self.results_as_hash = true
    self.type_translation = true
  end

end
