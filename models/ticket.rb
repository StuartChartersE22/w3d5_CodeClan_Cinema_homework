require_relative("./film.rb")
require_relative("./customer.rb")
require_relative("../db/sql_runner_cinema.rb")

class Ticket

  def initialize(details)
    @id = details["id"].to_i() if details["id"]
    @customer_id = details["customer_id"].to_i()
    @film_id = details["film_id"].to_i()
  end

  def save()
    sql = "INSERT INTO tickets
    (customer_id, film_id)
    VALUES
    ($1, $2)
    RETURNING id"
    values = [@customer_id, @film_id]
    @id = SqlRunner.run(sql, values)[0]["id"]
  end

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

end
