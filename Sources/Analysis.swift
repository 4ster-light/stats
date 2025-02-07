import Foundation
import Rainbow

func aggregateResults(fileAnalyses: [FileAnalysis]) -> AnalysisResults {
    var languageStats: [String: LanguageStats] = [:]
    var totalFiles = 0
    var totalLines = 0

    for language in LANGUAGES.keys {
        let analyses = fileAnalyses.filter { $0.language == language }
        let files = analyses.count
        let lines = analyses.reduce(0) { $0 + $1.lineCount }

        languageStats[language] = LanguageStats(files: files, lines: lines)
        totalFiles += files
        totalLines += lines
    }

    return AnalysisResults(stats: languageStats, totalFiles: totalFiles, totalLines: totalLines)
}

func analyzeFile(filePath: URL) -> FileAnalysis? {
    for (language, ext) in LANGUAGES {
        if filePath.pathExtension == ext {
            do {
                let content = try String(contentsOf: filePath, encoding: .utf8)
                let lineCount = content.components(separatedBy: .newlines).count
                return FileAnalysis(language: language, lineCount: lineCount)
            } catch {
                print(
                    "Warning: Could not process \(filePath.path): \(error.localizedDescription)"
                        .yellow)
            }
        }
    }
    return nil
}

func getFiles(directory: URL) throws -> [URL] {
    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: directory.path) else {
        throw StatsError.directoryNotFound(directory.path)
    }

    guard fileManager.isReadableFile(atPath: directory.path) else {
        throw StatsError.directoryNotReadable(directory.path)
    }

    guard
        let enumerator = fileManager.enumerator(
            at: directory, includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        )
    else {
        throw StatsError.directoryEnumerationFailed(directory.path)
    }

    var files: [URL] = []
    for case let fileURL as URL in enumerator {
        if !IGNORED_DIRS.contains(fileURL.lastPathComponent) {
            files.append(fileURL)
        }
    }
    return files
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

enum StatsError: Error, CustomStringConvertible {
    case directoryNotFound(String)
    case directoryNotReadable(String)
    case directoryEnumerationFailed(String)

    var description: String {
        switch self {
        case .directoryNotFound(let path):
            return "Directory not found: \(path)"
        case .directoryNotReadable(let path):
            return "Directory not readable: \(path)"
        case .directoryEnumerationFailed(let path):
            return "Failed to enumerate files in directory: \(path)"
        }
    }
}
