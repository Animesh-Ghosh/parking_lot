require_relative '../../../lib/parking_lot/interfaces/file_interface'

RSpec.describe ParkingLot::Interfaces::FileInterface do
  let(:filename) { '../../file_inputs.txt' }
  let(:file_interface) { ParkingLot::Interfaces::FileInterface.new filename }

  context "'if file doesn't exist" do
    it 'raises an error' do
      expect { ParkingLot::Interfaces::FileInterface.new 'non-existant-file.txt' }.to raise_error(Errno::ENOENT)
    end
  end

  context 'if file exists' do
    describe '#process' do
      context 'sees an invalid command' do
        let(:invalid_command_filename) { 'invalid_command.txt' }
        let(:invalid_commands) do
          <<~COMMANDS
            create_parking_lot 6
            park KA-01-HH-1234 White
            park KA-01-HH-9999 White
            park KA-01-BB-0001 Black
            park KA-01-HH-7777 Red
            park KA-01-HH-2701 Blue
            park KA-01-HH-3141 Black
            remove 4
            status
            park KA-01-P-333 White
            park DL-12-AA-9999 White
            registration_numbers_for_cars_with_colour White
            slot_numbers_for_cars_with_colour White
            slot_number_for_registration_number KA-01-HH-3141
            slot_number_for_registration_number MH-04-AY-1111
          COMMANDS
        end
        let(:invalid_commands_file_interface) do
          ParkingLot::Interfaces::FileInterface.new invalid_command_filename
        end

        before do
          File.write(invalid_command_filename, invalid_commands)
        end

        it 'raises an error' do
          expect { invalid_commands_file_interface.process }.to raise_error(StandardError)
        end

        after do
          File.unlink(invalid_command_filename)
        end
      end

      context "doesn't see any invalid commands" do
        it 'does not raise an error' do
          expect { invalid_commands_file_interface.process }.not_to raise_error
        end

        it 'dispatches correct methods to ParkingLot' do
          parking_lot = object_double(:ParkingLot)
          file_interface.process
          expect(parking_lot).to have_received(:create_parking_lot).with(6)
          expect(parking_lot).to have_received(:park).with('KA-01-HH-1234', 'White')
          expect(parking_lot).to have_received(:park).with('KA-01-HH-9999', 'White')
          expect(parking_lot).to have_received(:park).with('KA-01-BB-0001', 'Black')
          expect(parking_lot).to have_received(:park).with('KA-01-HH-7777', 'Red')
          expect(parking_lot).to have_received(:park).with('KA-01-HH-2701', 'Blue')
          expect(parking_lot).to have_received(:park).with('KA-01-HH-3141', 'Black')
          expect(parking_lot).to have_received(:leave).with(4)
          expect(parking_lot).to have_received(:status)
          expect(parking_lot).to have_received(:park).with('KA-01-P-333', 'White')
          expect(parking_lot).to have_received(:park).with('DL-12-AA-9999', 'White')
          expect(parking_lot).to have_received(:registration_numbers_for_cars_with_colour).with('White')
          expect(parking_lot).to have_received(:slot_numbers_for_cars_with_colour).with('White')
          expect(parking_lot).to have_received(:slot_number_for_registration_number).with('KA-01-HH-3141')
          expect(parking_lot).to have_received(:slot_number_for_registration_number).with('MH-04-AY-1111')
        end

        it 'prints out the correct output' do
          expected_output = <<~OUTPUT
            Created a parking lot with 6 slots
            Allocated slot number: 1
            Allocated slot number: 2
            Allocated slot number: 3
            Allocated slot number: 4
            Allocated slot number: 5
            Allocated slot number: 6
            Slot number 4 is free
            Slot No. Registration No
            1 KA-01-HH-1234
            2 KA-01-HH-9999
            3 KA-01-BB-0001
            5 KA-01-HH-2701
            6 KA-01-HH-3141
            Allocated slot number: 4
            Sorry, parking lot is full
            KA-01-HH-1234, KA-01-HH-9999, KA-01-P-333
            1, 2, 4
            6
            Not found
          OUTPUT
          expect { file_interface.process }.to output(expected_output).to_stdout
        end
      end
    end
  end
end
