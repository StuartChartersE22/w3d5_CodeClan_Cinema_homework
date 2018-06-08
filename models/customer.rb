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

end
