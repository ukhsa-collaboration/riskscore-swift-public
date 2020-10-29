# RiskScore

## API

The public API is [`RiskScoreCalculator`](Sources/RiskScore/RiskScoreCalculator.swift), [`RiskScoreCalculatorConfiguration`](Sources/RiskScore/RiskScoreCalculatorConfiguration.swift) and [`ScanInstance`](Sources/RiskScore/ScanInstance.swift). There is an example configuration `RiskScoreCalculatorConfiguration.exampleConfiguration` taken from the Python [GAEN repo](https://github.com/nhsx) .

## Usage

This project is published as an [SPM ](https://github.com/apple/swift-package-manager/blob/master/Documentation/Usage.md) package. Add the following dependency line into your `Package.swift` dependencies to depend on this project:

```swift
 dependencies: [
    .package(url: "https://github.com/nhsx/riskscore-swift-public", .upToNextMajor(from: "3.0.0"))
]
```

The package exports the `RiskScore` library.
