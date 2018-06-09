require_relative("./film.rb")
require_relative("./customer.rb")
require_relative("../db/sql_runner_cinema.rb")

class Ticket

  attr_reader(:customer_id, :screening_id)

  def initialize(details)
    @id = details["id"].to_i() if details["id"]
    @customer_id = details["customer_id"].to_i()
    @screening_id = details["screening_id"].to_i()
  end

#SQL instance methods

  def save()
    sql = "INSERT INTO tickets
    (customer_id, screening_id)
    VALUES
    ($1, $2)
    RETURNING id"
    values = [@customer_id, @screening_id]
    @id = SqlRunner.run(sql, values)[0]["id"]
  end

  def update()
    sql = "UPDATE tickets
    SET
    (customer_id, screening_id) = ($1, $2)
    WHERE
    tickets.id = $3"
    values = [@customer_id, @screening_id, @id]
    SqlRunner.run(sql, values)
  end

  def price()
    sql = "SELECT films.price FROM films
    INNER JOIN screenings ON screenings.film_id = films.id
    WHERE screenings.id = $1"
    values = [@screening_id]
    return SqlRunner.run(sql, values)[0]["price"].to_i()
  end

  def cancel()
    tickets = Ticket.ticket_prices_by_screening_for_customers(@screening_id)
    Customer.refund_tickets(tickets)

    sql = "DELETE FROM tickets
    WHERE tickets.id = $1"
    values = [@id]
    results = SqlRunner.run(sql, values)
  end

#SQL class methods

  def self.map_tickets(tickets)
    return tickets.map {|ticket| Ticket.new(ticket)}
  end

  def self.all()
    sql = "SELECT * FROM tickets"
    tickets = SqlRunner.run(sql)
    Ticket.map_tickets(tickets)
  end

  def self.delete_all()
    sql ="DELETE FROM tickets"
    SqlRunner.run(sql)
  end

  def self.refund_screening(screening_id)
    tickets = self.ticket_prices_by_screening_for_customers(screening_id)
    Customer.refund_tickets(tickets)

    sql = "DELETE FROM tickets
    WHERE screening_id = $1"
    values = [screening_id]
    ticket_details = SqlRunner.run(sql, values)
  end

  # def self.cancel_screening(screening_id)
  #   pg_object_of_cus_id_and_price = self.ticket_prices_by_screening_for_customers(screening_id)
  #
  #   return if pg_object_of_cus_id_and_price.to_a().length() == 0
  #
  #   sql = "UPDATE customers SET wallet = (wallet - $1.price)
  #   WHERE customers.id = $1.customer_id"
  #   values = [pg_object_of_cus_id_and_price]
  #   SqlRunner.run_unsanitised(sql, values)
  #
  #   sql = "DELETE FROM tickets
  #     WHERE screening_id = $1"
  #   values = [id_screening]
  #   SqlRunner.run(sql, values)
  # end

  def self.ticket_prices_by_screening_for_customers(screening_id)
    sql = "SELECT customers.*, films.price FROM films
    INNER JOIN screenings ON screenings.film_id = films.id
    INNER JOIN tickets ON tickets.screening_id = screenings.id
    INNER JOIN customers ON tickets.customer_id = customers.id
    WHERE screening_id = $1"
    values = [screening_id]
    results = SqlRunner.run(sql, values)
    return results.map {|result| [Customer.new(result), result["price"].to_i()]}
  end

end
