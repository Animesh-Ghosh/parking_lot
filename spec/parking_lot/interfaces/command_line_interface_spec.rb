require_relative '../../spec_helper'
require_relative '../../../lib/parking_lot/interfaces/command_line_interface'

RSpec::Matchers.define_negated_matcher :not_raise_error, :raise_error

RSpec.describe ParkingLot::Interfaces::CommandLineInterface do
  describe '#process' do
    let(:parking_lot) { instance_double(ParkingLot) }
    let(:command_line_interface) { described_class.new }

    before do
      allow(ParkingLot).to receive(:new).and_return(parking_lot)
      # stub gets in CommandLineInterface to return commands as we want
      allow(command_line_interface).to receive(:gets).and_return(*commands.split("\n"))
    end

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
        OUTPUT
      end

      before do
        allow(parking_lot).to receive(:create_parking_lot)
        allow(parking_lot).to receive(:park).and_return(1, 2, 3, 4, 5, 6)
      end

      it 'outputs till the invalid command and then raises' do
        expect { command_line_interface.process }.to output(expected_output).to_stdout
                                                                            .and raise_error(NoMethodError)
      end
    end

    context 'when no invalid commands exist' do
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
          registration_numbers_for_cars_with_colour White
          slot_numbers_for_cars_with_colour White
          slot_number_for_registration_number KA-01-HH-3141
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
          KA-01-HH-1234, KA-01-HH-9999
          1, 2
          6
        OUTPUT
      end

      before do
        allow(parking_lot).to receive(:create_parking_lot)
        allow(parking_lot).to receive(:park).and_return(1, 2, 3, 4, 5, 6)
        allow(parking_lot).to receive(:leave)
        allow(parking_lot).to receive(:status).and_return(
          [
            %w[1 KA-01-HH-1234],
            %w[2 KA-01-HH-9999],
            %w[3 KA-01-BB-0001],
            %w[5 KA-01-HH-2701],
            %w[6 KA-01-HH-3141]
          ]
        )
        allow(parking_lot).to receive(:registration_numbers_for_cars_with_colour).and_return(
          %w[
            KA-01-HH-1234
            KA-01-HH-9999
          ]
        )
        allow(parking_lot).to receive(:slot_numbers_for_cars_with_colour).and_return(
          [
            1,
            2
          ]
        )
        allow(parking_lot).to receive(:slot_number_for_registration_number).and_return(6)
      end

      it 'prints output and does not raise' do
        expect { command_line_interface.process }.to output(expected_output).to_stdout
                                                                            .and not_raise_error
      end

      it 'dispatches correct methods to ParkingLot' do
        expect(parking_lot).to receive(:create_parking_lot).with(6).once
        expect(parking_lot).to receive(:park).exactly(6).times
        expect(parking_lot).to receive(:leave).with(4).once
        expect(parking_lot).to receive(:status).once
        expect(parking_lot).to receive(:registration_numbers_for_cars_with_colour).with('White').once
        expect(parking_lot).to receive(:slot_numbers_for_cars_with_colour).with('White').once
        expect(parking_lot).to receive(:slot_number_for_registration_number).with('KA-01-HH-3141').once
        expect { command_line_interface.process }.to output(expected_output).to_stdout
      end
    end

    context 'when parking lot becomes full' do
      let(:commands) do
        <<~COMMANDS
          create_parking_lot 6
          park KA-01-HH-1234 White
          park KA-01-HH-9999 White
          park KA-01-BB-0001 Black
          park KA-01-HH-7777 Red
          park KA-01-HH-2701 Blue
          park KA-01-HH-3141 Black
          park KA-01-P-333 White
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
          Sorry, parking lot is full
        OUTPUT
      end

      before do
        allow(parking_lot).to receive(:create_parking_lot)
        allow(parking_lot).to receive(:park).and_return(1, 2, 3, 4, 5, 6, nil)
      end

      it 'outputs "Sorry, parking lot is full"' do
        expect { command_line_interface.process }.to output(expected_output).to_stdout
      end
    end

    context 'when no car with a specified colour is parked' do
      context 'when registration_numbers_for_cars_with_colour command is sent' do
        let(:commands) do
          <<~COMMANDS
            create_parking_lot 6
            park KA-01-HH-1234 White
            registration_numbers_for_cars_with_colour Red
            exit
          COMMANDS
        end
        let(:expected_output) do
          <<~OUTPUT
            Created a parking lot with 6 slots
            Allocated slot number: 1
            Not found
          OUTPUT
        end

        before do
          allow(parking_lot).to receive(:create_parking_lot)
          allow(parking_lot).to receive(:park).and_return(1)
          allow(parking_lot).to receive(:registration_numbers_for_cars_with_colour).with('Red').and_return([])
        end

        it 'outputs "Not found"' do
          expect { command_line_interface.process }.to output(expected_output).to_stdout
        end
      end

      context 'when slot_numbers_for_cars_with_colour command is sent' do
        let(:commands) do
          <<~COMMANDS
            create_parking_lot 6
            park KA-01-HH-1234 White
            slot_numbers_for_cars_with_colour Red
            exit
          COMMANDS
        end
        let(:expected_output) do
          <<~OUTPUT
            Created a parking lot with 6 slots
            Allocated slot number: 1
            Not found
          OUTPUT
        end

        before do
          allow(parking_lot).to receive(:create_parking_lot)
          allow(parking_lot).to receive(:park).and_return(1)
          allow(parking_lot).to receive(:slot_numbers_for_cars_with_colour).with('Red').and_return([])
        end

        it 'outputs "Not found"' do
          expect { command_line_interface.process }.to output(expected_output).to_stdout
        end
      end
    end

    context 'when no car with specified registration number is parked' do
      let(:commands) do
        <<~COMMANDS
          create_parking_lot 6
          park KA-01-HH-1234 White
          slot_number_for_registration_number KA-01-HH-9999
          exit
        COMMANDS
      end
      let(:expected_output) do
        <<~OUTPUT
          Created a parking lot with 6 slots
          Allocated slot number: 1
          Not found
        OUTPUT
      end

      before do
        allow(parking_lot).to receive(:create_parking_lot)
        allow(parking_lot).to receive(:park).and_return(1)
        allow(parking_lot).to receive(:slot_number_for_registration_number).with('KA-01-HH-9999').and_return(nil)
      end

      it 'outputs "Not found"' do
        expect { command_line_interface.process }.to output(expected_output).to_stdout
      end
    end
  end
end
