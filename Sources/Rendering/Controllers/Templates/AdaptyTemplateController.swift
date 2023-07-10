//
//  AdaptyTemplateController.swift
//
//
//  Created by Alexey Goncharov on 30.6.23..
//

import Adapty
import UIKit

extension AdaptyUI.LocalizedViewConfiguration {
    func extractStyle(_ id: String) throws -> AdaptyUI.LocalizedViewStyle {
        guard let style = styles[id] else {
            throw AdaptyUIError.styleNotFound(id)
        }
        return style
    }
}

// Basic
extension AdaptyUI.LocalizedViewStyle {
    var coverImage: AdaptyUI.Image {
        get throws {
            guard let result = items["cover_image"]?.asImage else {
                throw AdaptyUIError.componentNotFound("cover_image")
            }
            return result
        }
    }

    var contentShape: AdaptyUI.Shape {
        get throws {
            guard let result = items["main_content_shape"]?.asShape else {
                throw AdaptyUIError.componentNotFound("main_content_shape")
            }
            return result
        }
    }
    
    var titleRows: AdaptyUI.TextItems? {
        items["title_rows"]?.asTextItems
    }

    var purchaseButton: AdaptyUI.Button {
        get throws {
            guard let result = items["purchase_button"]?.asButton else {
                throw AdaptyUIError.componentNotFound("purchase_button")
            }
            return result
        }
    }

    var closeButton: AdaptyUI.Button {
        get throws {
            guard let result = items["close_button"]?.asButton else {
                throw AdaptyUIError.componentNotFound("close_button")
            }
            return result
        }
    }
}

extension AdaptyTemplateController {
    static func createBasic(config: AdaptyUI.LocalizedViewConfiguration) throws -> TemplateLayoutBuilderBasic {
        guard let coverImageHeightMultilpyer = config.mainImageRelativeHeight else {
            throw AdaptyUIError.componentNotFound("main_image_relative_height")
        }

        let style = try config.extractStyle("default")

        return .init(coverImage: try style.coverImage,
                     coverImageHeightMultilpyer: coverImageHeightMultilpyer,
                     contentShape: try style.contentShape,
                     titleRows: style.titleRows,
                     featuresBlock: style.featureBlock,
                     purchaseButton: try style.purchaseButton,
                     closeButton: try style.closeButton)
    }

    static func createLayoutFromConfiguration(_ viewConfiguration: AdaptyUI.ViewConfiguration,
                                              locale: String) throws -> LayoutBuilder {
        switch viewConfiguration.templateId {
        case "basic":
            return try createBasic(config: viewConfiguration.extractLocale(locale))
        default:
            throw AdaptyUIError.unsupportedTemplate(viewConfiguration.templateId)
        }
    }

    public static func template(_ viewConfiguration: AdaptyUI.ViewConfiguration) throws -> AdaptyTemplateController {
        .init(
            layoutBuilder: try createLayoutFromConfiguration(viewConfiguration, locale: "en")
        )
    }
}

public final class AdaptyTemplateController: UIViewController {
    private let layoutBuilder: LayoutBuilder

    init(layoutBuilder: LayoutBuilder) {
        self.layoutBuilder = layoutBuilder

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        layoutBuilder.buildInterface(on: view)
        layoutBuilder.onCloseButtonPressed { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        layoutBuilder.viewDidLayoutSubviews(view)
    }
}
