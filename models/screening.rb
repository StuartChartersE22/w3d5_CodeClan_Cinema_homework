require_relative("../db/sql_runner_cinema.rb")
require_relative("./film.rb")
require_relative("./change_time.rb")

class Screening

  attr_reader(:id, :film_id)
  attr_accessor(:show_time)

  def initialize(details)
    @id = details["id"].to_i() if details["id"]
    @film_id = details["film_id"].to_i()
    @show_time = details["show_time"]
  end

#pure Ruby methods

  def change_time_by_mins(mins)
    @show_time = TimeChange.change_by_mins(@show_time, mins)
  end

  def change_time_by_hours(hours)
    @show_time = TimeChange.change_by_hours(@show_time, hours)
  end

#SQL instance methods

  def save()
    sql = "INSERT INTO screenings
    (film_id, show_time)
    VALUES
    ($1, $2)
    RETURNING id"
    values = [@film_id, @show_time]
    @id = SqlRunner.run(sql, values)[0]["id"].to_i()
  end

  def update()
    sql = "UPDATE screenings
    SET (film_id, show_time) = ($1, $2)
    WHERE id = $3"
    values = [@film_id, @show_time, @id]
    SqlRunner.run(sql, values)
  end

  def delete()
    sql = "DELETE FROM screenings
    WHERE screenings.id = $1"
    values = [@id]
    SqlRunner.run(sql, values)
  end

  def tickets()
    sql = "SELECT * FROM tickets
    WHERE tickets.screening_id = $1"
    values = [@id]
    tickets = SqlRunner.run(sql, values)
    return Ticket.map_tickets(tickets)
  end

  def cancel()
    Ticket.refund_screening(@id)
    
    sql = "DELETE FROM screenings
    WHERE screenings.id = $1"
    values = [@id]
    SqlRunner.run(sql, values)
  end

#SQL class methods

  def self.delete_all()
    sql = "DELETE FROM screenings"
    SqlRunner.run(sql)
  end

  def self.map_screenings(screenings)
    return screenings.map {|screening| Screening.new(screening)}
  end

  def self.all()
    sql = "SELECT * FROM screenings"
    screenings = SqlRunner.run(sql)
    return self.map_screenings(screenings)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM screenings WHERE id = $1"
    values = [id]
    screening = SqlRunner.run(sql, values)
    return Screening.new(screening[0])
  end

  def self.find_film_screenings(film_id)
    sql = "SELECT * FROM screenings WHERE film_id = $1"
    values = [film_id]
    film_details = SqlRunner.run(sql, values)
    return Film.map_films(film_details)
  end

end
