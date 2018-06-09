require_relative("../db/sql_runner_cinema.rb")
require_relative("./film.rb")
require_relative("./ticket.rb")

class Customer

  attr_reader(:id, :name, :wallet)

  def initialize(details)
    @id = details["id"].to_i() if details["id"]
    @name = details["name"]
    @wallet = details["wallet"].to_i()
  end

# Pure Ruby methods
  def remove_cash(amount)
    @wallet -= amount
  end

# Sql instance methods
  def save()
    sql = "INSERT INTO customers
    (name, wallet)
    VALUES
    ($1, $2)
    RETURNING id"
    values = [@name, @wallet]
    @id = SqlRunner.run(sql, values)[0]["id"]
  end

  def update()
    sql = "UPDATE customers
    SET
    (name, wallet) = ($1, $2)
    WHERE
    customers.id = $3"
    values = [@name, @wallet, @id]
    SqlRunner.run(sql, values)
  end

  def films()
    sql = "SELECT films.* FROM customers
      INNER JOIN tickets ON tickets.customer_id = customers.id
      INNER JOIN screenings ON tickets.screening_id = screenings.id
      INNER JOIN films ON screenings.film_id = films.id
      WHERE tickets.customer_id = $1"
    values = [@id]
    films = SqlRunner.run(sql, values)
    return Film.map_films(films)
  end

  def buy_ticket(film_id)
    sql = "SELECT films.price FROM films
      WHERE films.id = $1"
    values = [film_id]
    film_price = SqlRunner.run(sql, values)[0]["price"].to_i()

    return if wallet < film_price

    remove_cash(film_price)
    update()
    ticket = Ticket.new({
      "customer_id" => @id,
      "film_id" => film_id
      })
    ticket.save()
  end

  def number_of_tickets()
    sql = "SELECT COUNT(*) FROM tickets
      WHERE tickets.customer_id = $1"
    values = [@id]
    return SqlRunner.run(sql, values)[0]["count"].to_i()
  end

  def delete()
    sql = "DELETE FROM customers WHERE customers.id = $1"
    values = [@id]
    SqlRunner.run(sql, values)
  end

#Sql class methods
  def self.map_customers(customers)
    return customers.map {|customer| Customer.new(customer)}
  end

  def self.all()
    sql = "SELECT * FROM customers"
    customers = SqlRunner.run(sql)
    Customer.map_customers(customers)
  end

  def self.delete_all()
    sql ="DELETE FROM customers"
    SqlRunner.run(sql)
  end

  def self.find(id)
    sql = "SELECT * FROM customers WHERE id = $1"
    values = [id]
    customer = SqlRunner.run(sql, values)
    return Customer.new(customer[0])
  end

  def self.refund_tickets(array_of_hash_customer_id_to_price_paid)
    array_of_hash_customer_id_to_price_paid.each do |entry|
      customer = self.find(entry["customer_id"])
      customer.remove_cash(-(entry["price"].to_i()))
      customer.update()
    end
  end

end
