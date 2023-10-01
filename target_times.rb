# frozen_string_literal: true

def clean_regdate(regdate)
  Time.parse(regdate)
end

def registration_hour(regdate)
  Time.new(clean_regdate(regdate)).hour
end
