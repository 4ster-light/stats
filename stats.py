import sys
from dataclasses import dataclass
from typing import Iterator, Optional
from pathlib import Path

# Language file extensions mapping
LANGUAGES: dict[str, str] = {
    "Python": "py",
    "Go": "go",
    "Templ": "templ",
    "Rust": "rs",
    "Haskell": "hs",
    "Lua": "lua",
    "Julia": "jl",
    "TypeScript": "ts",
    "JavaScript": "js",
    "Nix": "nix",
}

# Directories to skip during analysis
IGNORED_DIRS: set[str] = {"node_modules", "dist", "build", "__pycache__", ".git"}


@dataclass(frozen=True)
class LanguageStats:
    files: int
    lines: int

    # Calculate percentage of files and lines for this language
    def calculate_percentages(self, total_files: int, total_lines: int) -> tuple[float, float]:
        file_pct = (self.files / total_files * 100) if total_files > 0 else 0
        line_pct = (self.lines / total_lines * 100) if total_lines > 0 else 0
        return file_pct, line_pct


@dataclass(frozen=True)
class FileAnalysis:
    language: str
    line_count: int

    # Analyze a single file and return its language and line count
    @staticmethod
    def analyze(file_path: Path) -> Optional['FileAnalysis']:
        for language, ext in LANGUAGES.items():
            if file_path.suffix == f".{ext}":
                try:
                    line_count = len(file_path.read_text(encoding='utf-8').splitlines())
                    return FileAnalysis(language, line_count)
                except (UnicodeDecodeError, FileNotFoundError) as e:
                    print(f"\033[93mWarning: Could not process {file_path}: {str(e)}\033[0m")
        return None


@dataclass(frozen=True)
class AnalysisResults:
    stats: dict[str, LanguageStats]
    total_files: int
    total_lines: int

    # Combine individual file analyses into final results
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


# Yield files from a directory tree, skipping ignored directories
def get_files(directory: Path) -> Iterator[Path]:
    for path in directory.rglob('*'):
        if path.is_file() and not any(ignore in path.parts for ignore in IGNORED_DIRS):
            yield path


# Print table border with given style characters
def print_border(style: tuple[str, str, str]) -> None:
    left, mid, right = style
    segments = [left + "─" * 15] + [mid + "─" * 10 for _ in range(4)]
    print(''.join(segments) + right)


# Print analysis results in a formatted table
def display_results(results: AnalysisResults) -> None:
    # Header row
    print_border(("┌", "┬", "┐"))
    print(f"│{'Language':<15}│{'Files':>10}│{'Lines':>10}│{'File %':>10}│{'Line %':>10}│")
    print_border(("├", "┼", "┤"))

    # Individual language rows
    for language in sorted(results.stats.keys()):
        stats = results.stats[language]
        file_pct, line_pct = stats.calculate_percentages(results.total_files, results.total_lines)

        print(
            f"│{language:<15}"
            f"│{stats.files:>10}"
            f"│{stats.lines:>10}"
            f"│{file_pct:>9.1f}%"
            f"│{line_pct:>9.1f}%│"
        )

    # Total row
    print_border(("├", "┼", "┤"))
    print(
        f"│{'Total':<15}"
        f"│{results.total_files:>10}"
        f"│{results.total_lines:>10}"
        f"│{100:>9.1f}%"
        f"│{100:>9.1f}%│"
    )
    print_border(("└", "┴", "┘"))


def main() -> None:
    directory = Path(sys.argv[1] if len(sys.argv) > 1 else ".")

    if not directory.is_dir():
        print(f"\033[91mError: '{directory}' is not a valid directory.\033[0m")
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
