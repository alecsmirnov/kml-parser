//
//  KMLStyle.swift
//  KMLParser
//
//  Created by Alexander Smirnov on 05.12.2022.
//

import MapKit

private enum Constants {
    static let defaultWidth: CGFloat = 0
}

protocol KMLStyleType: KMLElementType {
    var isLineStyle: Bool { get set }
    var isPolyStyle: Bool { get set }
    var isLabelStyle: Bool { get set }

    var strokeWidth: CGFloat?  { get }
    var strokeColor: UIColor?  { get }
    var fillColor: UIColor?  { get }
    var labelScale: CGFloat? { get }
    var labelColor: UIColor? { get }

    func colorParse(isStarted: Bool)
    func scaleParse(isStarted: Bool)
    func widthParse(isStarted: Bool)
    func fillParse(isStarted: Bool)
    func outlineParse(isStarted: Bool)

    func apply(to overlayPathRenderer: MKOverlayPathRenderer)
}

final class KMLStyle: KMLStyleType {
    var canAddString: Bool {
        colorIsParsed || scaleIsParsed || widthIsParsed || fillIsParsed || outlineIsParsed
    }

    var strokeColor: UIColor? {
        hasOutline ? outlineColor : nil
    }

    var isLineStyle = false
    var isPolyStyle = false
    var isLabelStyle = false

    private(set) var strokeWidth: CGFloat?
    private(set) var fillColor: UIColor?
    private(set) var labelScale: CGFloat?
    private(set) var labelColor: UIColor?

    let identifier: String?

    private var colorIsParsed = false
    private var scaleIsParsed = false
    private var widthIsParsed = false
    private var fillIsParsed = false
    private var outlineIsParsed = false

    private var hasOutline = false

    private var outlineColor: UIColor?
    private var accumulatedData: String?

    init(identifier: String?) {
        self.identifier = identifier
    }
}

// MARK: - Public methods

extension KMLStyle {
    func append(data: String) {
        let filteredData = data.filter { !$0.isWhitespace }

        if !filteredData.isEmpty {
            accumulatedData = (accumulatedData ?? "") + filteredData
        }
    }

    func clearData() {
        accumulatedData = nil
    }

    func colorParse(isStarted: Bool) {
        colorIsParsed = isStarted

        if !colorIsParsed {
            defer {
                clearData()
            }

            guard let accumulatedData = accumulatedData,
                  let color = UIColor(hexString: accumulatedData) else {
                return
            }

            if isLineStyle {
                outlineColor = color
            } else if isPolyStyle {
                fillColor = color
            } else if isLabelStyle {
                labelColor = color
            }
        }
    }

    func scaleParse(isStarted: Bool) {
        scaleIsParsed = isStarted

        if !scaleIsParsed {
            defer {
                clearData()
            }

            guard let accumulatedData = accumulatedData else { return }

            let numberFormatter = NumberFormatter()
            if let scale = numberFormatter.number(from: accumulatedData)?.floatValue {
                labelScale = CGFloat(scale)
            }
        }
    }

    func widthParse(isStarted: Bool) {
        widthIsParsed = isStarted

        if !widthIsParsed {
            defer {
                clearData()
            }

            guard let accumulatedData = accumulatedData else { return }

            let numberFormatter = NumberFormatter()
            if let width = numberFormatter.number(from: accumulatedData)?.floatValue {
                strokeWidth = CGFloat(width)
            }
        }
    }

    func fillParse(isStarted: Bool) {
        fillIsParsed = isStarted

        if !fillIsParsed {
            clearData()
        }
    }

    func outlineParse(isStarted: Bool) {
        outlineIsParsed = isStarted

        if !outlineIsParsed {
            defer {
                clearData()
            }

            guard let accumulatedData = accumulatedData else { return }

            let numberFormatter = NumberFormatter()
            if let hasOutlineValue = numberFormatter.number(from: accumulatedData)?.intValue {
                hasOutline = hasOutlineValue != 0
            }
        }
    }

    func apply(to overlayPathRenderer: MKOverlayPathRenderer) {
        overlayPathRenderer.strokeColor = strokeColor
        overlayPathRenderer.fillColor = fillColor
        overlayPathRenderer.lineWidth = strokeWidth ?? Constants.defaultWidth
    }
}

// MARK: - UIColor+hexString

private extension UIColor {
    convenience init?(hexString: String) {
        var hexColor = hexString

        if hexColor.hasPrefix("#") {
            hexColor.removeFirst()
        }

        if hexColor.count == 8 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                let red = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                let green = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                let blue = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                let alpha = CGFloat(hexNumber & 0x000000ff) / 255

                self.init(red: red, green: green, blue: blue, alpha: alpha)
                return
            }
        }

        return nil
    }
}
