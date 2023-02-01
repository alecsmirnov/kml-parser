//
//  KMLPoint.swift
//  KMLParser
//
//  Created by Alexander Smirnov on 05.12.2022.
//

import MapKit

protocol KMLPointType: KMLGeometryType {
    var point: CLLocationCoordinate2D? { get }
}

final class KMLPoint: KMLPointType {
    var shape: MKShape? {
        guard let point = point else {
            return nil
        }

        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = point

        return pointAnnotation
    }

    private(set) var point: CLLocationCoordinate2D?

    let identifier: String?

    private var coordinateIsParsed = false
    private var accumulatedData: String?

    init(identifier: String?) {
        self.identifier = identifier
    }
}

// MARK: - Public methods

extension KMLPoint {
    func append(data: String) {
        accumulatedData = (accumulatedData ?? "") + data
    }
    
    func clearData() {
        accumulatedData = nil
    }

    func coordinateParse(isStarted: Bool) {
        coordinateIsParsed = isStarted

        guard !coordinateIsParsed, let accumulatedData = accumulatedData else { return }

        point = Self.makeLocationCoordinate(from: accumulatedData)
        clearData()
    }
}
