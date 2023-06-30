//
//  AdaptyTemplateController+Basic.swift
//
//
//  Created by Alexey Goncharov on 30.6.23..
//

import UIKit

final class BasicContent: TemplateContentProvider {
    let closeButtonImage: UIImage
    
    init(closeButtonImage: UIImage) {
        self.closeButtonImage = closeButtonImage
    }
    
    var closeButton: (any ButtonComponent)? {
        Mock.Button(shape: Mock.Shape(background: .image(closeButtonImage),
                                      mask: .circle,
                                      rectCornerRadius: 0.0),
                    text: nil,
                    align: .leading)
    }

    var purchaseButton: any ButtonComponent {
        Mock.Button(shape: .roundedRectGradient,
                    text: .body("Continue", .white),
                    align: .fill)
    }
}


extension AdaptyTemplateController {
    public static func basicTemplateRoundedRect(coverImage: UIImage,
                                                closeButtonImage: UIImage) -> AdaptyTemplateController {
        .init(
            layoutBuilder: TemplateLayoutBuilderBasic(
                content: BasicContent(closeButtonImage: closeButtonImage),
                coverImage: coverImage,
                coverImageHeightMultilpyer: 0.45,
                contentShape: Mock.Shape(background: .color(UIColor.white),
                                         mask: .rect,
                                         rectCornerRadius: 16.0)
            )
        )
    }

    public static func basicTemplateSmileUp(coverImage: UIImage,
                                            closeButtonImage: UIImage) -> AdaptyTemplateController {
        .init(
            layoutBuilder: TemplateLayoutBuilderBasic(
                content: BasicContent(closeButtonImage: closeButtonImage),
                coverImage: coverImage,
                coverImageHeightMultilpyer: 0.35,
                contentShape: Mock.Shape(background: .color(UIColor.black),
                                         mask: .curveDown,
                                         rectCornerRadius: 0.0)
            )
        )
    }

    public static func basicTemplateSmileDown(coverImage: UIImage,
                                              closeButtonImage: UIImage) -> AdaptyTemplateController {
        .init(
            layoutBuilder: TemplateLayoutBuilderBasic(
                content: BasicContent(closeButtonImage: closeButtonImage),
                coverImage: coverImage,
                coverImageHeightMultilpyer: 0.6,
                contentShape: Mock.Shape(background: .color(UIColor.white),
                                         mask: .curveUp,
                                         rectCornerRadius: 0.0)
            )
        )
    }
}
