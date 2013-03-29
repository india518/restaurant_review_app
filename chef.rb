require 'sqlite3'
require_relative 'reviews_database'

class Chef
  
  attr_accessor :first_name, :last_name, :mentor_id
  attr_accessor :id #make this a reader later?
  
  def self.find_all
    query = "SELECT * FROM chef"
    chef_array = ReviewsDatabase.instance.execute(query)
  end
  
  def self.find_by_id(id)
    query = "SELECT * FROM chef WHERE id = ?"
    chef_array = ReviewsDatabase.instance.execute(query, id)
    chef_array.empty? ? nil : parse(chef_array[0])
  end

  def self.parse(chef_array)
    chef = Chef.new(id: chef_array["id"],
                    first_name: chef_array["first_name"],
                    last_name: chef_array["last_name"],
                    mentor_id: chef_array["mentor_id"])
  end
  
  def self.save(chef)
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