require 'sqlite3'
require_relative 'reviews_database'
require_relative 'chef'

class Restaurant
  attr_accessor :name, :chef_id, :neighborhood, :cuisine
  attr_accessor :id #make this a reader later?
  
  def self.find_all
    query = "SELECT * FROM restaurants"
    restaurant_list = ReviewsDatabase.instance.execute(query)
    restaurant_list.map { |restaurant| Restaurant.parse(restaurant) }
  end
  
  def self.find_by_id(id)
    query = "SELECT * FROM restaurants WHERE id = ?"
    restaurant_list = ReviewsDatabase.instance.execute(query, id)    
    restaurant_list.empty? ? nil : parse(restaurant_list[0])
  end

  def self.parse(restaurant)
    Restaurant.new(id: restaurant["id"],
                   name: restaurant["name"],
                   chef_id: restaurant["chef_id"],
                   neighborhood: restaurant["neighborhood"],
                   cuisine: restaurant["cuisine"])
  end
  
  def self.by_neighborhood
    query = <<-SQL
      SELECT *
        FROM restaurants
    ORDER BY neighborhood
    SQL
    restaurant_list = ReviewsDatabase.instance.execute(query)
    restaurant_list.map { |restaurant| Restaurant.parse(restaurant) }
  end
  
  def initialize(options = {})
    @id = options[:id]
    @name = options[:name]
    @chef_id = options[:chef_id]
    @neighborhood, @cuisine = options[:neighborhood], options[:cuisine]
  end
  
  def self.save(restaurant)
    #refactor later for saving existing restaurant with changed data
    #Also: refactor SQL later! Options hash, not "?" !!!
    query = <<-SQL
      INSERT INTO restaurants (id, name, chef_id, neighborhood, cuisine)
      VALUES (NULL, ?, ?, ?, ?)
    SQL
    ReviewsDatabase.instance.execute(query, restaurant.name, restaurant.chef_id,
                                     restaurant.neighborhood, restaurant.cuisine)
    true
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