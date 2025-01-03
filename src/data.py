from dataclasses import dataclass

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

@dataclass(frozen=True)
class AnalysisResults:
    stats: dict[str, LanguageStats]
    total_files: int
    total_lines: int
