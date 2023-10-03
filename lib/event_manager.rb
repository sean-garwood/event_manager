# frozen_string_literal: true

require 'date'
require 'csv'
require 'erb'
require 'google/apis/civicinfo_v2'
require_relative '../cleaners'

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue
    'You can find your reps by checking the internet'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename = "output/thanks_#{id}.html"
  File.open(filename, 'w') { |file| file.puts form_letter }
end

puts "Event Manager initialized.\n\n"

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

registration_hours = []
registration_days = []
contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  # form_letter = erb_template.result(binding)
  # save_thank_you_letter(id, form_letter)
  registration_time = get_registration_hour(row[:regdate])
  registration_day = get_registration_day(row[:regdate])
  begin
    registration_hours << registration_time
  rescue
    registration_hours << 99
  end
end

tally_reg_hours = registration_hours.reduce(Hash.new(0)) do |best_hour, hour|
  best_hour[hour] += 1
  best_hour
end

best_hour = tally_reg_hours.max_by { |k, v| v }[0]

puts "#{best_hour}:00 is best hour to advertise (unless you're Disco Stu.)"
