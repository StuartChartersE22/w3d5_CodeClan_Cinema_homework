require_relative("../db/sql_runner_cinema.rb")

class Film

  attr_reader(:id, :name, :price)

  def initianlize(details)
    @id = details["id"].to_i() if details["id"]
    @name = details["name"]
    @price = details["price"].to_i()
  end

end
