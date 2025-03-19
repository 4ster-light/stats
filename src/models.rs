use std::collections::HashMap;
use thiserror::Error;

/// Statistics for a single programming language
#[derive(Debug, Clone, Default)]
pub struct LanguageStats {
    pub files: usize,
    pub lines: usize,
}

impl LanguageStats {
    /// Calculate file and line percentages for this language
    pub fn calculate_percentages(&self, total_files: usize, total_lines: usize) -> (f64, f64) {
        let file_pct = if total_files > 0 {
            (self.files as f64 / total_files as f64) * 100.0
        } else {
            0.0
        };

        let line_pct = if total_lines > 0 {
            (self.lines as f64 / total_lines as f64) * 100.0
        } else {
            0.0
        };

        (file_pct, line_pct)
    }
}

/// Analysis results for a single file
#[derive(Debug, Clone)]
pub struct FileAnalysis {
    pub language: String,
    pub line_count: usize,
}

/// Aggregate results of code analysis
#[derive(Debug, Clone)]
pub struct AnalysisResults {
    pub stats: HashMap<String, LanguageStats>,
    pub total_files: usize,
    pub total_lines: usize,
}

/// Errors that can occur during analysis
#[derive(Debug, Error)]
pub enum StatsError {
    #[error("Directory not found: {0}")]
    DirectoryNotFound(String),

    #[error("IO error: {0}")]
    IoError(#[from] std::io::Error),
}
