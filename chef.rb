require 'sqlite3'
require_relative 'reviews_database'
require_relative 'restaurant'

class Chef
  
  attr_accessor :first_name, :last_name, :mentor_id
  attr_accessor :id #make this a reader later?
  
  def self.find_all
    query = "SELECT * FROM chef"
    chef_list = ReviewsDatabase.instance.execute(query)
    chef_list.map { |chef| Chef.parse(chef) }
  end
  
  def self.find_by_id(id)
    query = "SELECT * FROM chef WHERE id = ?"
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
    #refactor later for saving existing chef with changed data
    query = <<-SQL
      INSERT INTO chef (id, first_name, last_name, mentor_id)
      VALUES (NULL, ?, ?, ?)
    SQL
    
    QuestionsDatabase.instance.execute(query, chef.first_name, chef.last_name, chef.mentor_id)
    true
  end

  def initialize(options = {})
    @id = options[:id]
    @first_name, @last_name = options[:first_name], options[:last_name]
    @mentor_id = options[:mentor_id]
  end
  
end