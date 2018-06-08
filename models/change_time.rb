class TimeChange

  def self.change_by_mins(time_as_string, minutes)
    time_as_array = time_as_string.split(":")
    minute = (time_as_array[1].to_i() + minutes)%60
    hour = (time_as_array[0].to_i() + (time_as_array[1].to_i() + minutes)/60)%24
    return "#{hour}:#{minute}"
  end

  def self.change_by_hours(time_as_string, hours)
    time_as_array = time_as_string.split(":")
    minute = time_as_array[1].to_i()
    hour = (time_as_array[0].to_i() + hours)%24
    return "#{hour}:#{minute}"
  end

end
