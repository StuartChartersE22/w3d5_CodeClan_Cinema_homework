require("pry")
require_relative("./models/film.rb")
require_relative("./models/customer.rb")
require_relative("./models/ticket.rb")
require_relative("./models/screening.rb")

Ticket.delete_all()
Screening.delete_all()
Customer.delete_all()
Film.delete_all()

customer1 = Customer.new({
  "name" => "Stuart",
  "wallet" => 5000
})

customer2 = Customer.new({
  "name" => "Joe",
  "wallet" => 1000
})

customer3 = Customer.new({
  "name" => "Ro",
  "wallet" => 10000
})

customer1.save()
customer2.save()
customer3.save()

film1 = Film.new({
  "name" => "Crank",
  "price" => 500
})

film2 = Film.new({
  "name" => "Dumbo",
  "price" => 750
})

film3 = Film.new({
  "name" => "Anastasia",
  "price" => 1500
})

film1.save()
film2.save()
film3.save()

screening1 = Screening.new({
  "film_id" => film1.id(),
  "show_time" => "12:45"
  })

screening2 = Screening.new({
  "film_id" => film1.id(),
  "show_time" => "00:15"
  })

screening3 = Screening.new({
  "film_id" => film1.id(),
  "show_time" => "13:00"
  })

screening1.save()
screening2.save()
screening3.save()

ticket1 = Ticket.new({
  "customer_id" => customer1.id(),
  "screening_id" => screening3.id()
})

ticket2 = Ticket.new({
  "customer_id" => customer2.id(),
  "screening_id" => screening1.id()
})

ticket3 = Ticket.new({
  "customer_id" => customer1.id(),
  "screening_id" => screening2.id()
})

ticket1.save()
ticket2.save()
ticket3.save()

binding.pry
nil
