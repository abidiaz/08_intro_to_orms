class Tweet
  attr_accessor :message, :username, :id
  
  def self.all
    sql = <<-SQL
    SELECT * FROM tweets;
    SQL

    results = DB[:conn].execute(sql)
    results.collect do |result|
      Tweet.new(result)
    end
  end

  def initialize(options={}) 
    @message = options['message']
    @username = options['username']
    @id = options['id']
  end

  def self.find(id)
    sql = "SELECT * FROM tweets WHERE tweets.id = ?;"

    results = DB[:conn].execute(sql, id)

    if results.empty?
      raise "No Tweet Found"
    else 
      self.new(results.first) # pulls the single element from the array produced by .execute
    end 
  end

  def save
    if @id
      sql = "UPDATE tweets SET message = ? WHERE id = ?;"
      results = DB[:conn].execute(sql, message, id)

    else
      # Make a call to the db to create a row with a message and a username value
      sql = 'INSERT INTO tweets (username, message) VALUES (?,?);'
      DB[:conn].execute(sql, username, message)

      # Find the row that was just inserted and set the id from that row to this tweet's id
      sql = 'SELECT id FROM tweets ORDER BY id DESC LIMIT 1;'
      results = DB[:conn].execute(sql)
      self.id = results.first['id']
      
      # Return the tweet
      self
    end
  end
end