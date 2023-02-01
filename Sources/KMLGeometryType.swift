//
//  KMLGeometryType.swift
//  KMLParser
//
//  Created by Alexander Smirnov on 05.12.2022.
//

import MapKit

protocol KMLGeometryType: KMLElementType {
    var shape: MKShape? { get }

    func coordinatesParse(isStarted: Bool)
    func createOverlayPathRenderer(for shape: MKShape) -> MKOverlayPathRenderer?
    func recalculateShape()
}

extension KMLGeometryType {
    var canAddString: Bool {
        false
    }

    var shape: MKShape? {
        nil
    }

    func coordinatesParse(isStarted: Bool) {}
    
    func createOverlayPathRenderer(for shape: MKShape) -> MKOverlayPathRenderer? {
        nil
    }

    func recalculateShape() {}
}
