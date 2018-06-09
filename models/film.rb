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

  def delete()
    sql = "DELETE FROM films WHERE films.id = $1"
    values = [@id]
    SqlRunner.run(sql, values)
  end

  def cancel()
    customers = find_all_customers_and_the_price()
    Customer.refund_tickets(customers)

    values = [@id]

    sql = "DELETE FROM tickets
    WHERE tickets.id IN (SELECT tickets.id FROM tickets
    INNER JOIN screenings ON screenings.id = tickets.screening_id
    WHERE screenings.film_id = $1)"
    SqlRunner.run(sql, values)

    sql = "DELETE FROM screenings WHERE screenings.film_id = $1"
    SqlRunner.run(sql, values)

    sql = "DELETE FROM films WHERE films.id = $1"
    SqlRunner.run(sql, values)
  end

  def find_all_customers_and_the_price()
    sql = "SELECT customers.* FROM screenings
    INNER JOIN tickets ON tickets.screening_id = screenings.id
    INNER JOIN customers ON tickets.customer_id = customers.id
    WHERE screenings.film_id = $1"
    values = [@id]
    results = SqlRunner.run(sql, values)
    return results.map {|result| [Customer.new(result), @price]}
  end

  def most_popular_screening()
    sql = "SELECT screenings.*, COUNT(tickets.screening_id) FROM screenings
    LEFT JOIN tickets ON tickets.screening_id = screenings.id
    WHERE screenings.film_id = $1 GROUP BY screenings.id"
    values = [@id]
    frequencies = SqlRunner.run(sql, values).to_a()
    most_popular = frequencies.max_by {|frequency| frequency["count"].to_i()}
    return Screening.new(most_popular)
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

  def self.find(id)
    sql = "SELECT * FROM films WHERE id = $1"
    values = [id]
    film = SqlRunner.run(sql, values)
    return Film.new(film[0])
  end

end
