require 'sqlite3'
require_relative 'reviews_database'
require_relative 'restaurant'
require_relative 'restaurant_review'

class Chef
  
  attr_accessor :first_name, :last_name, :mentor_id
  attr_reader :id
  
  def self.find_all
    query = "SELECT * FROM chefs"
    chef_list = ReviewsDatabase.instance.execute(query)
    chef_list.map { |chef| Chef.parse(chef) }
  end
  
  def self.find_by_id(id)
    query = "SELECT * FROM chefs WHERE id = ?"
    chef_list = ReviewsDatabase.instance.execute(query, id)
    
    p chef_list[0]
    
    chef_list.empty? ? nil : Chef.new(chef_list[0])
  end

  # def self.parse(chef)
  #   Chef.new(id: chef["id"],
  #            first_name: chef["first_name"],
  #            last_name: chef["last_name"],
  #            mentor_id: chef["mentor_id"])
  # end
  
  def attrs
      { :first_name => first_name, :last_name => last_name, :mentor_id => mentor_id }
  end
    
  def save
    if @id
      query = <<-SQL
      UPDATE chefs
         SET "first_name" = :first_name, "last_name" = :last_name, "mentor_id" = :mentor_id
       WHERE chefs.id = :id
      SQL
      
      ReviewsDatabase.instance.execute(query, attrs.merge({ :id => id }))
    else
      query = <<-SQL
        INSERT INTO chefs (id, first_name, last_name, mentor_id)
        VALUES (NULL, :first_name, :last_name, :mentor_id)
      SQL
      ReviewsDatabase.instance.execute(query, attrs)
    end
    
    @id = ReviewsDatabase.instance.last_insert_row_id
  end

  def initialize(options = {})
    # When creating a brand new chef:
    # Chef.new("first_name" = "<first_name_str>", "last_name" => "<last_name_str>")
    @id, @mentor_id = options.values_at("id", "mentor_id")
    @first_name, @last_name = options.values_at("first_name", "last_name")
  end
  
  def proteges
    #return a list of chef objects for which I am the mentor
    query = <<-SQL
      SELECT *
        FROM chefs
       WHERE mentor_id = ?
    SQL
    
    proteges_list = ReviewsDatabase.instance.execute(query, self.id)
    proteges_list.map { |proteges| Chef.parse(proteges) }
  end
  
  def num_proteges
    #proteges.length
    query = <<-SQL
      SELECT COUNT(*)
        FROM chefs
       WHERE mentor_id = ?
    SQL
    
    proteges = ReviewsDatabase.instance.get_first_value(query, self.id)
  end
  
  def co_workers
    query = <<-SQL
      SELECT chefs.*   
        FROM chef_tenures co_worker_tenures
        JOIN (SELECT *
                FROM chef_tenures
               WHERE chef_tenures.chef_id = ?) my_tenures
          ON co_worker_tenures.restaurant_id = my_tenures.restaurant_id
        JOIN chefs
          ON co_worker_tenures.chef_id = chefs.id
       WHERE (my_tenures.end_date >= co_worker_tenures.start_date) 
             AND (my_tenures.start_date <= co_worker_tenures.end_date)
             AND co_worker_tenures.chef_id != my_tenures.chef_id
    SQL
    
    co_worker_list = ReviewsDatabase.instance.execute(query, self.id)
    co_worker_list.map { |co_worker| Chef.parse(co_worker) }    
  end
  
  def reviews
    #when chef was head chef there
    query = <<-SQL
        
    SELECT restaurant_reviews.* 
      FROM restaurant_reviews    
      JOIN (SELECT restaurant_id, start_date, end_date
              FROM chef_tenures
             WHERE chef_id = ? AND is_head_chef = 1 ) AS my_tenures
        ON restaurant_reviews.restaurant_id = my_tenures.restaurant_id   
     WHERE restaurant_reviews.review_date
           BETWEEN my_tenures.start_date AND my_tenures.end_date
    SQL
    
    review_list = ReviewsDatabase.instance.execute(query, self.id)
    review_list.map { |review| RestaurantReview.parse(review) }           
  end
  
end











