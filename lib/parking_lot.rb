class ParkingLot # :nodoc:
  class Car # :nodoc:
    attr_reader :registration_number, :colour

    def initialize(registration_number, colour)
      @registration_number = registration_number
      @colour = colour
    end
  end

  def initialize
    @slots = nil
  end

  def create_parking_lot(lot_size)
    lot_size = Integer(lot_size, exception: false)
    raise ArgumentError if lot_size.nil? || lot_size < 1

    @slots = Array.new(lot_size)
  end

  def slots
    available_slots.size
  end

  def park(registration_number, colour)
    slot_index = @slots.find_index(&:nil?)
    return nil if slot_index.nil?

    @slots[slot_index] = Car.new(registration_number, colour)
    slot_index + 1
  end

  def leave(slot_number)
    raise ArgumentError unless (0..@slots.size).include?(slot_number - 1)

    @slots[slot_number - 1] = nil
  end

  def status
    slots_with_index
      .reject { |_idx, slot| slot.nil? }
      .map { |idx, slot| [idx, slot&.registration_number] }
  end

  def registration_numbers_for_cars_with_colour(colour)
    filled_slots.filter { |slot| slot.colour == colour }
                .map(&:registration_number)
  end

  def slot_numbers_for_cars_with_colour(colour)
    slots_with_index
      .filter { |_idx, slot| slot&.colour == colour }
      .map { |idx, _slot| idx }
  end

  def slot_number_for_registration_number(registration_number)
    idx = @slots.find_index { |slot| slot&.registration_number == registration_number }
    return nil if idx.nil?

    idx + 1
  end

  private

  def available_slots
    @slots.filter(&:nil?)
  end

  def filled_slots
    @slots.reject(&:nil?)
  end

  def slots_with_index
    @slots.map.with_index { |slot, idx| [idx + 1, slot] }
  end
end
