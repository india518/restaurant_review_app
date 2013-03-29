require 'sqlite3'
require_relative 'reviews_database'
require_relative 'restaurant'

class Critic
  
  attr_accessor :screen_name
  attr_accessor :id #make this a reader later?
  
  def self.find_all
    query = "SELECT * FROM critic"
    critic_list = ReviewsDatabase.instance.execute(query)
    critic_list.map { |critic| Critic.parse(critic) }
  end
  
  def self.find_by_id(id)
    query = "SELECT * FROM critic WHERE id = ?"
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
      INSERT INTO critic (id, screen_name)
      VALUES (NULL, ?)
    SQL
    
    QuestionsDatabase.instance.execute(query, critic.screen_name)
    true
  end

  def initialize(options = {})
    @id = options[:id]
    @screen_name = options[:screen_name]
  end
  
end