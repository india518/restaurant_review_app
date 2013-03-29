require 'sqlite3'
require_relative 'reviews_database'
require_relative 'chef'

class Restaurant
  attr_accessor :name, :chef_id, :neighborhood, :cuisine
  attr_accessor :id #make this a reader later?
  
  def self.find_all
    query = "SELECT * FROM restaurant"
    restaurant_list = ReviewsDatabase.instance.execute(query)
    restaurant_list.map { |restaurant| Restaurant.parse(restaurant) }
  end
  
  def self.find_by_id(id)
    query = "SELECT * FROM restaurant WHERE id = ?"
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
        FROM restaurant
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
      INSERT INTO restaurant (id, name, chef_id, neighborhood, cuisine)
      VALUES (NULL, ?, ?, ?, ?)
    SQL
    QuestionsDatabase.instance.execute(query, restaurant.name, restaurant.chef_id,
                                       restaurant.neighborhood, restaurant.cuisine)

    true
  end

end