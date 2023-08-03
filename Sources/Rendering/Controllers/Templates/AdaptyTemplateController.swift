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

// TODO: Move this out
// Flat
extension AdaptyUI.LocalizedViewStyle {
    var background: AdaptyUI.Filling {
        get throws {
            guard let result = items["background"]?.asFilling else {
                throw AdaptyUIError.componentNotFound("background")
            }
            return result
        }
    }

    var coverImageShape: AdaptyUI.Shape {
        get throws {
            guard let result = items["cover_image"]?.asShape else {
                throw AdaptyUIError.componentNotFound("cover_image")
            }
            return result
        }
    }
}

// Basic
extension AdaptyUI.LocalizedViewStyle {
    var backgroundImage: AdaptyUI.Image {
        get throws {
            guard let result = items["background_image"]?.asImage else {
                throw AdaptyUIError.componentNotFound("background_image")
            }
            return result
        }
    }

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

    var titleRows: AdaptyUI.СompoundText? {
        items["title_rows"]?.asText
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
                     productsBlock: style.productBlock,
                     purchaseButton: try style.purchaseButton,
                     footerBlock: style.footerBlock,
                     closeButton: try style.closeButton)
    }

    static func createTransparent(config: AdaptyUI.LocalizedViewConfiguration) throws -> TemplateLayoutBuilderTransparent {
        let style = try config.extractStyle("default")

        return .init(background: .image(try style.backgroundImage),
                     contentShape: try style.contentShape,
                     titleRows: style.titleRows,
                     featuresBlock: style.featureBlock,
                     productsBlock: style.productBlock,
                     purchaseButton: try style.purchaseButton,
                     footerBlock: style.footerBlock,
                     closeButton: try style.closeButton)
    }

    static func createFlat(config: AdaptyUI.LocalizedViewConfiguration) throws -> TemplateLayoutBuilderFlat {
        guard let coverImageHeightMultilpyer = config.mainImageRelativeHeight else {
            throw AdaptyUIError.componentNotFound("main_image_relative_height")
        }

        let style = try config.extractStyle("default")

        return .init(background: try style.background,
                     contentShape: try style.contentShape,
                     coverImage: try style.coverImageShape,
                     coverImageHeightMultilpyer: coverImageHeightMultilpyer,
                     titleRows: style.titleRows,
                     featuresBlock: style.featureBlock,
                     productsBlock: style.productBlock,
                     purchaseButton: try style.purchaseButton,
                     footerBlock: style.footerBlock,
                     closeButton: try style.closeButton)
    }

    static func createLayoutFromConfiguration(_ viewConfiguration: AdaptyUI.ViewConfiguration,
                                              locale: String) throws -> LayoutBuilder {
        switch viewConfiguration.templateId {
        case "basic":
            return try createBasic(config: viewConfiguration.extractLocale(locale))
        case "transparent":
            return try createTransparent(config: viewConfiguration.extractLocale(locale))
        case "flat":
            return try createFlat(config: viewConfiguration.extractLocale(locale))
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

        do {
            try layoutBuilder.buildInterface(on: view)
        } catch {
            // TODO: move out
            print("rendering error \(error)")
        }

        layoutBuilder.onAction { [weak self] action in
            switch action {
            case .close:
                self?.dismiss(animated: true)
            default:
                break
            }
        }
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        layoutBuilder.viewDidLayoutSubviews(view)
    }
}
