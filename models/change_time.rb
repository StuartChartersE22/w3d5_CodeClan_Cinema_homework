class TimeChange

  def self.change_by_mins(time_as_string, minutes)
    time_as_array = time_as_string.split(":")

    sec = time_as_array[2].to_i()
    minute = (time_as_array[1].to_i() + minutes)%60
    hour = (time_as_array[0].to_i() + (time_as_array[1].to_i() + minutes)/60)%24

    return "%02d:%02d:%02d" % [hour, minute, sec]
  end

  def self.change_by_hours(time_as_string, hours)
    time_as_array = time_as_string.split(":")

    sec = time_as_array[2].to_i()
    minute = time_as_array[1].to_i()
    hour = (time_as_array[0].to_i() + hours)%24

    return "%02d:%02d:%02d" % [hour, minute, sec]
  end

end
