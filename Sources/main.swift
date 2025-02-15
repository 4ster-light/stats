import ArgumentParser
import Foundation
import Rainbow

struct Stats: ParsableCommand {
  @Argument(help: "Directory to analyze. Defaults to current directory.")
  var directory: String = "."

  func run() throws {
    let directoryURL = URL(fileURLWithPath: directory, isDirectory: true)

    let result = getFiles(directory: directoryURL)
      .flatMap { files in
        let analyses = files.compactMap { analyzeFile(filePath: $0) }
        return .success(analyses)
      }
      .map(aggregateResults)
      .map(displayResults)

    if case .failure(let error) = result {
      print(error.description.red)
    }
  }
}

Stats.main()
