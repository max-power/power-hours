# frozen_string_literal: true

require_relative "test_helper"

class ModelTest < Minitest::Test
  class Venue
    include OpeningHours::Model

    attr_accessor :opening_hours, :timezone
  end

  class VenueWithCustomColumn
    include OpeningHours::Model
    opening_hours_column :hours_json

    attr_accessor :hours_json, :timezone
  end

  class RailsLikeVenue
    class << self
      attr_reader :registered_attributes

      def attribute(name, type)
        @registered_attributes ||= {}
        @registered_attributes[name] = type
      end
    end

    include OpeningHours::Model
    opening_hours_column :business_hours

    attr_accessor :business_hours, :timezone
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

    assert_equal ["09:00-17:00"], venue.opening_hours[:mon]
    assert_equal ["10:00-14:00"], venue.opening_hours[:tue]
    assert venue.open?(at: Time.new(2024, 1, 1, 11, 0, 0))
    refute venue.open?(at: Time.new(2024, 1, 1, 18, 0, 0))
  end

  def test_define_hours_requires_a_block
    venue = Venue.new

    assert_raises(ArgumentError) { venue.define_hours }
  end

  def test_custom_opening_hours_column_reads_and_writes
    venue = VenueWithCustomColumn.new

    venue.define_hours do
      mon "09:00".."17:00"
    end

    assert_equal ["09:00-17:00"], venue.hours_json[:mon]
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

  def test_registers_opening_hours_type_for_rails_like_classes
    assert_instance_of OpeningHours::Type, RailsLikeVenue.registered_attributes[:opening_hours]
    assert_instance_of OpeningHours::Type, RailsLikeVenue.registered_attributes[:business_hours]
  end
end
