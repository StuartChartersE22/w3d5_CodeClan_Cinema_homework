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

#SQL class methods

  def self.delete_all()
    sql ="DELETE FROM screenings"
    SqlRunner.run(sql)
  end

end
