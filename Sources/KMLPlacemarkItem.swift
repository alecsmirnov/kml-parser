//
//  KMLPlacemarkItem.swift
//  KMLParser
//
//  Created by Alexander Smirnov on 05.12.2022.
//

import MapKit

protocol KMLPlacemarkItemType {
    var polygon: KMLPolygonType? { get }
    var overlay: MKOverlay? { get }
    var annotation: MKAnnotation? { get }
    var shape: MKShape? { get }
    var geometry: KMLGeometryType { get }
}

struct KMLPlacemarkItem: KMLPlacemarkItemType {
    var polygon: KMLPolygonType? {
        geometry as? KMLPolygonType
    }

    var overlay: MKOverlay? {
        shape as? MKOverlay
    }

    var annotation: MKAnnotation? {
        guard shape is MKPointAnnotation else {
            return nil
        }

        return shape
    }

    var shape: MKShape? {
        geometry.shape
    }

    let geometry: KMLGeometryType
}
