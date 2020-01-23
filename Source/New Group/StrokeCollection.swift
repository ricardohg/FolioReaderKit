//
//  StrokeCollection.swift
//  Eduac
//
//  Created by ricardo hernandez  on 2/22/19.
//  Copyright © 2019 webcat. All rights reserved.
//

import Foundation
import UIKit

open class StrokeCollection {
    open var strokes: [Stroke] = []
    open var undoStrokes: [Stroke] = []
    open var activeStroke: Stroke?
    
    open func takeActiveStroke() {
        if let stroke = activeStroke {
            strokes.append(stroke)
            undoStrokes.removeAll()
            activeStroke = nil
        }
    }
    
    public init() {}
}

enum StrokePhase {
    case began
    case changed
    case ended
    case cancelled
}

public struct StrokeSample {
    
    // Always.
    let timestamp: TimeInterval
    let location: CGPoint
    
    // 3D Touch or Pencil.
    var force: CGFloat?
    
    // Pencil only.
    var estimatedProperties: UITouch.Properties = []
    var estimatedPropertiesExpectingUpdates: UITouch.Properties = []
    var altitude: CGFloat?
    var azimuth: CGFloat?
    
    var azimuthUnitVector: CGVector {
        var vector = CGVector(dx: 1.0, dy: 0.0)
        if let azimuth = self.azimuth {
            vector = vector.applying(CGAffineTransform(rotationAngle: azimuth))
        }
        return vector
    }
    
    init(timestamp: TimeInterval,
         location: CGPoint,
         coalesced: Bool,
         predicted: Bool = false,
         force: CGFloat? = nil,
         azimuth: CGFloat? = nil,
         altitude: CGFloat? = nil,
         estimatedProperties: UITouch.Properties = [],
         estimatedPropertiesExpectingUpdates: UITouch.Properties = []) {
        
        self.timestamp = timestamp
        self.location = location
        self.force = force
        self.coalesced = coalesced
        self.predicted = predicted
        self.altitude = altitude
        self.azimuth = azimuth
    }
    
    /// Convenience accessor returns a non-optional (Default: 1.0)
    var forceWithDefault: CGFloat {
        return force ?? 1.0
    }
    
    /// Returns the force perpendicular to the screen. The regular pencil force is along the pencil axis.
    var perpendicularForce: CGFloat {
        let force = forceWithDefault
        if let altitude = altitude {
            let result = force / CGFloat(sin(Double(altitude)))
            return result
        } else {
            return force
        }
    }
    
    // Values for debug display.
    let coalesced: Bool
    let predicted: Bool
}

enum StrokeState {
    case active
    case done
    case cancelled
}

public struct Shape {
    var path: UIBezierPath
    var backgroundColor: UIColor
    var borderColor: UIColor
    var borderWidth: CGFloat
    
    init(path: UIBezierPath, backgroundColor: UIColor = .black, borderColor: UIColor = .clear, borderWidth: CGFloat = 0.0) {
        self.path = path
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
}

open class Stroke {
    static let calligraphyFallbackAzimuthUnitVector = CGVector(dx: 1.0, dy: 1.0).normalized!
    
    var samples: [StrokeSample] = []
    var predictedSamples: [StrokeSample] = []
    var previousPredictedSamples: [StrokeSample]?
    var state: StrokeState = .active
    var sampleIndicesExpectingUpdates = Set<Int>()
    var expectsAltitudeAzimuthBackfill = false
    var hasUpdatesFromStartTo: Int?
    var hasUpdatesAtEndFrom: Int?
    
    open var color: UIColor?
    open var width: Double?
    open var shape: Shape?
    
    var strokeDisplay: StrokeViewDisplayOptions?
    
    open var receivedAllNeededUpdatesBlock: (() -> Void)?
    
    func add(sample: StrokeSample) -> Int {
        let resultIndex = samples.count
        if hasUpdatesAtEndFrom == nil {
            hasUpdatesAtEndFrom = resultIndex
        }
        samples.append(sample)
        if previousPredictedSamples == nil {
            previousPredictedSamples = predictedSamples
        }
        if sample.estimatedPropertiesExpectingUpdates != [] {
            sampleIndicesExpectingUpdates.insert(resultIndex)
        }
        predictedSamples.removeAll()
        return resultIndex
    }
    
    func update(sample: StrokeSample, at index: Int) {
        if index == 0 {
            hasUpdatesFromStartTo = 0
        } else if hasUpdatesFromStartTo != nil && index == hasUpdatesFromStartTo! + 1 {
            hasUpdatesFromStartTo = index
        } else if hasUpdatesAtEndFrom == nil || hasUpdatesAtEndFrom! > index {
            hasUpdatesAtEndFrom = index
        }
        samples[index] = sample
        sampleIndicesExpectingUpdates.remove(index)
        
        if sampleIndicesExpectingUpdates.isEmpty {
            if let block = receivedAllNeededUpdatesBlock {
                receivedAllNeededUpdatesBlock = nil
                block()
            }
        }
    }
    
    func addPredicted(sample: StrokeSample) {
        predictedSamples.append(sample)
    }
    
    open func clearUpdateInfo() {
        hasUpdatesFromStartTo = nil
        hasUpdatesAtEndFrom = nil
        previousPredictedSamples = nil
    }
    
    func updatedRanges() -> [CountableClosedRange<Int>] {
        var ranges = [CountableClosedRange<Int>]()
        
        if let hasUpdatesFromStartTo = self.hasUpdatesFromStartTo,
            let hasUpdatesAtEndFrom = self.hasUpdatesAtEndFrom {
            ranges = [0...(hasUpdatesFromStartTo), hasUpdatesAtEndFrom...(samples.count - 1)]
            
        } else if let hasUpdatesFromStartTo = self.hasUpdatesFromStartTo {
            ranges = [0...(hasUpdatesFromStartTo)]
            
        } else if let hasUpdatesAtEndFrom = self.hasUpdatesAtEndFrom {
            ranges = [(hasUpdatesAtEndFrom)...(samples.count - 1)]
        }
        
        return ranges
    }
    
    func containSamples(in stroke:Stroke) -> Bool {
        
        for sample in stroke.samples {
            
           return samples.filter { compare(ls: sample, rs: $0) }.count > 0
            
        }
        
        return false
        
    }
    
    func shapeContainSamples(in stroke: Stroke) -> Bool {
        guard let origin = samples.first, let completeFrame = samples.last else {
            return false
        }
        
        let width = completeFrame.location.x - origin.location.x
        let height = completeFrame.location.y - origin.location.y
        let size = CGSize(width: width, height: height)
        let frame = CGRect(origin: origin.location, size: size)
        return stroke.samples.contains(where: { frame.contains($0.location) })        
    }
    
    private func compare(ls: StrokeSample, rs: StrokeSample) -> Bool {
        
        let delta: CGFloat = 10
    
        let dxlrHigh = rs.location.x + delta
        let dxlrLow = rs.location.x - delta
        
        let dylrHigh = rs.location.y + delta
        let dylrLow = rs.location.y - delta
        
        let x = ls.location.x
        let y = ls.location.y
        
        return  (x >= dxlrLow && x <= dxlrHigh) && (y >= dylrLow && y <= dylrHigh)
        
    }
    
}

extension Stroke: Sequence {
    open func makeIterator() -> StrokeSegmentIterator {
        return StrokeSegmentIterator(stroke: self)
    }
}

private func interpolatedNormalUnitVector(between vector1: CGVector, and vector2: CGVector) -> CGVector {
    if let result = (vector1.normal + vector2.normal)?.normalized {
        return result
    } else {
        // This means they resulted in a 0,0 vector,
        // in this case one of the incoming vectors is a good result.
        if let result = vector1.normalized {
            return result
        } else if let result = vector2.normalized {
            return result
        } else {
            // This case should not happen.
            return CGVector(dx: 1.0, dy: 0.0)
        }
    }
}

open class StrokeSegment {
    var sampleBefore: StrokeSample?
    var fromSample: StrokeSample!
    var toSample: StrokeSample!
    var sampleAfter: StrokeSample?
    var fromSampleIndex: Int
    
    var color: UIColor?
    
    var width: Double?
    
    var strokeDisplay: StrokeViewDisplayOptions?
    
    var segmentUnitNormal: CGVector {
        return segmentStrokeVector.normal!.normalized!
    }
    
    var fromSampleUnitNormal: CGVector {
        return interpolatedNormalUnitVector(between: previousSegmentStrokeVector, and: segmentStrokeVector)
    }
    
    var toSampleUnitNormal: CGVector {
        return interpolatedNormalUnitVector(between: segmentStrokeVector, and: nextSegmentStrokeVector)
    }
    
    var previousSegmentStrokeVector: CGVector {
        if let sampleBefore = self.sampleBefore {
            return fromSample.location - sampleBefore.location
        } else {
            return segmentStrokeVector
        }
    }
    
    var segmentStrokeVector: CGVector {
        return toSample.location - fromSample.location
    }
    
    var nextSegmentStrokeVector: CGVector {
        if let sampleAfter = self.sampleAfter {
            return sampleAfter.location - toSample.location
        } else {
            return segmentStrokeVector
        }
    }
    
    public init(sample: StrokeSample, color: UIColor?, width: Double, style: StrokeViewDisplayOptions) {
        self.sampleAfter = sample
        self.color = color
        self.strokeDisplay = style
        self.width = width
        self.fromSampleIndex = -2
    }
    
    @discardableResult
    func advanceWithSample(incomingSample: StrokeSample?) -> Bool {
        if let sampleAfter = self.sampleAfter {
            self.sampleBefore = fromSample
            self.fromSample = toSample
            self.toSample = sampleAfter
            self.sampleAfter = incomingSample
            self.fromSampleIndex += 1
            return true
        }
        return false
    }
}

open class StrokeSegmentIterator: IteratorProtocol {
    private let stroke: Stroke
    private var nextIndex: Int
    private let sampleCount: Int
    private let predictedSampleCount: Int
    private var segment: StrokeSegment!
    
    init(stroke: Stroke) {
        self.stroke = stroke
        nextIndex = 1
        sampleCount = stroke.samples.count
        predictedSampleCount = stroke.predictedSamples.count
        if (predictedSampleCount + sampleCount) > 1 {
            segment = StrokeSegment(sample: sampleAt(0)!, color: stroke.color, width: stroke.width ?? 0.5, style: stroke.strokeDisplay ?? .ink)
            segment.advanceWithSample(incomingSample: sampleAt(1))
        }
    }
    
    func sampleAt(_ index: Int) -> StrokeSample? {
        if index < sampleCount {
            return stroke.samples[index]
        }
        let predictedIndex = index - sampleCount
        if predictedIndex < predictedSampleCount {
            return stroke.predictedSamples[predictedIndex]
        } else {
            return nil
        }
    }
    
    open func next() -> StrokeSegment? {
        nextIndex += 1
        if let segment = self.segment {
            if segment.advanceWithSample(incomingSample: sampleAt(nextIndex)) {
                return segment
            }
        }
        return nil
    }
}

// MARK: - Shape -

extension Stroke {
    convenience init(shape: Shape) {
        self.init()
        self.shape = shape
    }
}

