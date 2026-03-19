# frozen_string_literal: true

require_relative "test_helper"
require "active_model"

class ModelTest < Minitest::Test
  class Venue
    include ActiveModel::Model
    include ActiveModel::Attributes
    include OpeningHours::Model

    attribute :timezone, :string
  end

  class VenueWithCustomColumn
    include ActiveModel::Model
    include ActiveModel::Attributes
    include OpeningHours::Model
    opening_hours_column :hours_json

    attribute :timezone, :string
  end

  def test_open_uses_backing_data_hash
    venue = Venue.new
    venue.opening_hours = { "mon" => ["09:00-17:00"] }

    assert venue.open?(at: Time.new(2024, 1, 1, 10, 0, 0))
  end

  def test_open_reflects_opening_hours_changes
    venue = Venue.new
    venue.opening_hours = { "mon" => ["09:00-17:00"] }

    refute venue.open?(at: Time.new(2024, 1, 2, 10, 0, 0))

    venue.opening_hours = { "tue" => ["09:00-17:00"] }

    assert venue.open?(at: Time.new(2024, 1, 2, 10, 0, 0))
  end

  def test_define_hours_updates_schedule_and_opening_hours_hash
    venue = Venue.new

    venue.define_hours do
      mon "09:00".."17:00"
      tue "10:00".."14:00"
    end

    assert_instance_of Schedule, venue.opening_hours
    assert_equal [TimeWindow["09:00-17:00"]], venue.opening_hours.mon
    assert_equal [TimeWindow["10:00-14:00"]], venue.opening_hours.tue
    assert venue.open?(at: Time.new(2024, 1, 1, 11, 0, 0))
    refute venue.open?(at: Time.new(2024, 1, 1, 18, 0, 0))
  end

  def test_define_hours_without_block_sets_blank_schedule
    venue = Venue.new
    venue.opening_hours = { "mon" => ["09:00-17:00"] }

    schedule = venue.define_hours

    assert_equal Schedule.new, schedule
    assert_equal Schedule.new, venue.opening_hours
  end

  def test_custom_opening_hours_column_reads_and_writes
    venue = VenueWithCustomColumn.new

    venue.define_hours do
      mon "09:00".."17:00"
    end

    assert_instance_of Schedule, venue.hours_json
    assert_equal [TimeWindow["09:00-17:00"]], venue.hours_json.mon
    assert venue.open?(at: Time.new(2024, 1, 1, 10, 0, 0))
  end

  def test_custom_opening_hours_column_from_existing_data
    venue = VenueWithCustomColumn.new
    venue.hours_json = { "tue" => ["10:00-12:00"] }

    assert venue.open?(at: Time.new(2024, 1, 2, 11, 0, 0))
  end

  def test_model_does_not_expose_schedule_method
    refute_respond_to Venue.new, :schedule
  end

  def test_registers_type_for_default_column
    venue = Venue.new
    assert_instance_of Schedule, venue.opening_hours
  end

  def test_registers_type_for_custom_column
    venue = VenueWithCustomColumn.new
    assert_instance_of Schedule, venue.hours_json
  end

  def test_opening_hours_column_reader
    assert_equal :opening_hours, Venue.opening_hours_column
    assert_equal :hours_json, VenueWithCustomColumn.opening_hours_column
  end
end
