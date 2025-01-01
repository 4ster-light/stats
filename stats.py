import sys
from dataclasses import dataclass
from typing import Iterator, Optional
from pathlib import Path
import argparse
from rich.console import Console
from rich.table import Table

# Language file extensions mapping
LANGUAGES: dict[str, str] = {
    "Python": "py",
    "Rust": "rs",
    "Haskell": "hs",
    "Lua": "lua",
    "TypeScript": "ts",
    "JavaScript": "js",
    "Nix": "nix",
    "Elixir": "exs",
    "C": "c",
}

# Directories to skip during analysis
IGNORED_DIRS: set[str] = {"node_modules", "dist", "build", "__pycache__", ".git", "venv", "env", ".venv", "target"}

console = Console()

@dataclass(frozen=True)
class LanguageStats:
    files: int
    lines: int

    def calculate_percentages(self, total_files: int, total_lines: int) -> tuple[float, float]:
        file_pct = (self.files / total_files * 100) if total_files > 0 else 0
        line_pct = (self.lines / total_lines * 100) if total_lines > 0 else 0
        return file_pct, line_pct


@dataclass(frozen=True)
class FileAnalysis:
    language: str
    line_count: int

    @staticmethod
    def analyze(file_path: Path) -> Optional['FileAnalysis']:
        for language, ext in LANGUAGES.items():
            if file_path.suffix == f".{ext}":
                try:
                    line_count = len(file_path.read_text(encoding='utf-8').splitlines())
                    return FileAnalysis(language, line_count)
                except (UnicodeDecodeError, FileNotFoundError) as e:
                    console.print(f"[yellow]Warning: Could not process {file_path}: {str(e)}[/yellow]")
        return None


@dataclass(frozen=True)
class AnalysisResults:
    stats: dict[str, LanguageStats]
    total_files: int
    total_lines: int

    @staticmethod
    def aggregate(file_analyses: list[FileAnalysis]) -> 'AnalysisResults':
        language_stats = {}
        total_files = 0
        total_lines = 0

        for language in LANGUAGES:
            analyses = [a for a in file_analyses if a.language == language]
            files = len(analyses)
            lines = sum(a.line_count for a in analyses)

            language_stats[language] = LanguageStats(files, lines)
            total_files += files
            total_lines += lines

        return AnalysisResults(language_stats, total_files, total_lines)


def get_files(directory: Path) -> Iterator[Path]:
    for path in directory.rglob('*'):
        if path.is_file() and not any(ignore in path.parts for ignore in IGNORED_DIRS):
            yield path


def display_results(results: AnalysisResults) -> None:
    print("\n")
    table = Table(title="Language Statistics", style="cyan")

    table.add_column("Language", justify="left", style="bold yellow", no_wrap=True)
    table.add_column("Files", justify="right")
    table.add_column("Lines", justify="right")
    table.add_column("File %", justify="right")
    table.add_column("Line %", justify="right")

    for language in sorted(results.stats.keys()):
        stats = results.stats[language]
        file_pct, line_pct = stats.calculate_percentages(results.total_files, results.total_lines)

        table.add_row(
            language,
            str(stats.files),
            str(stats.lines),
            f"{file_pct:.1f}%",
            f"{line_pct:.1f}%"
        )

    table.add_row(
        "Total",
        str(results.total_files),
        str(results.total_lines),
        "100.0%",
        "100.0%",
        style="bold green"
    )

    console.print(table)
    print("\n")


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
            FileAnalysis.analyze(file) for file in get_files(directory)
        ) if analysis is not None
    ]

    results = AnalysisResults.aggregate(file_analyses)
    display_results(results)


if __name__ == "__main__":
    main()
