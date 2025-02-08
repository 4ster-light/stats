import Foundation
import Rainbow

func aggregateResults(fileAnalyses: [FileAnalysis]) -> AnalysisResults {
    let languageStats = Dictionary(grouping: fileAnalyses, by: \.language)
        .mapValues { analyses in
            let files = analyses.count
            let lines = analyses.reduce(0) { $0 + $1.lineCount }
            return LanguageStats(files: files, lines: lines)
        }

    let totalFiles = languageStats.values.reduce(0) { $0 + $1.files }
    let totalLines = languageStats.values.reduce(0) { $0 + $1.lines }

    return AnalysisResults(stats: languageStats, totalFiles: totalFiles, totalLines: totalLines)
}

func analyzeFile(filePath: URL) -> FileAnalysis? {
    guard let ext = LANGUAGES.first(where: { filePath.pathExtension == $0.value })?.key else {
        return nil
    }

    do {
        let content = try String(contentsOf: filePath, encoding: .utf8)
        let lineCount = content.components(separatedBy: .newlines).count
        return FileAnalysis(language: ext, lineCount: lineCount)
    } catch {
        print("Warning: Could not process \(filePath.path): \(error.localizedDescription)".yellow)
        return nil
    }
}

func getFiles(directory: URL) -> Result<[URL], StatsError> {
    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: directory.path) else {
        return .failure(.directoryNotFound(directory.path))
    }

    guard fileManager.isReadableFile(atPath: directory.path) else {
        return .failure(.directoryNotReadable(directory.path))
    }

    guard
        let enumerator = fileManager.enumerator(
            at: directory, includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        )
    else {
        return .failure(.directoryEnumerationFailed(directory.path))
    }

    let files = enumerator.compactMap { $0 as? URL }
        .filter { !IGNORED_DIRS.contains($0.lastPathComponent) }

    return .success(files)
}

func displayResults(results: AnalysisResults) {
    print("\n")
    print("Language Statistics".cyan.bold)
    print("┏━━━━━━━━━━━━┳━━━━━━━┳━━━━━━━┳━━━━━━━━┳━━━━━━━━┓")
    print("┃ Language   ┃ Files ┃ Lines ┃ File % ┃ Line % ┃")
    print("┡━━━━━━━━━━━━╇━━━━━━━╇━━━━━━━╇━━━━━━━━╇━━━━━━━━┩")

    for language in results.stats.keys.sorted() {
        guard let stats = results.stats[language] else { continue }
        let (filePct, linePct) = stats.calculatePercentages(
            totalFiles: results.totalFiles, totalLines: results.totalLines)

        print(
            "│ \(language.padding(toLength: 10, withPad: " ", startingAt: 0).bold.yellow) │ \(String(stats.files).padding(toLength: 5, withPad: " ", startingAt: 0)) │ \(String(stats.lines).padding(toLength: 5, withPad: " ", startingAt: 0)) │ \(String(format: "%.1f%%", filePct).padding(toLength: 6, withPad: " ", startingAt: 0)) │ \(String(format: "%.1f%%", linePct).padding(toLength: 6, withPad: " ", startingAt: 0)) │"
        )
    }

    print("└────────────┴───────┴───────┴────────┴────────┘")
    print("\n")
}
