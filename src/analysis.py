from typing import Iterator, Optional
from pathlib import Path
from rich.console import Console
from rich.table import Table

from conf import LANGUAGES, IGNORED_DIRS
from data import AnalysisResults, FileAnalysis, LanguageStats

console = Console()

def aggregate_results(file_analyses: list[FileAnalysis]) -> AnalysisResults:
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

def analyze_file(file_path: Path) -> Optional[FileAnalysis]:
        for language, ext in LANGUAGES.items():
            if file_path.suffix == f".{ext}":
                try:
                    line_count = len(file_path.read_text(encoding='utf-8').splitlines())
                    return FileAnalysis(language, line_count)
                except (UnicodeDecodeError, FileNotFoundError) as e:
                    console.print(f"[yellow]Warning: Could not process {file_path}: {str(e)}[/yellow]")
        return None


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