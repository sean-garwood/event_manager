# frozen_string_literal: true

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
contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  # form_letter = erb_template.result(binding)
  # save_thank_you_letter(id, form_letter)
  registration_time = clean_regdate(row[:regdate])
  begin
    registration_hours << registration_time
  rescue
    registration_hours << 99
  end
  puts "#{name} #{id} #{registration_time} #{registration_hours}"
end

tally_reg_hours = registration_hours.reduce(Hash.new(0)) do |best_hour, hour|
  best_hour[hour] += 1
  best_hour
end

puts tally_reg_hours
puts(tally_reg_hours.max_by { |k, v| v })
