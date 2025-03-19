mod analysis;
mod config;
mod models;

use anyhow::Result;
use clap::Parser;
use colored::Colorize;
use std::path::PathBuf;

/// A tool for analyzing programming language statistics in a directory
#[derive(Parser, Debug)]
#[clap(about, long_about = None)]
struct Args {
    /// Directory to analyze. Defaults to current directory.
    #[clap(default_value = ".")]
    directory: PathBuf,
}

fn main() -> Result<()> {
    let args = Args::parse();
    
    let files = match analysis::get_files(&args.directory) {
        Ok(files) => files,
        Err(err) => {
            eprintln!("{}", err.to_string().red());
            std::process::exit(1);
        }
    };
    
    let mut file_analyses = Vec::new();
    for file in files {
        if let Ok(Some(analysis)) = analysis::analyze_file(&file) {
            file_analyses.push(analysis);
        }
    }
    
    let results = analysis::aggregate_results(file_analyses);
    analysis::display_results(&results);
    
    Ok(())
}
