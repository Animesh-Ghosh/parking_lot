require_relative './spec_helper'
require_relative '../lib/parking_lot'

RSpec.describe ParkingLot do
  let(:parking_lot) { described_class.new }
  let(:number_of_slots) { 6 }
  let(:parking_lot_with_slots) do
    parking_lot.create_parking_lot(number_of_slots)
    parking_lot
  end

  describe '#create_parking_lot' do
    context 'when called with a valid number' do
      before do
        parking_lot.create_parking_lot(number_of_slots)
      end

      it 'creates a parking lot with n slots' do
        expect(parking_lot.slots).to eq number_of_slots
      end
    end

    context 'when called with anything but a valid number' do
      it 'raises an ArgumentError' do
        expect { parking_lot.create_parking_lot(0) }.to raise_error(ArgumentError)
        expect { parking_lot.create_parking_lot(-1) }.to raise_error(ArgumentError)
        expect { parking_lot.create_parking_lot(nil) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#park' do
    context 'when slots are empty' do
      it 'allocates a slot' do
        expect do
          parking_lot_with_slots.park('KA-01-HH-1234', 'White')
        end.to change(parking_lot_with_slots, :slots).from(number_of_slots)
                                                     .to(number_of_slots - 1)
      end
    end

    context 'when slots are full' do
      before do
        parking_lot_with_slots.park('KA-01-HH-1234', 'White')
        parking_lot_with_slots.park('KA-01-HH-9999', 'White')
        parking_lot_with_slots.park('KA-01-BB-0001', 'Black')
        parking_lot_with_slots.park('KA-01-HH-7777', 'Red')
        parking_lot_with_slots.park('KA-01-HH-2701', 'Blue')
        parking_lot_with_slots.park('KA-01-HH-3141', 'Black')
      end

      it 'does not allocate a slot' do
        expect do
          parking_lot_with_slots.park('DL-12-AA-9999', 'White')
        end.not_to(change(parking_lot_with_slots, :slots))
      end
    end
  end

  describe '#leave' do
    before do
      parking_lot_with_slots.park('KA-01-HH-1234', 'White')
      parking_lot_with_slots.park('KA-01-HH-9999', 'White')
      parking_lot_with_slots.park('KA-01-BB-0001', 'Black')
      parking_lot_with_slots.park('KA-01-HH-7777', 'Red')
      parking_lot_with_slots.park('KA-01-HH-2701', 'Blue')
      parking_lot_with_slots.park('KA-01-HH-3141', 'Black')
    end

    it 'raises for invalid slot numbers' do
      expect do
        parking_lot_with_slots.leave(10)
      end.to raise_error(ArgumentError)
    end

    context 'when there are used slots' do
      it 'frees up a slot' do
        expect do
          parking_lot_with_slots.leave(4)
        end.to change(parking_lot_with_slots, :slots).from(0).to(1)
      end
    end

    context 'when slots are empty' do
      before do
        1.upto(number_of_slots) do |slot_number|
          parking_lot_with_slots.leave(slot_number)
        end
      end

      it 'does not free any slots' do
        expect do
          parking_lot_with_slots.leave(4)
        end.not_to(change(parking_lot_with_slots, :slots))
      end
    end
  end

  describe '#status' do
    before do
      parking_lot_with_slots.park('KA-01-HH-1234', 'White')
      parking_lot_with_slots.park('KA-01-HH-9999', 'White')
      parking_lot_with_slots.park('KA-01-BB-0001', 'Black')
      parking_lot_with_slots.park('KA-01-HH-7777', 'Red')
      parking_lot_with_slots.park('KA-01-HH-2701', 'Blue')
      parking_lot_with_slots.park('KA-01-HH-3141', 'Black')
      parking_lot_with_slots.leave(4)
    end

    it 'returns current state of slots' do
      expect(parking_lot_with_slots.status).to eq [
        [1, 'KA-01-HH-1234'],
        [2, 'KA-01-HH-9999'],
        [3, 'KA-01-BB-0001'],
        [5, 'KA-01-HH-2701'],
        [6, 'KA-01-HH-3141']
      ]
    end
  end

  describe '#registration_numbers_for_cars_with_colour' do
    before do
      parking_lot_with_slots.park('KA-01-HH-1234', 'White')
      parking_lot_with_slots.park('KA-01-HH-9999', 'White')
      parking_lot_with_slots.park('KA-01-BB-0001', 'Black')
      parking_lot_with_slots.park('KA-01-HH-7777', 'Red')
      parking_lot_with_slots.park('KA-01-HH-2701', 'Blue')
      parking_lot_with_slots.park('KA-01-HH-3141', 'Black')
      parking_lot_with_slots.leave(4)
      parking_lot_with_slots.park('KA-01-P-333', 'White')
    end

    context 'when cars with specified colour are parked' do
      let(:colour) { 'White' }

      it 'returns the registration numbers' do
        expect(parking_lot_with_slots.registration_numbers_for_cars_with_colour(colour)).to eq [
          'KA-01-HH-1234', 'KA-01-HH-9999', 'KA-01-P-333'
        ]
      end
    end

    context 'when no car with specified colour are parked' do
      let(:colour) { 'Red' }

      it 'returns an empty list' do
        expect(parking_lot_with_slots.registration_numbers_for_cars_with_colour(colour)).to eq []
      end
    end
  end

  describe '#slot_numbers_for_cars_with_colour' do
    before do
      parking_lot_with_slots.park('KA-01-HH-1234', 'White')
      parking_lot_with_slots.park('KA-01-HH-9999', 'White')
      parking_lot_with_slots.park('KA-01-BB-0001', 'Black')
      parking_lot_with_slots.park('KA-01-HH-7777', 'Red')
      parking_lot_with_slots.park('KA-01-HH-2701', 'Blue')
      parking_lot_with_slots.park('KA-01-HH-3141', 'Black')
      parking_lot_with_slots.leave(4)
      parking_lot_with_slots.park('DL-12-AA-9999', 'White')
    end

    context 'when cars with specified colour are parked' do
      let(:colour) { 'White' }

      it 'returns the slot numbers' do
        expect(parking_lot_with_slots.slot_numbers_for_cars_with_colour(colour)).to eq [1, 2, 4]
      end
    end

    context 'when no car with specified colour are parked' do
      let(:colour) { 'Red' }

      it 'returns an empty list' do
        expect(parking_lot_with_slots.slot_numbers_for_cars_with_colour(colour)).to eq []
      end
    end
  end

  describe '#slot_number_for_registration_number' do
    before do
      parking_lot_with_slots.park('KA-01-HH-1234', 'White')
      parking_lot_with_slots.park('KA-01-HH-9999', 'White')
      parking_lot_with_slots.park('KA-01-BB-0001', 'Black')
      parking_lot_with_slots.park('KA-01-HH-7777', 'Red')
      parking_lot_with_slots.park('KA-01-HH-2701', 'Blue')
      parking_lot_with_slots.park('KA-01-HH-3141', 'Black')
      parking_lot_with_slots.leave(4)
      parking_lot_with_slots.park('DL-12-AA-9999', 'White')
    end

    context 'when a car with specified registration number is parked' do
      let(:registration_number) { 'KA-01-HH-3141' }

      it 'returns the slot number' do
        expect(parking_lot_with_slots.slot_number_for_registration_number(registration_number)).to eq 6
      end
    end

    context 'when a car with specified registration number is not parked' do
      let(:registration_number) { 'MH-04-AY-1111' }

      it 'returns nil' do
        expect(parking_lot_with_slots.slot_number_for_registration_number(registration_number)).to be_nil
      end
    end
  end
end
