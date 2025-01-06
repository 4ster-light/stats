import sys
from pathlib import Path
import argparse

from rich.console import Console
from analysis import analyze_file, get_files, display_results, aggregate_results

console = Console()

def parse_arguments() -> Path:
    parser = argparse.ArgumentParser(
        description="Analyze file counts and line counts for different programming languages in a directory."
    )
    parser.add_argument(
        "directory",
        nargs="?",
        default=".",
        help="Directory to analyze. Defaults to current directory."
    )
    args = parser.parse_args()
    return Path(args.directory)


def main() -> None:
    directory = parse_arguments()

    if not directory.is_dir():
        console.print(f"[red]Error: '{directory}' is not a valid directory.[/red]")
        sys.exit(1)

    file_analyses = [
        analysis for analysis in (
            analyze_file(file) for file in get_files(directory)
        ) if analysis is not None
    ]

    results = aggregate_results(file_analyses)
    display_results(results)


if __name__ == "__main__":
    main()
