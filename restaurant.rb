require 'sqlite3'
require_relative 'reviews_database'
require_relative 'restaurant_review'

class Restaurant
  
  attr_accessor :name, :chef_id, :neighborhood, :cuisine
  attr_reader :id
  
  def self.find_all
    query = "SELECT * FROM restaurants"
    restaurant_list = ReviewsDatabase.instance.execute(query)
    restaurant_list.map { |restaurant| Restaurant.new(restaurant) }
  end
  
  def self.find_by_id(id)
    query = "SELECT * FROM restaurants WHERE id = ?"
    restaurant_list = ReviewsDatabase.instance.execute(query, id)    
    restaurant_list.empty? ? nil : Restaurant.new(restaurant_list[0])
  end

  def self.by_neighborhood
    query = <<-SQL
      SELECT *
        FROM restaurants
    ORDER BY neighborhood
    SQL
    restaurant_list = ReviewsDatabase.instance.execute(query)
    restaurant_list.map { |restaurant| Restaurant.new(restaurant) }
  end
  
  def self.top_restaurants(n)
    #Find the top n restaurants with the best average review.
    query = <<-SQL
      SELECT restaurants.*
        FROM restaurant_reviews
        JOIN restaurants
          ON restaurant_reviews.restaurant_id = restaurants.id
    GROUP BY restaurant_id
    ORDER BY AVG(restaurant_reviews.score) DESC
       LIMIT ?      
    SQL

    restaurant_list = ReviewsDatabase.instance.execute(query, n)
    restaurant_list.map { |restaurant| Restaurant.new(restaurant) }        
  end
  
  def self.highly_reviewed_restaurants(min_reviews)
    #Returns restaurants that have at least min_reviews filed
    query = <<-SQL
      SELECT restaurants.*
        FROM restaurant_reviews
        JOIN restaurants
          ON restaurant_reviews.restaurant_id = restaurants.id
    GROUP BY restaurant_reviews.restaurant_id
      HAVING COUNT(*) >= ?
    SQL

    restaurant_list = ReviewsDatabase.instance.execute(query, min_reviews)
    restaurant_list.map { |restaurant| Restaurant.new(restaurant) }       
  end
  
  def attrs
      { :name => name, :chef_id => chef_id,
        :neighborhood => neighborhood, :cuisine => cuisine }
  end
    
  def initialize(options = {})
    # When creating a brand new restaurant:
    # Restaurant.new("name" = "<name_str>",
    #                "neighborhood" => "<neighborhood_str>", etc.)
    @id, @chef_id = options.values_at("id", "chef_id")
    @name, @neighborhood = options.values_at("name", "neighborhood")
    @cuisine = options["cuisine"]
  end
  
  def save
    if @id
      query = <<-SQL
      UPDATE restaurants
         SET "name" = :name, "neighborhood" = :neighborhood,
             "chef_id" = :chef_id, "cuisine" = :cuisine
       WHERE restaurants.id = :id
      SQL
      
      ReviewsDatabase.instance.execute(query, attrs.merge({ :id => id }))
    else
      query = <<-SQL
        INSERT INTO restaurants (id, name, chef_id, neighborhood, cuisine)
        VALUES (NULL, :name, :chef_id, :neighborhood, :cuisine)
      SQL
      ReviewsDatabase.instance.execute(query, attrs)
    end
    @id = ReviewsDatabase.instance.last_insert_row_id
  end
  
  def reviews
    #return all reviews for this restaurant
    query = <<-SQL
      SELECT *
        FROM restaurant_reviews
       WHERE restaurant_id = ?
    SQL
    
    review_list = ReviewsDatabase.instance.execute(query, self.id)
    review_list.map { |review| RestaurantReview.parse(review) }   
  end
  
  def average_review_score
    #return a number: SUM(scores for this restaurant)/total reviews
    query = <<-SQL
      SELECT AVG(score)
        FROM restaurant_reviews
       WHERE restaurant_id = ?
    SQL
        
    ReviewsDatabase.instance.get_first_value(query, self.id)
  end

end