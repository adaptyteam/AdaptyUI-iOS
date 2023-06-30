//
//  AdaptyTemplateController+Flat.swift
//
//
//  Created by Alexey Goncharov on 30.6.23..
//

import UIKit

extension AdaptyTemplateController {
    public static func flatTemplate(backgroundColor: UIColor,
                                    closeButtonImage: UIImage) -> AdaptyTemplateController {
        return AdaptyTemplateController(
            layoutBuilder: TemplateLayoutBuilderFlat(
                content: BasicContent(closeButtonImage: closeButtonImage),
                background: .color(backgroundColor),
                contentShape: .init(background: .color(UIColor.clear),
                                    mask: .rect,
                                    rectCornerRadius: 0.0)
            )
        )
    }
}
