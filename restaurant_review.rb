require 'sqlite3'
require_relative 'reviews_database'

class RestaurantReview
  
  attr_accessor :restaurant_id, :critic_id, :score, :review_date, :review
  attr_reader :id
  
  def self.find_all
    query = "SELECT * FROM restaurant_reviews"
    review_list = ReviewsDatabase.instance.execute(query)
    review_list.map { |review| RestaurantReview.new(review) }
  end
  
  def self.find_by_id(id)
    query = "SELECT * FROM restaurant_reviews WHERE id = ?"
    review_list = ReviewsDatabase.instance.execute(query, id)    
    review_list.empty? ? nil : RestaurantReview.new(review_list[0])
  end
  
  def attrs
      { :restaurant_id => restaurant_id, :critic_id => critic_id,
        :score => score, :review_date => review_date, :review => review }
  end
  
  def initialize(options = {})
    @id, @restaurant_id = options.values_at("id", "restaurant_id")
    @critic_id, @score = options.values_at("critic_id", "score")
    @review_date = options["review_date"].to_s
    @review = options["review"]
  end
  
  def save
    if @id
      query = <<-SQL
      UPDATE restaurant_reviews
         SET "restaurant_id" = :restaurant_id, "critic_id" = :critic_id,
             "score" = :score, "review_date" = :review_date, "review" = :review
       WHERE restaurant_reviews.id = :id
      SQL
      
      ReviewsDatabase.instance.execute(query, attrs.merge({ :id => id }))
    else
      query = <<-SQL
        INSERT INTO restaurant_reviews (id, restaurant_id, critic_id, score, review_date, review)
        VALUES (NULL, :restaurant_id, :critic_id, :score, :review_date, :review)
      SQL
      
      ReviewsDatabase.instance.execute(query, attrs)
    end
    
    @id = ReviewsDatabase.instance.last_insert_row_id
  end

end