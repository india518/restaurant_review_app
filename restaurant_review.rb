require 'sqlite3'
require_relative 'reviews_database'
require_relative 'restaurant'
require_relative 'critic'

class RestaurantReview
  attr_accessor :restaurant_id, :critic_id, :score, :review_date, :review
  attr_accessor :id #make this a reader later?
  
  def self.find_all
    query = "SELECT * FROM restaurantreview"
    review_list = ReviewsDatabase.instance.execute(query)
    review_list.map { |review| RestaurantReview.parse(review) }
  end
  
  def self.find_by_id(id)
    query = "SELECT * FROM restaurantreview WHERE id = ?"
    review_list = ReviewsDatabase.instance.execute(query, id)    
    review_list.empty? ? nil : parse(review_list[0])
  end
  
  def self.parse(review)
    RestaurantReview.new(id: review["id"],
                         restaurant_id: review["restaurant_id"],
                         critic_id: review["critic_id"],
                         score: review["score"],
                         review_date: review["review_date"],
                         review: review["review"])
  end
  
  def initialize(options = {})
    @id = options[:id]
    @restaurant_id, @critic_id = options[:restaurant_id], options[:critic_id]
    @score, @review_date = options[:score], options[:review_date]
    @review = options[:review]
  end
  
  def self.save(restaurant)
    #refactor later for saving existing restaurant with changed data
    #Also: refactor SQL later! Options hash, not "?" !!!
    query = <<-SQL
      INSERT INTO restaurant (id, restaurant_id, critic_id, score, review_date, review)
      VALUES (NULL, ?, ?, ?, ?, ?)
    SQL
    QuestionsDatabase.instance.execute(query, review.restaurant_id, review.critic_id,
                                       review.score, review.review_date, review.review)

    true
  end

  
end