require 'sqlite3'
require_relative 'reviews_database'
require_relative 'chef'
require_relative 'restaurant'

class ChefTenure

  attr_accessor :chef_id, :restaurant_id, :start_date, :end_date, :is_head_chef
  attr_accessor :id #make this a reader later?
  
  def self.find_all
    query = "SELECT * FROM cheftenure"
    tenure_list = ReviewsDatabase.instance.execute(query)
    tenure_list.map { |tenure_item| ChefTenure.parse(tenure_item) }
  end
  
  def self.find_by_id(id)
    query = "SELECT * FROM cheftenure WHERE id = ?"
    tenure_list = ReviewsDatabase.instance.execute(query, id)    
    tenure_list.empty? ? nil : parse(tenure_list[0])
  end

  def self.parse(tenure_item)
    ChefTenure.new(id: tenure_item["id"],
                   chef_id: tenure_item["chef_id"],
                   restaurant_id: tenure_item["restaurant_id"],
                   start_date: tenure_item["start_date"],
                   end_date: tenure_item["end_date"],
                   is_head_chef: tenure_item["is_head_chef"])
  end
  
  def initialize(options = {})
    @id = options[:id]
    @chef_id, @restaurant_id = options[:chef_id], options[:restaurant_id]
    @start_date, @end_date = options[:start_date], options[:end_date]
    @is_head_chef = options[:is_head_chef]
  end
  
  def self.save(cheftenure)
    #refactor later for saving existing restaurant with changed data
    #Also: refactor SQL later! Options hash, not "?" !!!
    query = <<-SQL
      INSERT INTO cheftenure (id, chef_id, restaurant_id, start_date, end_date, is_head_chef)
      VALUES (NULL, ?, ?, ?, ?, ?) #yeah we need a better way to do this
    SQL
    QuestionsDatabase.instance.execute(query, cheftenure.chef_id, cheftenure.restaurant_id,
                                       cheftenure.start_date, cheftenure.end_date,
                                       cheftenure.is_head_chef)
    true
  end  
  
end