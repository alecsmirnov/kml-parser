//
//  KMLElementType.swift
//  KMLParser
//
//  Created by Alexander Smirnov on 05.12.2022.
//

import MapKit

protocol KMLElementType: AnyObject {
    var canAddString: Bool { get }
    var identifier: String? { get }

    func append(data: String)
    func clearData()
}

// MARK: - Default methods

extension KMLElementType {
    var canAddString: Bool {
        false
    }
}

// MARK: - Helper methods

extension KMLElementType {
    static func makeLocationCoordinates(from string: String) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []

        let tuples = string.components(separatedBy: .whitespacesAndNewlines)

        for tuple in tuples {
            if let locationCoordinate = makeLocationCoordinate(from: tuple) {
                coordinates.append(locationCoordinate)
            }
        }

        return coordinates
    }

    static func makeLocationCoordinate(from string: String) -> CLLocationCoordinate2D? {
        let scanner = Scanner(string: string)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: ",")

        if #available(iOS 13, *) {
            if let longitude = scanner.scanDouble(), let latitude = scanner.scanDouble() {
                let locationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                if CLLocationCoordinate2DIsValid(locationCoordinate) {
                    return locationCoordinate
                }
            }
        } else {
            var longitude: Double = 0
            var latitude: Double = 0

            if scanner.scanDouble(&longitude), scanner.scanDouble(&latitude) {
                let locationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                if CLLocationCoordinate2DIsValid(locationCoordinate) {
                    return locationCoordinate
                }
            }
        }

        return nil
    }
}
