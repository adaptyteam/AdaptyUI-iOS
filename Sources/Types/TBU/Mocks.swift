//
//  Mocks.swift
//
//
//  Created by Alexey Goncharov on 27.6.23..
//

import UIKit

extension UIImage: ImageAsset {
    var uiImage: UIImage? { self }
}

struct Mock {
    struct Color: ColorAsset {
        let uiColor: UIColor

        init(_ color: UIColor) {
            uiColor = color
        }
    }
    
    struct LinearGradient: LinarGradientAsset {
        let startPoint: Point
        let endPoint: Point
        let values: [Value]
        
        init(startPoint: Point, endPoint: Point, values: [Value]) {
            self.startPoint = startPoint
            self.endPoint = endPoint
            self.values = values
        }
    }

    struct Font: FontAsset {
        let uiFont: UIFont
        let uiColor: UIColor?

        init(font: UIFont, defaultColor: UIColor?) {
            uiFont = font
            uiColor = defaultColor
        }
    }

    struct Text: TextComponent {
        let value: String?
        let uiFont: UIFont?
        let uiColor: UIColor?

        init(value: String?, uiFont: UIFont?, uiColor: UIColor?) {
            self.value = value
            self.uiFont = uiFont
            self.uiColor = uiColor
        }
    }

    struct Shape: ShapeComponent {
        let background: BackgroundTBU
        let mask: MaskTBU
        let rectCornerRadius: Double?

        init(background: BackgroundTBU, mask: MaskTBU, rectCornerRadius: Double?) {
            self.background = background
            self.mask = mask
            self.rectCornerRadius = rectCornerRadius
        }
    }

    struct Button: ButtonComponent {
        let shape: Mock.Shape?
        let text: Mock.Text?
        let align: AlignTBU

        init(shape: Mock.Shape?, text: Mock.Text?, align: AlignTBU) {
            self.shape = shape
            self.text = text
            self.align = align
        }
    }
}
