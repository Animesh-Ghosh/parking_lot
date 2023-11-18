require_relative '../../spec_helper'
require_relative '../../../lib/parking_lot/interfaces/command_line_interface'

RSpec.describe ParkingLot::Interfaces::CommandLineInterface do
  let(:commands) do
    <<~COMMANDS
      create_parking_lot 6
      park KA-01-HH-1234 White
      park KA-01-HH-9999 White
      park KA-01-BB-0001 Black
      park KA-01-HH-7777 Red
      park KA-01-HH-2701 Blue
      park KA-01-HH-3141 Black
      leave 4
      status
      park KA-01-P-333 White
      park DL-12-AA-9999 White
      registration_numbers_for_cars_with_colour White
      slot_numbers_for_cars_with_colour White
      slot_number_for_registration_number KA-01-HH-3141
      slot_number_for_registration_number MH-04-AY-1111
      exit
    COMMANDS
  end
  let(:commands_list) { commands.split("\n") }
  let(:parking_lot) do
    parking_lot = instance_double(ParkingLot)
    allow(ParkingLot).to receive(:new).and_return(parking_lot)
    parking_lot
  end
  let(:command_line_interface) do
    described_class.new
  end

  # stub stdout temporarily to reduce noise in spec runs
  before do
    @stdout = $stdout
    $stdout = File.open(File::NULL, 'w')
    allow(command_line_interface).to receive(:gets).and_return(*commands_list)
  end

  after do
    $stdout = @stdout
  end

  describe '#process' do
    context 'when an invalid command exists' do
      let(:commands) do
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
          exit
        COMMANDS
      end

      it 'raises an error' do
        expect { command_line_interface.process }.to raise_error(NoMethodError)
      end
    end

    context 'when no invalid commands exist' do
      let(:expected_output) do
        <<~OUTPUT
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
      end

      it 'does not raise an error' do
        expect { command_line_interface.process }.not_to raise_error
      end

      it 'dispatches correct methods to ParkingLot' do
        parking_lot = instance_double(ParkingLot)
        allow(ParkingLot).to receive(:new).and_return(parking_lot)
        command_line_interface = described_class.new
        allow(command_line_interface).to receive(:gets).and_return(*commands_list)
        allow(parking_lot).to receive(:create_parking_lot)
        allow(parking_lot).to receive(:park)
        allow(parking_lot).to receive(:leave)
        allow(parking_lot).to receive(:status).and_return([
                                                            %w[1 KA-01-HH-1234],
                                                            %w[2 KA-01-HH-9999],
                                                            %w[3 KA-01-BB-0001],
                                                            %w[5 KA-01-HH-2701],
                                                            %w[6 KA-01-HH-3141]
                                                          ])
        allow(parking_lot).to receive(:registration_numbers_for_cars_with_colour).and_return([
                                                                                               'KA-01-HH-1234',
                                                                                               'KA-01-HH-9999',
                                                                                               'KA-01-P-333'
                                                                                             ])
        allow(parking_lot).to receive(:slot_numbers_for_cars_with_colour).and_return([
                                                                                       1,
                                                                                       2,
                                                                                       4
                                                                                     ])
        allow(parking_lot).to receive(:slot_number_for_registration_number)
        expect(parking_lot).to receive(:create_parking_lot).with(6)
        expect(parking_lot).to receive(:park).with('KA-01-HH-1234', 'White')
        expect(parking_lot).to receive(:leave).with(4)
        expect(parking_lot).to receive(:status)
        expect(parking_lot).to receive(:registration_numbers_for_cars_with_colour).with('White')
        expect(parking_lot).to receive(:slot_number_for_registration_number).with('KA-01-HH-3141')
        command_line_interface.process
      end

      it 'prints out the correct output' do
        expect { command_line_interface.process }.to output(expected_output).to_stdout
      end

      context 'when cars of a specified colour are not parked' do
        let(:commands) do
          <<~COMMANDS
            create_parking_lot 6
            park KA-01-HH-1234 White
            park KA-01-HH-9999 White
            park KA-01-BB-0001 Black
            park KA-01-HH-7777 Red
            park KA-01-HH-2701 Blue
            park KA-01-HH-3141 Black
            leave 4
            status
            park KA-01-P-333 White
            park DL-12-AA-9999 White
            registration_numbers_for_cars_with_colour Red
            slot_numbers_for_cars_with_colour Red
            slot_number_for_registration_number KA-01-HH-3141
            slot_number_for_registration_number MH-04-AY-1111
            exit
          COMMANDS
        end
        let(:expected_output) do
          <<~OUTPUT
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
            Not found
            Not found
            6
            Not found
          OUTPUT
        end

        it 'prints out Not found for registration numbers and slot numbers' do
          expect { command_line_interface.process }.to output(expected_output).to_stdout
        end
      end
    end
  end
end
