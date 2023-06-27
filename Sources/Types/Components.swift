//
//  Components.swift
//
//
//  Created by Alexey Goncharov on 27.6.23..
//

import Adapty
import UIKit

protocol TextComponent {
    var value: String? { get }
    var uiFont: UIFont? { get }
    var uiColor: UIColor? { get }
}

protocol ShapeComponent {
    var background: BackgroundTBU { get }
    var mask: MaskTBU { get }
    var rectCornerRadius: Double? { get }
}

protocol TextRowComponent {
    var value: String? { get }
    var size: Double? { get }
    var uiColor: UIColor? { get }
}

protocol TextRowsComponent {
    var items: [TextRowComponent] { get }
    var uiFont: UIFont? { get }
}

protocol ButtonComponent where ShapeType: ShapeComponent, TextType: TextComponent {
    associatedtype ShapeType
    associatedtype TextType

    var shape: ShapeType? { get }
    var text: TextType? { get }
    var align: AlignTBU { get }
}

// MARK: - AdaptyUI

extension AdaptyUI.Text: TextComponent {
    var uiFont: UIFont? {
        guard let font = font?.uiFont else { return nil }

        if let size {
            return font.withSize(size)
        } else {
            return font
        }
    }

    var uiColor: UIColor? { color?.uiColor }
}

extension AdaptyUI.TextRow: TextRowComponent {
    var uiColor: UIColor? { color?.uiColor }
}

extension AdaptyUI.TextRows: TextRowsComponent {
    var items: [TextRowComponent] { rows }
    var uiFont: UIFont? { font?.uiFont }
}
