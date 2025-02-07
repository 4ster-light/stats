import ArgumentParser
import Foundation
import Rainbow

struct Stats: ParsableCommand {
    @Argument(help: "Directory to analyze. Defaults to current directory.")
    var directory: String = "."

    func run() throws {
        let directoryURL = URL(fileURLWithPath: directory, isDirectory: true)

        do {
            let fileAnalyses = try getFiles(directory: directoryURL).compactMap {
                analyzeFile(filePath: $0)
            }
            let results = aggregateResults(fileAnalyses: fileAnalyses)
            displayResults(results: results)
        } catch let error as StatsError {
            print("Error: \(error.description)".red)
        } catch {
            print("Error: An unexpected error occurred.".red)
        }
    }
}

Stats.main()
