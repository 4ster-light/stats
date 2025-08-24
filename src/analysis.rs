use crate::config;
use crate::utils;
use crate::models::{AnalysisResults, FileAnalysis, LanguageStats, StatsError};
use anyhow::Result;
use colored::Colorize;
use std::collections::HashMap;
use std::fs;
use std::path::{Path, PathBuf};
use walkdir::{DirEntry, WalkDir};

/// Check if a directory entry should be skipped
fn should_skip(entry: &DirEntry) -> bool {
    // Only skip if it's a directory and it's in our ignored list
    if entry.file_type().is_dir() {
        let file_name = entry.file_name().to_string_lossy();
        let is_hidden = file_name.starts_with('.') && file_name != ".";
        let is_ignored = config::ignored_dirs().contains(file_name.as_ref());

        return is_hidden || is_ignored;
    }

    false
}

/// Get a list of files to analyze in the given directory
pub fn get_files(directory: &Path) -> Result<Vec<PathBuf>, StatsError> {
    // Check if directory exists
    if !directory.exists() {
        return Err(StatsError::DirectoryNotFound(
            directory.display().to_string(),
        ));
    }

    if !directory.is_dir() {
        return Err(StatsError::DirectoryNotFound(
            directory.display().to_string(),
        ));
    }

    let mut files = Vec::new();

    // Walk the directory tree
    let walker = WalkDir::new(directory).follow_links(false).into_iter();
    for entry in walker.filter_entry(|e| !should_skip(e)) {
        match entry {
            Ok(entry) => {
                // Skip directories
                if entry.file_type().is_dir() {
                    continue;
                }
                files.push(entry.path().to_path_buf());
            }
            Err(err) => {
                eprintln!(
                    "{}",
                    format!("Warning: Could not access {}: {}", directory.display(), err).yellow()
                );
            }
        }
    }

    Ok(files)
}

/// Analyze a single file and return its statistics
pub fn analyze_file(file_path: &Path) -> Result<Option<FileAnalysis>, StatsError> {
    // Get language from extension
    let ext = match file_path.extension() {
        Some(ext) => ext.to_string_lossy().to_string(),
        None => return Ok(None),
    };

    // Read file and count lines
    match fs::read_to_string(file_path) {
        Ok(content) => {
            let line_count = content.lines().count();
            Ok(Some(FileAnalysis {
                language: ext,
                line_count,
            }))
        }
        Err(err) => {
            eprintln!(
                "{}",
                format!(
                    "Warning: Could not process {}: {}",
                    file_path.display(),
                    err
                )
                .yellow()
            );
            Ok(None)
        }
    }
}

/// Aggregate individual file analyses into combined results
pub fn aggregate_results(file_analyses: Vec<FileAnalysis>) -> AnalysisResults {
    // Group by language
    let mut lang_stats: HashMap<String, LanguageStats> = HashMap::new();

    for analysis in file_analyses {
        let stats = lang_stats.entry(analysis.language).or_default();
        stats.files += 1;
        stats.lines += analysis.line_count;
    }

    // Calculate totals
    let total_files = lang_stats.values().map(|stats| stats.files).sum();
    let total_lines = lang_stats.values().map(|stats| stats.lines).sum();

    AnalysisResults {
        stats: lang_stats,
        total_files,
        total_lines,
    }
}

/// Display the analysis results in a formatted table
pub fn display_results(results: &AnalysisResults) {
    // Sort languages alphabetically
    let mut languages: Vec<&String> = results.stats.keys().collect();
    languages.sort();

    println!();
    println!("{}", "Language Statistics".cyan().bold());
    println!("┏━━━━━━━━━━━━┳━━━━━━━┳━━━━━━━┳━━━━━━━━┳━━━━━━━━┓");
    println!("┃ Language   ┃ Files ┃ Lines ┃ File % ┃ Line % ┃");
    println!("┡━━━━━━━━━━━━╇━━━━━━━╇━━━━━━━╇━━━━━━━━╇━━━━━━━━┩");

    for lang in languages {
        let stats = &results.stats[lang];
        let (file_pct, line_pct) =
            stats.calculate_percentages(results.total_files, results.total_lines);

        // Padding for alignment
        let padded_lang = utils::right_pad(lang, 10);
        let padded_files = utils::left_pad(&stats.files.to_string(), 5);
        let padded_lines = utils::left_pad(&stats.lines.to_string(), 5);
        let padded_file_pct = utils::left_pad(&format!("{:.1}%", file_pct), 6);
        let padded_line_pct = utils::left_pad(&format!("{:.1}%", line_pct), 6);

        println!(
            "│ {} │ {} │ {} │ {} │ {} │",
            padded_lang.yellow().bold(),
            padded_files,
            padded_lines,
            padded_file_pct,
            padded_line_pct
        );
    }

    println!("└────────────┴───────┴───────┴────────┴────────┘");
    println!();
}
