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

  def buy_ticket(screening_id)
    sql = "SELECT films.price, screenings.capacity, COUNT(tickets.id) FROM screenings
      INNER JOIN films ON films.id = screenings.film_id
      INNER JOIN tickets ON tickets.screening_id = screenings.id
      WHERE screenings.id = $1 GROUP BY (films.price, screenings.capacity)"
    values = [screening_id]
    details = SqlRunner.run(sql, values)
    screening_price = details[0]["price"].to_i()
    screening_capacity = details[0]["capacity"].to_i()
    number_attending = details[0]["count"].to_i()

    return if wallet < screening_price || number_attending >= screening_capacity

    remove_cash(screening_price)
    update()
    ticket = Ticket.new({
      "customer_id" => @id,
      "screening_id" => screening_id
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

  def force_delete()
    sql = "DELETE FROM tickets WHERE tickets.customer_id = $1"
    values = [@id]
    SqlRunner.run(sql, values)
    delete()
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

  def self.find_customers(array_of_ids)
    sql = "SELECT * FROM customers WHERE id IN $1"
    values = [array_of_ids]
    customers = SqlRunner.run(sql, values)
    return self.map_customers(customers)
  end

  # def self.refund_tickets(pg_object_customer_details_and_price)
  #   sql = "UPDATE customers SET wallet = (wallet - $1.price)
  #   WHERE customers.id IN $1"
  #   values = [pg_object_customer_details_and_price]
  #   SqlRunner.run(sql, values)
  # end

  def self.refund_tickets(array_of_array_customer__price_paid)
    array_of_array_customer__price_paid.each do |entry|
      customer = entry[0]
      customer.remove_cash(-entry[1])
      customer.update()
    end
  end

end
