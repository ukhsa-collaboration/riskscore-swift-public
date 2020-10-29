
import Foundation

public struct ScanInstance: Equatable {
    var value: Double
    var secondsSinceLastScan: Double
    
    /**
     An Adapter type for the EN API attenuation data.
     
     - parameter attenuationValue: The attenuation value at this time.
     - parameter secondsSinceLastScan: The elapsed time since the previous scan.
     */
    public init(attenuationValue: UInt8, secondsSinceLastScan: Int) {
        self.value = Double(attenuationValue)
        self.secondsSinceLastScan = Double(secondsSinceLastScan)
    }
    
    // Used by tests as this matches the type of data provided from the Python simulations
    public init(value: Double, secondsSinceLastScan: Double) {
        self.value = value
        self.secondsSinceLastScan = secondsSinceLastScan
    }
}

struct Observation {
    var sequenceNumber: Int
    var value: Double?
}

func makeObservations(instances: [ScanInstance], sampleResolution: Double) -> [Observation] {
    guard let firstInstance = instances.first else {
        assertionFailure("makeObservations: called with 0 instances")
        return []
    }
    
    // Algorithm assumes that the first observation is unmasked so we do not pad before
    // the first ScanInstance
    let resetFirst = ScanInstance(value: firstInstance.value, secondsSinceLastScan: .zero)
    let resetInstances = [resetFirst] + instances.dropFirst()
    
    return resetInstances.reduce(into: (lastSeq: Double.zero, observations: [Observation]())) { current, next in
        let nextSeq = current.lastSeq + (next.secondsSinceLastScan / sampleResolution)
        
        current.observations.append(Observation(sequenceNumber: Int(nextSeq), value: log(next.value)))
        current.lastSeq = nextSeq
    }.observations
        .pad(makeEntry: { Observation(sequenceNumber: $0, value: nil) }) { $0.sequenceNumber }
        .map { observation in
            // replace a non-finite Double value with `nil`.
            guard let value = observation.value, value.isFinite else {
                return Observation(sequenceNumber: observation.sequenceNumber, value: nil)

            }
            return observation
    }
}
