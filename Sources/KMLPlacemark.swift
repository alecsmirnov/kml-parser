//
//  KMLPlacemark.swift
//  KMLParser
//
//  Created by Alexander Smirnov on 05.12.2022.
//

import MapKit

private enum KMLTypeName: String {
    case point = "Point"
    case polygon = "Polygon"
    case lineString = "LineString"
}

protocol KMLPlacemarkType: KMLElementType {
    var style: KMLStyleType? { get set }

    var items: [KMLPlacemarkItemType] { get }

    var name: String? { get }
    var description: String? { get }
    var styleURL: String? { get }

    func nameParse(isStarted: Bool)
    func descriptionParse(isStarted: Bool)
    func styleURLParse(isStarted: Bool)

    func enableStyle(with identifier: String?)
    func disableStyle()
    func enableGeometry(of type: String, with identifier: String?)
    func disableGeometry()
}

final class KMLPlacemark: KMLPlacemarkType {
    var canAddString: Bool {
        nameIsParsed || descriptionIsParsed || styleURLIsParsed
    }

    var style: KMLStyleType?
    
    private(set) var items: [KMLPlacemarkItemType] = []

    private(set) var name: String?
    private(set) var description: String?
    private(set) var styleURL: String?

    let identifier: String?

    private var nameIsParsed = false
    private var descriptionIsParsed = false
    private var styleURLIsParsed = false

    private var hasStyle = false
    private var hasGeometry = false

    private var accumulatedData: String?

    init(identifier: String?) {
        self.identifier = identifier
    }
}

// MARK: - Public methods

extension KMLPlacemark {
    func append(data: String) {
        if hasStyle {
            style?.append(data: data)
        } else if hasGeometry {
            items.last?.geometry.append(data: data)
        } else {
            let filteredData = data.filter { !$0.isWhitespace }

            if !filteredData.isEmpty {
                accumulatedData = (accumulatedData ?? "") + filteredData
            }
        }
    }

    func clearData() {
        accumulatedData = nil
    }

    func nameParse(isStarted: Bool) {
        nameIsParsed = isStarted

        if !nameIsParsed {
            name = accumulatedData
            clearData()
        }
    }

    func descriptionParse(isStarted: Bool) {
        descriptionIsParsed = isStarted

        if !descriptionIsParsed {
            description = accumulatedData
            clearData()
        }
    }

    func styleURLParse(isStarted: Bool) {
        styleURLIsParsed = isStarted

        if !styleURLIsParsed {
            styleURL = accumulatedData
            clearData()
        }
    }

    func enableStyle(with identifier: String?) {
        hasStyle = true
        style = KMLStyle(identifier: identifier)
    }

    func disableStyle() {
        hasStyle = false
    }

    func enableGeometry(of type: String, with identifier: String?) {
        guard let type = KMLTypeName(rawValue: type) else { return }

        hasGeometry = true

        let geometry: KMLGeometryType

        switch type {
            case .point:
                geometry = KMLPoint(identifier: identifier)
            case .polygon:
                geometry = KMLPolygon(identifier: identifier)
            case .lineString:
                geometry = KMLLineString(identifier: identifier)
        }

        let item = KMLPlacemarkItem(geometry: geometry)
        items.append(item)
    }

    func disableGeometry() {
        hasGeometry = false

        let lastGeometry = items.last?.geometry
        lastGeometry?.recalculateShape()
        lastGeometry?.shape?.title = name
        lastGeometry?.shape?.subtitle = description
    }
}
