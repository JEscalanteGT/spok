require 'active_support'
require 'active_support/core_ext'
require 'set'
require 'yaml'

module Workday
  # Hash of Arrays containing Dates of holidays
  # Brasil  => 2001 - 2078
  # Bovespa => 1993 - 2022
  # TODO: add holidays before 2001 for :brasil (use :bovespa to infer?)
  # TODO: remove weekend dates from :brasil
  holidays_file = File.join(File.dirname(__FILE__), "config/holidays.yml")
  holidays = YAML.load_file(holidays_file)

  HOLIDAYS ||= {
    :brasil => Set.new(holidays["brasil"]),
    :bovespa => Set.new(holidays["bovespa"])
  }

  def restday?(calendar = :brasil)
    weekday = self.wday
    weekday == 0 || #saturday
    weekday == 6 || #sunday
    HOLIDAYS[calendar].include?(self)
  end

  def workday?(calendar = :brasil)
    !restday?(calendar)
  end

  def last_workday(calendar = :brasil)
    return self if workday?(calendar)
    (self - 1.day).last_workday(calendar)
  end

  def next_workday(calendar = :brasil)
    return self if workday?(calendar)
    (self + 1.day).next_workday(calendar)
  end
end

module Workdays
  DATE_FORMAT = '%Y%m%d'

  def as_string(format = DATE_FORMAT)
    self.map{ |date| date.strftime(format) }
  end
end
