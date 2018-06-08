require_relative("../db/sql_runner_cinema.rb")

class Film

  attr_reader(:id, :name, :price)

  def initialize(details)
    @id = details["id"].to_i() if details["id"]
    @name = details["name"]
    @price = details["price"].to_i()
  end

  def save()
    sql = "INSERT INTO films
    (name, price)
    VALUES
    ($1, $2)
    RETURNING id"
    values = [@name, @price]
    @id = SqlRunner.run(sql, values)[0]["id"]
  end

  def self.map_films(films)
    return films.map {|film| Film.new(film)}
  end

  def self.all()
    sql = "SELECT * FROM films"
    films = SqlRunner.run(sql)
    Film.map_films(films)
  end

end
