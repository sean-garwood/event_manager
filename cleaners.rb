# frozen_string_literal: true

def bad?(number)
  number = number.to_s
  if !(10..11).include?(number.length) || number.length == 11 && number[0] != '1'
    true
  else
    false
  end
end

def clean_phone_number(phone_number)
  phone_number.to_s.rjust(10, '0')[-10..-1] unless bad?(phone_number)
end

def clean_regdate(regdate)
  Time.parse(regdate.split(' ')[1]).hour
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end
