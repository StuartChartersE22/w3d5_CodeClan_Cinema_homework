require_relative("../db/sql_runner_cinema.rb")
require_relative("./film.rb")

class Screening

  attr_reader(:id, :film_id, :show_time)

  def initialize(details)
    @id = details["id"].to_i() if details["id"]
    @film_id = details["film_id"].to_i()
    @show_time = details["show_time"]
  end

  def save()
    sql = "INSERT INTO screenings
    (film_id, show_time)
    VALUES
    ($1, $2)
    RETURNING id"
    values = [@film_id, @show_time]
    @id = SqlRunner.run(sql, values)[0]["id"].to_i()
  end

  def self.delete_all()
    sql ="DELETE FROM screenings"
    SqlRunner.run(sql)
  end

end
