require_relative '../../parking_lot'

class ParkingLot
  module Interfaces
    class CLI # :nodoc:
      def initialize
        @parking_lot = ParkingLot.new
        @last_command = nil
      end

      def process
        while @last_command != 'exit'
          command = gets.chomp
          parse_and_dispatch_to_parking_lot_for(command)
          @last_command = command
        end
      end

      private

      def parse_and_dispatch_to_parking_lot_for(command)
        case command.split
        in ['create_parking_lot', lot_size]
          create_parking_lot(lot_size)
        in ['park', registration_number, colour]
          park(registration_number, colour)
        in ['leave', slot_number]
          leave(slot_number)
        in ['status']
          status
        in [
          'registration_numbers_for_cars_with_colour' | 'slot_numbers_for_cars_with_colour' => command,
          colour
        ]
          send(command, colour)
        in ['slot_number_for_registration_number', registration_number]
          slot_number_for_registration_number(registration_number)
        in ['exit']
          # noop
        else
          raise NoMethodError
        end
      end

      def create_parking_lot(lot_size)
        @parking_lot.create_parking_lot lot_size.to_i
        puts "Created a parking lot with #{lot_size} slots"
      end

      def park(registration_number, colour)
        slot_number = @parking_lot.park registration_number, colour
        if slot_number.nil?
          puts 'Sorry, parking lot is full'
        else
          puts "Allocated slot number: #{slot_number}"
        end
      end

      def leave(slot_number)
        @parking_lot.leave slot_number.to_i
        puts "Slot number #{slot_number} is free"
      end

      def status
        status = @parking_lot.status
        puts 'Slot No. Registration No'
        status.each do |slot_number, registration_number|
          puts "#{slot_number} #{registration_number}"
        end
      end

      def registration_numbers_for_cars_with_colour(colour)
        registration_numbers = @parking_lot.registration_numbers_for_cars_with_colour colour
        if registration_numbers.empty?
          puts 'Not found'
        else
          puts registration_numbers.join(', ')
        end
      end

      def slot_numbers_for_cars_with_colour(colour)
        slot_numbers = @parking_lot.slot_numbers_for_cars_with_colour colour
        if slot_numbers.empty?
          puts 'Not found'
        else
          puts slot_numbers.join(', ')
        end
      end

      def slot_number_for_registration_number(registration_number)
        slot_number = @parking_lot.slot_number_for_registration_number registration_number
        if slot_number.nil?
          puts 'Not found'
        else
          puts slot_number
        end
      end
    end
  end
end
