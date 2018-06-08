require_relative("../db/sql_runner_cinema.rb")

class Customer

  attr_reader(:id, :name, :wallet)

  def initialize(details)
    @id = details["id"].to_i() if details["id"]
    @name = details["name"]
    @wallet = details["wallet"].to_i()
  end

  def save()
    sql = "INSERT INTO customers
    (name, wallet)
    VALUES
    ($1, $2)
    RETURnING id"
    values = [@name, @wallet]
    @id = SqlRunner.run(sql, values)[0]["id"]
  end

end
