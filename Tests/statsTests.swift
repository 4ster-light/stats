import XCTest

@testable import stats

final class StatsTests: XCTestCase {
    func testLanguageStatsPercentages() {
        let stats = LanguageStats(files: 10, lines: 100)
        let (filePct, linePct) = stats.calculatePercentages(totalFiles: 20, totalLines: 200)
        XCTAssertEqual(filePct, 50.0)
        XCTAssertEqual(linePct, 50.0)
    }

    func testAggregateResults() {
        let analyses = [
            FileAnalysis(language: "Python", lineCount: 50),
            FileAnalysis(language: "Python", lineCount: 50),
            FileAnalysis(language: "Rust", lineCount: 100),
        ]
        let results = aggregateResults(fileAnalyses: analyses)

        XCTAssertEqual(results.totalFiles, 3)
        XCTAssertEqual(results.totalLines, 200)
        XCTAssertEqual(results.stats["Python"]?.files, 2)
        XCTAssertEqual(results.stats["Python"]?.lines, 100)
        XCTAssertEqual(results.stats["Rust"]?.files, 1)
        XCTAssertEqual(results.stats["Rust"]?.lines, 100)
    }

    func testAnalyzeFile() {
        let tempFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(
            "test.py")
        try? "print('Hello, World!')\nprint('Goodbye, World!')".write(
            to: tempFile, atomically: true, encoding: .utf8)

        let analysis = analyzeFile(filePath: tempFile)
        XCTAssertEqual(analysis?.language, "Python")
        XCTAssertEqual(analysis?.lineCount, 2)

        try? FileManager.default.removeItem(at: tempFile)
    }

    func testGetFiles() throws {
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("testDir")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let tempFile1 = tempDir.appendingPathComponent("test.py")
        let tempFile2 = tempDir.appendingPathComponent("test.rs")
        try "print('Hello')".write(to: tempFile1, atomically: true, encoding: .utf8)
        try "fn main() {}".write(to: tempFile2, atomically: true, encoding: .utf8)

        let result = getFiles(directory: tempDir)
        switch result {
        case .success(let files):
            XCTAssertEqual(files.count, 2)
        case .failure:
            XCTFail("Expected success but got failure")
        }

        try FileManager.default.removeItem(at: tempDir)
    }

    func testErrorHandling() {
        let invalidDir = URL(fileURLWithPath: "/invalid/path")
        let result = getFiles(directory: invalidDir)
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTFail("Expected directoryNotFound error but got \(error)")
        }
    }
}
