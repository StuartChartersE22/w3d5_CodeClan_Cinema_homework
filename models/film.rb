require_relative("../db/sql_runner_cinema.rb")
require_relative("./customer.rb")

class Film

  attr_reader(:id, :name)
  attr_accessor(:price)

  def initialize(details)
    @id = details["id"].to_i() if details["id"]
    @name = details["name"]
    @price = details["price"].to_i()
  end

#Sql instance methods

  def save()
    sql = "INSERT INTO films
    (name, price)
    VALUES
    ($1, $2)
    RETURNING id"
    values = [@name, @price]
    @id = SqlRunner.run(sql, values)[0]["id"]
  end

  def update()
    sql = "UPDATE films
    SET
    (name, price) = ($1, $2)
    WHERE
    films.id = $3"
    values = [@name, @price, @id]
    SqlRunner.run(sql, values)
  end

  def audience()
    sql = "SELECT customers.* FROM films
    INNER JOIN screenings ON screenings.film_id = films.id
    INNER JOIN tickets ON tickets.screening_id = screenings.id
    INNER JOIN customers ON tickets.customer_id = customers.id
    WHERE screenings.film_id = $1"
    values = [@id]
    customers = SqlRunner.run(sql, values)
    return Customer.map_customers(customers)
  end

  def number_of_audience_members()
    sql = "SELECT COUNT(*) FROM tickets
      WHERE tickets.screening_id = $1"
    values = [@id]
    return SqlRunner.run(sql, values)[0]["count"].to_i()
  end

#Sql class methods

  def self.map_films(films)
    return films.map {|film| Film.new(film)}
  end

  def self.all()
    sql = "SELECT * FROM films"
    films = SqlRunner.run(sql)
    Film.map_films(films)
  end

  def self.delete_all()
    sql ="DELETE FROM films"
    SqlRunner.run(sql)
  end

end
