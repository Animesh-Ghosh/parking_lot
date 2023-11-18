# parking_lot

A solution to the problem statement shared in `problem-statement-level-1.md`.

The core business logic lives in `lib/parking_lot.rb` and instance methods map one-to-one to the commands shown in the example inputs. It requires atleast 1 or more parking slots.

Interfaces to process input from file and stdin live in `lib/parking_lot/interfaces` and are as follow:

1. `lib/parking_lot/interfaces/file_interface`
2. `lib/parking_lot/interfaces/command_line_interface`

Both interfaces raise an error for invalid commands; this behaviour could be changed if needed but this implementation was simplest.

## Setup

Install dependencies and run the specs:

```bash
bin/setup
```

## Execution

Use the executable script:

```bash
bin/parking_lot [filename]
```
