# Stats

A command-line tool written in Rust for analyzing programming language statistics in a directory.

## Features

- Analyzes directories to count files and lines of code by programming language
- Filters out common directories like `.git`, `node_modules`, etc.
- Displays results in a colorful, formatted table
- Supports any configured programming languages

## Default Languages

- Rust (.rs)
- Go (.go)
- JavaScript (.js)
- TypeScript (.ts)
- Lua (.lua)
- Haskell (.hs)

## Installation

### From Source

1. Clone the repository
2. Install the project:

```bash
cargo install --path .
```

## Usage

```bash
# Analyze the current directory
stats

# Analyze a specific directory
stats /path/to/directory
```

## Example Output

```
Language Statistics
┏━━━━━━━━━━━━┳━━━━━━━┳━━━━━━━┳━━━━━━━━┳━━━━━━━━┓
┃ Language   ┃ Files ┃ Lines ┃ File % ┃ Line % ┃
┡━━━━━━━━━━━━╇━━━━━━━╇━━━━━━━╇━━━━━━━━╇━━━━━━━━┩
│ Rust       │    10 │  1250 │  62.5% │  75.8% │
│ JavaScript │     4 │   250 │  25.0% │  15.2% │
│ Python     │     2 │   150 │  12.5% │   9.1% │
└────────────┴───────┴───────┴────────┴────────┘
```

## License

GNU General Public License v3.0
