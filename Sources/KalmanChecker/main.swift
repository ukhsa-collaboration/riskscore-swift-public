
import ArgumentParser
import Foundation
import Files
import Kalman1D
import RiskScore
import Support

struct SmootherChecker: ParsableCommand {
    
    static var configuration = CommandConfiguration(
        abstract: "A utility for testing kalman smoothing / filtering",
        subcommands: [ComputeKalmanFilter.self, ComputeKalmanSmoother.self]
    )
}

extension SmootherChecker {
    struct ComputeKalmanFilter: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Compute the \"mean, covariance\" at each step of the Kalman filter for the ScanInstance (Requires Debug BuildConfiguration)")
        
        @Argument(help: "Path to the ScanInstance data file path")
        var scanInstanceFilePath: String
        
        mutating func run() throws {
            let instances = try ScanInstanceCSVDecoder.decode(from: scanInstanceFilePath)
            let calculator = RiskScoreCalculator(configuration: .exampleConfiguration)
            
            print(calculator
                    .filter(instances: instances)
                    .enumerated()
                    .map { idx, pair in
                        let (mean, covariance) = pair
                        return "\(idx), \(mean), \(covariance)"
                    }
                    .joined(separator: "\n"))
        }
    }
    
    struct ComputeKalmanSmoother: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Compute the \"mean, covariance\" at each step of the Kalman smoother for the ScanInstance (Requires Debug BuildConfiguration)")
        
        @Argument(help: "Path to the ScanInstance data file path")
        var scanInstanceFilePath: String
        
        mutating func run() throws {
            let instances = try ScanInstanceCSVDecoder.decode(from: scanInstanceFilePath)
            let calculator = RiskScoreCalculator(configuration: .exampleConfiguration)
            
            print(calculator
                    .smooth(instances: instances)
                    .enumerated()
                    .map { idx, pair in
                        let (mean, covariance) = pair
                        return "\(idx), \(mean), \(covariance)"
                    }
                    .joined(separator: "\n"))
        }
    }
}

SmootherChecker.main()

