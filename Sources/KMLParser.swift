//
//  KMLParser.swift
//  KMLParser
//
//  Created by Alexander Smirnov on 05.12.2022.
//

import MapKit

private enum KMLElementName: String {
    case style
    case polyStyle = "PolyStyle"
    case lineStyle = "LineStyle"
    case labelStyle = "LabelStyle"
    case color
    case scale
    case width
    case fill
    case outline
    case placemark = "Placemark"
    case name
    case description
    case styleURL
    case multiGeometry = "MultiGeometry"
    case polygon = "Polygon"
    case lineString = "LineString"
    case point = "Point"
    case coordinates
    case outerBoundaryIs
    case innerBoundaryIs
    case linearRing = "LinearRing"
    case extrude
    case altitudeMode
}

protocol KMLParserType {
    var styles: [String: KMLStyleType] { get }
    var placemarks: [KMLPlacemarkType] { get }

    func parse()
}

final class KMLParser: NSObject, KMLParserType {
    private(set) var styles: [String: KMLStyleType] = [:]
    private(set) var placemarks: [KMLPlacemarkType] = []

    private var style: KMLStyleType?
    private var placemark: KMLPlacemarkType?

    private let xmlParser: XMLParser?

    init(url: URL) {
        xmlParser = XMLParser(contentsOf: url)

        super.init()

        xmlParser?.delegate = self
    }
}

// MARK: - Public methods

extension KMLParser {
    func parse() {
        xmlParser?.parse()
        assignStyles()
    }
}

// MARK: - private methods

private extension KMLParser {
    func assignStyles() {
        for i in placemarks.indices {
            if placemarks[i].style == nil,
               let styleURL = placemarks[i].styleURL,
               let referenceCharacterIndex = styleURL.firstIndex(of: "#") {
                let styleStartIndex = styleURL.index(after: referenceCharacterIndex)

                if styleStartIndex != styleURL.endIndex {
                    let styleIdentifier = String(styleURL[styleStartIndex...])

                    placemarks[i].style = styles[styleIdentifier]
                }
            }
        }
    }
}

// MARK: - XMLParserDelegate

extension KMLParser: XMLParserDelegate {
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String : String] = [:]
    ) {
        let identifier = attributeDict["id"]
        let elementStyle = placemark?.style != nil ? placemark?.style : style

        guard let element = KMLElementName(rawValue: elementName) else { return }

        switch element {
            case .style:
                if let placemark = placemark {
                    placemark.enableStyle(with: identifier)
                } else if identifier != nil  {
                    style = KMLStyle(identifier: identifier)
                }
            case .polyStyle:
                elementStyle?.isPolyStyle = true
            case .lineStyle:
                elementStyle?.isLineStyle = true
            case .labelStyle:
                elementStyle?.isLabelStyle = true
            case .color:
                elementStyle?.colorParse(isStarted: true)
            case .scale:
                elementStyle?.scaleParse(isStarted: true)
            case .width:
                elementStyle?.widthParse(isStarted: true)
            case .fill:
                elementStyle?.fillParse(isStarted: true)
            case .outline:
                elementStyle?.outlineParse(isStarted: true)
            case .placemark:
                placemark = KMLPlacemark(identifier: identifier)
            case .name:
                placemark?.nameParse(isStarted: true)
            case .description:
                placemark?.descriptionParse(isStarted: true)
            case .styleURL:
                placemark?.styleURLParse(isStarted: true)
            case .multiGeometry:
                break
            case .polygon,
                 .lineString,
                 .point:
                placemark?.enableGeometry(of: elementName, with: identifier)
            case .coordinates:
                placemark?.items.last?.geometry.coordinatesParse(isStarted: true)
            case .outerBoundaryIs:
                placemark?.items.last?.polygon?.outerBoundaryParse(isStarted: true)
            case .innerBoundaryIs:
                placemark?.items.last?.polygon?.innerBoundaryParse(isStarted: true)
            case .linearRing:
                placemark?.items.last?.polygon?.linearRingParse(isStarted: true)
            case .extrude:
                placemark?.items.last?.polygon?.extrudeParse(isStarted: true)
            case .altitudeMode:
                placemark?.items.last?.polygon?.altitudeModeParse(isStarted: true)
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        let elementStyle = placemark?.style != nil ? placemark?.style : style

        guard let element = KMLElementName(rawValue: elementName) else { return }

        switch element {
            case .style:
                if let placemark = placemark {
                    placemark.disableStyle()
                } else if let style = style, let identifier = style.identifier {
                    styles[identifier] = style
                    self.style = nil
                }
            case .polyStyle:
                elementStyle?.isPolyStyle = false
            case .lineStyle:
                elementStyle?.isLineStyle = false
            case .labelStyle:
                elementStyle?.isLabelStyle = false
            case .color:
                elementStyle?.colorParse(isStarted: false)
            case .scale:
                elementStyle?.scaleParse(isStarted: false)
            case .width:
                elementStyle?.widthParse(isStarted: false)
            case .fill:
                elementStyle?.fillParse(isStarted: false)
            case .outline:
                elementStyle?.outlineParse(isStarted: false)
            case .placemark:
                guard let placemark = placemark else { return }

                placemarks.append(placemark)
                self.placemark = nil
            case .name:
                placemark?.nameParse(isStarted: false)
            case .description:
                placemark?.descriptionParse(isStarted: false)
            case .styleURL:
                placemark?.styleURLParse(isStarted: false)
            case .multiGeometry:
                break
            case .polygon,
                 .lineString,
                 .point:
                placemark?.disableGeometry()
            case .coordinates:
                placemark?.items.last?.geometry.coordinatesParse(isStarted: false)
            case .outerBoundaryIs:
                placemark?.items.last?.polygon?.outerBoundaryParse(isStarted: false)
            case .innerBoundaryIs:
                placemark?.items.last?.polygon?.innerBoundaryParse(isStarted: false)
            case .linearRing:
                placemark?.items.last?.polygon?.linearRingParse(isStarted: false)
            case .extrude:
                placemark?.items.last?.polygon?.extrudeParse(isStarted: false)
            case .altitudeMode:
                placemark?.items.last?.polygon?.altitudeModeParse(isStarted: false)
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let element: KMLElementType? = placemark != nil ? placemark : style
        element?.append(data: string)
    }
}
