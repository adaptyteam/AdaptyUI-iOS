//
//  AdaptyTemplateController+Transparent.swift
//
//
//  Created by Alexey Goncharov on 30.6.23..
//

import UIKit

extension AdaptyTemplateController {
    public static func transparentTemplate(backgroundImage: UIImage,
                                           closeButtonImage: UIImage) -> AdaptyTemplateController {
        return AdaptyTemplateController(
            layoutBuilder: TemplateLayoutBuilderTransparent(
                content: BasicContent(closeButtonImage: closeButtonImage),
                background: .image(backgroundImage),
                contentShape: Mock.Shape(background: .gradient(Mock.LinearGradient.transparent),
                                         mask: .rect,
                                         rectCornerRadius: 0.0)
            )
        )
    }
}
