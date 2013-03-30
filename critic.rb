require 'sqlite3'
require_relative 'reviews_database'
require_relative 'restaurant_review'

class Critic
  
  attr_accessor :screen_name
  attr_accessor :id #make this a reader later?
  
  def self.find_all
    query = "SELECT * FROM critics"
    critic_list = ReviewsDatabase.instance.execute(query)
    critic_list.map { |critic| Critic.parse(critic) }
  end
  
  def self.find_by_id(id)
    query = "SELECT * FROM critics WHERE id = ?"
    critic_list = ReviewsDatabase.instance.execute(query, id)
    critic_list.empty? ? nil : Critic.parse(critic_list[0])
  end

  def self.parse(critic)
    Critic.new(id: critic["id"],
               screen_name: critic["screen_name"])
  end
  
  def self.save(critic)
    #refactor later for saving existing chef with changed data
    query = <<-SQL
      INSERT INTO critics (id, screen_name)
      VALUES (NULL, ?)
    SQL
    
    ReviewsDatabase.instance.execute(query, critic.screen_name)
    true
  end

  def initialize(options = {})
    @id = options[:id]
    @screen_name = options[:screen_name]
  end
  
  def reviews
    #return a list of all reviews this reviewer has writen
    query = <<-SQL
      SELECT *
        FROM restaurant_reviews
       WHERE critic_id = ?
    SQL
    
    review_list = ReviewsDatabase.instance.execute(query, self.id)
    review_list.map { |review| RestaurantReview.parse(review) }
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
    restaurant_list.map { |restaurant| Restaurant.parse(restaurant) }
  end
  
end





















