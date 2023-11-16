# Nature of the Game

We aim to understand your development approach and the level of expertise you bring to building software. While a real-world problem at scale would be ideal, it's not practical due to time constraints. Instead, we present a simpler problem statement for you to solve as if it were a real-world scenario. Failure to follow the instructions will result in automated rejection, and exceeding the time limit will impact our evaluation.

## Rules of the Game

1. **Time Limit:**
    - You have two full days to implement a solution.

2. **Coding Style:**
    - Emphasize object-oriented or functional design skills; create elegant, high-quality code.
    - Demonstrate your decision-making process when faced with undefined workflow or boundary conditions.

3. **Language and Environment:**
    - Solve the problem in an object-oriented or functional language without external libraries (except for testing).
    - Ensure your solution builds and runs on Linux; use Docker if necessary.
    - Utilize Git for version control; submit a zip or tarball with Git metadata for review.
    - Avoid checking in binaries, class files, jars, libraries, or build output.

4. **Testing:**
    - Write comprehensive unit tests/specs; consider test-driven development for object-oriented solutions.

5. **Project Structure:**
    - Organize your solution inside the `parking_lot` directory.
    - Adopt the structure, organization, and conventions of mature open-source projects.
    - Include a README.md with clear instructions.

6. **Executable Scripts:**
    - Update Unix executable scripts `bin/setup` and `bin/parking_lot` in the bin directory for automated testing.
    - `bin/setup`: Install dependencies, compile code, and run unit tests.
    - `bin/parking_lot`: Run the program, accepting input from a file and printing output to STDOUT.

7. **Input and Output Formatting:**
    - Adhere to syntax and formatting guidelines for both input and output.
    - Use the provided automated functional test suite (`bin/run_functional_tests`) for validation.
    - Refer to `functional_spec/README.md` for setup instructions for functional tests.

8. **Confidentiality:**
    - Do not make your solution or this problem statement publicly available on platforms like GitHub, Bitbucket, blogs, or forums.

## Problem Statement

You own a parking lot that can hold up to 'n' cars at any given time. Each slot is numbered starting from 1, increasing with distance from the entry point. Create an automated ticketing system allowing customers to use the parking lot without human intervention.

- When a car enters, issue a ticket with the car's registration number and color; allocate the nearest available slot.
- Upon exit, mark the slot as available.
- Provide the ability to find:
    - Registration numbers of cars of a particular color.
    - Slot number for a given registration number.
    - Slot numbers for all cars of a specific color.

Interact with the system via commands in two ways:
1. Interactive command prompt-based shell.
2. Accept commands from a file.

### Example: File

To install dependencies, compile, and run tests:
```
$ bin/setup
```
To run the code with input from a file:
```
$ bin/parking_lot file_inputs.txt
```
**Input (file content):**
```
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
```
**Output (STDOUT):**
```
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
```

### Example: Interactive

To install dependencies, compile, and run tests:
```
$ bin/setup
```

To run the program and launch the shell:
```
$ bin/parking_lot
```

Assuming a parking lot with 6 slots, run the following commands in sequence, producing output as described below each command. Note: `exit` terminates the process and returns control to the shell.
```
$ create_parking_lot 6
Created a parking lot with 6 slots

$ park KA-01-HH-1234 White
Allocated slot number: 1

$ park KA-01-HH-9999 White
Allocated slot number: 2

$ park KA-01-BB-0001 Black
Allocated slot number: 3

$ park KA-01-HH-7777 Red
Allocated slot number: 4

$ park KA-01-HH-2701 Blue
Allocated slot number: 5

$ park KA-01-HH-3141 Black
Allocated slot number: 6

$ leave 4
Slot number 4 is free

$ status
Slot No. Registration No
1 KA-01-HH-1234
2 KA-01-HH-9999
3 KA-01-BB-0001
5 KA-01-HH-2701
6 KA-01-HH-3141

$ park KA-01-P-333 White
Allocated slot number: 4

$ park DL-12-AA-9999 White
Sorry, parking lot is full

Colour
White
White
Black
Blue
Black

$ registration_numbers_for_cars_with_colour White
KA-01-HH-1234, KA-01-HH-9999, KA-01-P-333

$ slot_numbers_for_cars_with_colour White
1, 2, 4

$ slot_number_for_registration_number KA-01-HH-3141
6

$ slot_number_for_registration_number MH-04-AY-1111
Not found

$ exit
```
