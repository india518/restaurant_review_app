require 'sqlite3'
require_relative 'reviews_database'
require_relative 'restaurant_review'

class Critic
  
  attr_accessor :screen_name
  attr_reader :id
  
  def self.find_all
    query = "SELECT * FROM critics"
    critic_list = ReviewsDatabase.instance.execute(query)
    critic_list.map { |critic| Critic.new(critic) }
  end
  
  def self.find_by_id(id)
    query = "SELECT * FROM critics WHERE id = ?"
    critic_list = ReviewsDatabase.instance.execute(query, id)
    critic_list.empty? ? nil : Critic.new(critic_list[0])
  end
  
  def attrs
    { :screen_name => screen_name }
  end
  
  def initialize(options = {})
    @id, @screen_name = options.values_at("id", "screen_name")
  end
  
  def save
    if @id
      query = <<-SQL      
        UPDATE critics
           SET "screen_name" = :screen_name
         WHERE critics.id = :id
        SQL
      
      ReviewsDatabase.instance.execute(query, attrs.merge({ :id => id }))
    else
      query = <<-SQL
        INSERT INTO critics (id, screen_name)
        VALUES (NULL, :screen_name)
      SQL
    
      ReviewsDatabase.instance.execute(query, attrs)
    end
  end
  
  def reviews
    #return a list of all reviews this reviewer has writen
    query = <<-SQL
      SELECT *
        FROM restaurant_reviews
       WHERE critic_id = ?
    SQL
    
    review_list = ReviewsDatabase.instance.execute(query, id)
    review_list.map { |review| RestaurantReview.new(review) }
  end
  
  def average_review_score
    #returns a number: SUM(all scores by this critic)/number of reviews
    query = <<-SQL
      SELECT AVG(score)
        FROM restaurant_reviews
       WHERE critic_id = ?
    SQL
    
    ReviewsDatabase.instance.get_first_value(query, self.id)
  end
  
  def unreviewed_restaurants
    query = <<-SQL
           SELECT restaurants.*
             FROM restaurants
  LEFT OUTER JOIN restaurant_reviews
               ON restaurants.id = restaurant_reviews.restaurant_id
            WHERE restaurant_reviews.critic_id <> ? OR critic_id IS NULL
         GROUP BY restaurants.id
    SQL
    
    restaurant_list = ReviewsDatabase.instance.execute(query, self.id)
    restaurant_list.map { |restaurant| Restaurant.new(restaurant) }
  end
  
end