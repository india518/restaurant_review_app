require 'sqlite3'
require_relative 'reviews_database'
require_relative 'restaurant'
require_relative 'restaurant_review'

class Chef
  
  attr_accessor :first_name, :last_name, :mentor_id
  attr_accessor :id #make this a reader later?
  
  def self.find_all
    query = "SELECT * FROM chefs"
    chef_list = ReviewsDatabase.instance.execute(query)
    chef_list.map { |chef| Chef.parse(chef) }
  end
  
  def self.find_by_id(id)
    query = "SELECT * FROM chefs WHERE id = ?"
    chef_list = ReviewsDatabase.instance.execute(query, id)
    chef_list.empty? ? nil : Chef.parse(chef_list[0])
  end

  def self.parse(chef)
    Chef.new(id: chef["id"],
             first_name: chef["first_name"],
             last_name: chef["last_name"],
             mentor_id: chef["mentor_id"])
  end
  
  def self.save(chef)
    if @id
      query = <<-SQL
      UPDATE chefs
         SET "first_name" = ?, "last_name" = ?, "mentor_id" = ?
       WHERE chefs.id = ?
      SQL
      
      ReviewsDatabase.instance.execute(query, chef.first_name, 
                                      chef.last_name, chef.mentor_id, chef.id)
    else
      query = <<-SQL
        INSERT INTO chefs (id, first_name, last_name, mentor_id)
        VALUES (NULL, ?, ?, ?)
      SQL
      ReviewsDatabase.instance.execute(query, chef.first_name, chef.last_name,
                                       chef.mentor_id)
    end
    
    @id = ReviewsDatabase.instance.last_insert_row_id
  end

  def initialize(options = {})
    @id = options[:id]
    @first_name, @last_name = options[:first_name], options[:last_name]
    @mentor_id = options[:mentor_id]
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











