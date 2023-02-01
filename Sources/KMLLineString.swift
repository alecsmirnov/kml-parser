//
//  KMLLineString.swift
//  KMLParser
//
//  Created by Alexander Smirnov on 05.12.2022.
//

import MapKit

protocol KMLLineStringType: KMLGeometryType {
    var points: [CLLocationCoordinate2D] { get }
}

final class KMLLineString: KMLLineStringType {
    var shape: MKShape? {
        MKPolyline(coordinates: &points, count: points.count)
    }

    private(set) var points: [CLLocationCoordinate2D] = []

    let identifier: String?

    private var coordinatesIsParsed = false
    private var accumulatedData: String?

    init(identifier: String?) {
        self.identifier = identifier
    }
}

// MARK: - Public methods

extension KMLLineString {
    func append(data: String) {
        accumulatedData = (accumulatedData ?? "") + data
    }

    func clearData() {
        accumulatedData = nil
    }

    func coordinatesParse(isStarted: Bool) {
        coordinatesIsParsed = isStarted

        guard !coordinatesIsParsed, let accumulatedData = accumulatedData else { return }

        points = Self.makeLocationCoordinates(from: accumulatedData)
        clearData()
    }

    func createOverlayPathRenderer(for shape: MKShape) -> MKOverlayPathRenderer? {
        guard let polygon = shape as? MKPolygon else {
            return nil
        }

        return MKPolygonRenderer(polygon: polygon)
    }
}
