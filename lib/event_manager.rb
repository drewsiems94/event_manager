require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

#def save_thank_you_letter(id,form_letter)
  #Dir.mkdir('output') unless Dir.exist?('output')

  #filename = "output/thanks_#{id}.html"

  #File.open(filename, 'w') do |file|
    #file.puts form_letter
  #end
#end

def clean_phone_number(number)
  num_string = number.to_s.gsub(/[^\d]/, '')
  if num_string.length == 10
    num_string
  elsif num_string.length == 11 && num_string[0] == '1'
    num_string[1..-1]
  else
    "Invalid number!"
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

#template_letter = File.read('form_letter.erb')
#erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  #legislators = legislators_by_zipcode(zipcode)
  phone_number = clean_phone_number(row[:homephone])

  #form_letter = erb_template.result(binding)

  #save_thank_you_letter(id,form_letter)
end

def most_common_hour
  contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
  )
  hours = []
  contents.each do |row|
    reg_date = row[:regdate]
    reg_hour = Time.strptime(reg_date, '%m/%d/%y %k:%M').strftime('%k')
    hours.push(reg_hour)
  end
  common_hour = hours.reduce(Hash.new(0)) do |result, hour|
    result[hour] += 1
    result
  end
  common_hour.key(common_hour.values.max)
end

def most_common_day
  contents = CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
  )
  days = []
  contents.each do |row|
    reg_date = row[:regdate]
    reg_day = Time.strptime(reg_date, '%m/%d/%y').strftime('%A')
    days.push(reg_day)
  end
  common_day = days.reduce(Hash.new(0)) do |result, day|
    result[day] += 1
    result
  end
  common_day.key(common_day.values.max)
end
