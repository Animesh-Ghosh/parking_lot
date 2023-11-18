require_relative '../../parking_lot'

class ParkingLot
  module Interfaces
    class CommandLineInterface # :nodoc:
      def initialize
        @parking_lot = ParkingLot.new
        @last_command = nil
      end

      def process
        while @last_command != 'exit'
          command = gets.chomp
          dispatch_parking_lot_command(command)
          @last_command = command
        end
      end

      private

      def dispatch_parking_lot_command(command)
        case command.split
        in ['create_parking_lot', lot_size]
          @parking_lot.create_parking_lot lot_size.to_i
          puts "Created a parking lot with #{lot_size} slots"
        in ['park', registration_number, colour]
          slot_number = @parking_lot.park registration_number, colour
          if slot_number.nil?
            puts 'Sorry, parking lot is full'
          else
            puts "Allocated slot number: #{slot_number}"
          end
        in ['leave', slot_number]
          @parking_lot.leave slot_number.to_i
          puts "Slot number #{slot_number} is free"
        in ['status']
          status = @parking_lot.status
          puts 'Slot No. Registration No'
          status.each do |slot_number, registration_number|
            puts "#{slot_number} #{registration_number}"
          end
        in ['registration_numbers_for_cars_with_colour', colour]
          registration_numbers = @parking_lot.registration_numbers_for_cars_with_colour colour
          if registration_numbers.empty?
            puts 'Not found'
          else
            puts registration_numbers.join(', ')
          end
        in ['slot_numbers_for_cars_with_colour', colour]
          slot_numbers = @parking_lot.slot_numbers_for_cars_with_colour colour
          if slot_numbers.empty?
            puts 'Not found'
          else
            puts slot_numbers.join(', ')
          end
        in ['slot_number_for_registration_number', registration_number]
          slot_number = @parking_lot.slot_number_for_registration_number registration_number
          if slot_number.nil?
            puts 'Not found'
          else
            puts slot_number
          end
        in ['exit']
          # noop
        else
          raise NoMethodError
        end
      end
    end
  end
end
