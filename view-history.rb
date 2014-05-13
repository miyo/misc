require 'cfpropertylist'

def load_plist(str)
  return CFPropertyList::List.new(:file => str)
end

def NSDate2UnixTime(v)
  Time.at(Time.gm(2001, 1, 1).to_i + v.to_i)
end

list = load_plist("#{ENV['HOME']}/Library/Safari/History.plist")

def today?(t)
  today = Time.now
  b = Time.local(today.year, today.month, today.day, 0, 0, 0)
  e = Time.local(today.year, today.month, today.day, 23, 59, 59)
  return (b.to_i < t.to_i && t.to_i < e.to_i)
end

def print_info(v)
  puts "URL: #{v.value[""].value}" unless v.value[""] == nil
  puts "Title: #{v.value["title"].value}" unless v.value["title"] == nil
  puts "Date: #{NSDate2UnixTime(v.value["lastVisitedDate"].value)}" unless v.value["lastVisitedDate"] == nil
end

def timeslot(t)
  today = Time.now
  b = Time.local(today.year, today.month, today.day, 0, 0, 0)
  return (t.to_i - b.to_i) / (60 * 60)
end

def gen_graph(data)
  s = ""
  s << "var Canvas = require('term-canvas');" << "\n"
  s << "var canvas = new Canvas(80, 40), ctx = canvas.getContext('2d');" << "\n"
  s << "ctx.clear();" << "\n"
  y = 20
  w = 2
  data.each_with_index{|d,i|
    h = y * (d.to_f / data.max)
    s << "ctx.fillStyle = 'blue';" << "\n"
    s << "ctx.fillRect(#{3+(w+1)*i}, #{y-h.to_i}, #{w}, #{h.to_i});" << "\n"
    s << "ctx.fillStyle = 'white';" << "\n"
    s << "ctx.fillText('#{format("%2d", i)}', #{3+(w+1)*i}, #{y + 1});" << "\n"
    s << "ctx.fillStyle = 'white';" << "\n"
    s << "ctx.fillText('#{format("%2d", d)}', #{3+(w+1)*i}, #{y + 2});" << "\n"
  }
  s << "console.log('\\n');" << "\n"
  s << "ctx.resetState();" << "\n"
  open("fe.js", "w"){|f|
    f.puts(s)
  }
  system "node fe.js"
  system "rm fe.js"
end

accesses = []
timeslots = Array.new(24, 0)

list.value.value["WebHistoryDates"].value.each{|v|
  t = NSDate2UnixTime(v.value["lastVisitedDate"].value)
  next unless(today?(t))
  accesses << v
  #timeslots[timeslot(t)] += v.value["visitCount"].value.to_i
  timeslots[timeslot(t)] += 1
}

#accesses.each{|v|
#  print_info(v)
#}

#p timeslots
gen_graph(timeslots)
puts "#. of Today Acccess: #{accesses.size()}"
min = accesses.size() * 1
ratio = min.to_f * 100 / (24 * 60)
#puts "Rough estimated: #{min} min., #{ratio} %"
