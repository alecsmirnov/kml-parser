//
//  KMLPolygon.swift
//  KMLParser
//
//  Created by Alexander Smirnov on 05.12.2022.
//

import MapKit

enum KMLPolygonAltitudeKind: String {
    case absolute
    case clampToGround
    case clampToSeaFloor
    case relativeToGround
    case relativeToSeaFloor
}

protocol KMLPolygonType: KMLGeometryType {
    var outerRingCoordinates: String? { get }
    var innerRingsCoordinates: [String] { get }
    var altitudeKind: KMLPolygonAltitudeKind? { get }

    func outerBoundaryParse(isStarted: Bool)
    func innerBoundaryParse(isStarted: Bool)
    func linearRingParse(isStarted: Bool)
    func extrudeParse(isStarted: Bool)
    func altitudeModeParse(isStarted: Bool)
}

final class KMLPolygon: KMLPolygonType {
    var canAddString: Bool {
        linearRingIsParsed
    }

    private(set) var shape: MKShape?

    private(set) var outerRingCoordinates: String?
    private(set) var innerRingsCoordinates: [String] = []
    private(set) var altitudeKind: KMLPolygonAltitudeKind?

    let identifier: String?

    private var outerBoundaryIsParsed = false
    private var innerBoundaryIsParsed = false
    private var linearRingIsParsed = false
    private var extrudeIsParsed = false
    private var altitudeModeIsParsed = false

    private var accumulatedData: String?

    init(identifier: String?) {
        self.identifier = identifier
    }
}

// MARK: - Public methods

extension KMLPolygon {
    func append(data: String) {
        accumulatedData = (accumulatedData ?? "") + data
    }

    func clearData() {
        accumulatedData = nil
    }

    func outerBoundaryParse(isStarted: Bool) {
        outerBoundaryIsParsed = isStarted

        if !outerBoundaryIsParsed {
            if let accumulatedData = accumulatedData {
                outerRingCoordinates = accumulatedData
            }

            clearData()
        }
    }

    func innerBoundaryParse(isStarted: Bool) {
        innerBoundaryIsParsed = isStarted

        if !innerBoundaryIsParsed {
            if let accumulatedData = accumulatedData {
                innerRingsCoordinates.append(accumulatedData)
            }

            clearData()
        }
    }

    func linearRingParse(isStarted: Bool) {
        linearRingIsParsed = isStarted
    }

    func createOverlayPathRenderer(for shape: MKShape) -> MKOverlayPathRenderer? {
        guard let polygon = shape as? MKPolygon else {
            return nil
        }

        return MKPolygonRenderer(polygon: polygon)
    }

    func extrudeParse(isStarted: Bool) {
        extrudeIsParsed = isStarted

        if !extrudeIsParsed {
            clearData()
        }
    }

    func altitudeModeParse(isStarted: Bool) {
        altitudeModeIsParsed = isStarted

        if !altitudeModeIsParsed {
            if let accumulatedData = accumulatedData {
                altitudeKind = KMLPolygonAltitudeKind(rawValue: accumulatedData)
            }

            clearData()
        }
    }

    func recalculateShape() {
        var innerPolygons: [MKPolygon] = []

        if !innerRingsCoordinates.isEmpty {
            for innerRingCoordinates in innerRingsCoordinates {
                let coordinates = Self.makeLocationCoordinates(from: innerRingCoordinates)
                let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)

                innerPolygons.append(polygon)
            }
        }

        var coordinates: [CLLocationCoordinate2D] = []

        if let outerRingCoordinates = outerRingCoordinates {
            coordinates = Self.makeLocationCoordinates(from: outerRingCoordinates)
        }

        shape = MKPolygon(coordinates: coordinates, count: coordinates.count, interiorPolygons: innerPolygons)
    }
}
