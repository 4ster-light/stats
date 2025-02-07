import Foundation

struct LanguageStats {
    let files: Int
    let lines: Int

    func calculatePercentages(totalFiles: Int, totalLines: Int) -> (
        filePct: Double, linePct: Double
    ) {
        let filePct = totalFiles > 0 ? Double(files) / Double(totalFiles) * 100 : 0
        let linePct = totalLines > 0 ? Double(lines) / Double(totalLines) * 100 : 0
        return (filePct, linePct)
    }
}

struct FileAnalysis {
    let language: String
    let lineCount: Int
}

struct AnalysisResults {
    let stats: [String: LanguageStats]
    let totalFiles: Int
    let totalLines: Int
}
