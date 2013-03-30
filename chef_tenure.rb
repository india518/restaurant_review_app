require 'sqlite3'
require_relative 'reviews_database'

class ChefTenure

  attr_accessor :chef_id, :restaurant_id, :start_date, :end_date, :is_head_chef
  attr_reader :id
  
  def self.find_all
    query = "SELECT * FROM chef_tenures"
    tenure_list = ReviewsDatabase.instance.execute(query)
    tenure_list.map { |tenure_item| ChefTenure.new(tenure_item) }
  end
  
  def self.find_by_id(id)
    query = "SELECT * FROM chef_tenures WHERE id = ?"
    tenure_list = ReviewsDatabase.instance.execute(query, id)    
    tenure_list.empty? ? nil : ChefTenure.new(tenure_list[0])
  end

  def attrs
      { :chef_id => chef_id, :restaurant_id => restaurant_id,
        :start_date => start_date, :end_date => end_date,
        :is_head_chef => is_head_chef }
  end
  
  def initialize(options = {})
    @id, @is_head_chef = options.values_at("id", "is_head_chef")
    @chef_id, @restaurant_id = options.values_at("chef_id", "restaurant_id")
    @start_date = options["start_date"].to_s
    @end_date = options["end_date"].to_s
  end
  
  def save
    if @id
      query = <<-SQL
      UPDATE chef_tenures
         SET "chef_id" = :chef_id, "restaurant_id" = :restaurant_id,
             "start_date" = :start_date, "end_date" = :end_date,
             "is_head_chef" = :is_head_chef
       WHERE chef_tenures.id = :id
      SQL
      
      ReviewsDatabase.instance.execute(query, attrs.merge({ :id => id }))
    else
      query = <<-SQL
        INSERT INTO chef_tenures (id, chef_id, restaurant_id, start_date,
                                  end_date, is_head_chef)
        VALUES (NULL, :chef_id, :restaurant_id, :start_date, :end_date,
                      :is_head_chef)
      SQL
      
      ReviewsDatabase.instance.execute(query, attrs)
    end
    
    @id = ReviewsDatabase.instance.last_insert_row_id
  end  
  
end