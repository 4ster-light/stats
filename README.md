# stats

An small tool I made to know how much I code in each language I use

## Usage

The directory must be given as only argument or else it'll default to the current directory

- Activate the virtual environment and install the dependencies first if using pip

```bash
source venv/bin/activate
pip install -r requirements.txt
```

- Run the script

```bash
# Directly with the python interpreter
python stats.py <directory>
# Using uv
uv run stats.py <directory>
```

## Output

```bash
              Language Statistics               
┏━━━━━━━━━━━━┳━━━━━━━┳━━━━━━━┳━━━━━━━━┳━━━━━━━━┓
┃ Language   ┃ Files ┃ Lines ┃ File % ┃ Line % ┃
┡━━━━━━━━━━━━╇━━━━━━━╇━━━━━━━╇━━━━━━━━╇━━━━━━━━┩
│ Go         │    15 │   998 │  20.3% │  32.0% │
│ Haskell    │     5 │   160 │   6.8% │   5.1% │
│ JavaScript │     3 │    75 │   4.1% │   2.4% │
│ Lua        │    30 │   665 │  40.5% │  21.3% │
│ Nix        │     2 │    81 │   2.7% │   2.6% │
│ OCaml      │     0 │     0 │   0.0% │   0.0% │
│ Python     │     2 │   247 │   2.7% │   7.9% │
│ Rust       │     9 │   552 │  12.2% │  17.7% │
│ Templ      │     6 │   182 │   8.1% │   5.8% │
│ TypeScript │     2 │   158 │   2.7% │   5.1% │
│ Total      │    74 │  3118 │ 100.0% │ 100.0% │
└────────────┴───────┴───────┴────────┴────────┘
```

## License

GNU GPL v3
