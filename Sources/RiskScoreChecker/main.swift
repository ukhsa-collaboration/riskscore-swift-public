
import ArgumentParser
import Foundation
import Files
import Kalman1D
import RiskScore
import Support

struct RiskScoreChecker: ParsableCommand {
    
    static var configuration = CommandConfiguration(
        abstract: "A utility for testing riskscoring",
        subcommands: [RiskScoreComparison.self, ComputeRiskScore.self],
        defaultSubcommand: RiskScoreComparison.self
    )
}

extension RiskScoreChecker {
    struct RiskScoreComparison: ParsableCommand {
        @Argument(help: "The path to the scaninstance directory")
        var scanInstanceDir: String
        
        @Argument(help: "The path to the riskscore file")
        var riskScorePath: String
        
        @Option(name: .shortAndLong, help: "Number to calculate", transform: NumberToCalculate.init)
        var number: NumberToCalculate = .all
        
        @Option(name: [.customLong("save-smoother-data"), .customShort("s")], help: "Save the intermediatte filter and smoother data (overwrites existing files)")
        var filterAndSmoothDataDir: String?
            
        mutating func run() throws {
            let expectedResults = try RiskScoreResultsCSVDecoder.decode(from: riskScorePath)
            
            print("experiment python swift diff")
            try computeScores().forEach { (instance, riskScore) in
                guard let expectedScore = expectedResults[instance] else {
                    print("cannot find result for \(instance.name)")
                    return
                }
                print("\(instance.name) \(expectedScore.score) \(riskScore.score) \(expectedScore.score - riskScore.score)")
            }
        }
        
        func computeScores() throws -> [(InstanceName, RiskScoreValue)] {
            let calculator = RiskScoreCalculator(configuration: .exampleConfiguration)
            
            let maximum: Int
            switch number {
            case .all: maximum = Int(INT_MAX)
            case .maximum(let max): maximum = max
            }
            
            return try Folder(path: scanInstanceDir).files
                .prefix(maximum)
                .map { (file: File) -> (InstanceName, RiskScoreValue) in
                    let instances = try ScanInstanceCSVDecoder.decode(from: file.path)
                    let score = calculator.calculate(instances: instances)
                    return (InstanceName(name: file.name), RiskScoreValue(score: score))
                }
        }
        
        enum NumberToCalculate {
            enum Errors: Error {
                case invalidNumber(String)
            }
            
            case all
            case maximum(of: Int)
            
            init(argument: String) throws {
                guard let value = Int(argument),
                      value > 0 else {
                    throw Errors.invalidNumber(argument)
                }
                self = .maximum(of: value)
            }
        }
    }
    
    struct ComputeRiskScore: ParsableCommand {
        @Argument(help: "Path to the ScanInstance data file path")
        var scanInstanceFilePath: String
        
        mutating func run() throws {
            let instances = try ScanInstanceCSVDecoder.decode(from: scanInstanceFilePath)
            let calculator = RiskScoreCalculator(configuration: .exampleConfiguration)
    
            print(calculator.calculate(instances: instances))
        }
    }
}

RiskScoreChecker.main()

