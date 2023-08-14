//
//  AdaptyTemplateController.swift
//
//
//  Created by Alexey Goncharov on 30.6.23..
//

import Adapty
import UIKit

struct TemplateLayoutBuilderFabric {
    static func createBasic(config: AdaptyUI.LocalizedViewConfiguration,
                            products: [ProductInfoModel]) throws -> TemplateLayoutBuilderBasic {
        guard let coverImageHeightMultilpyer = config.mainImageRelativeHeight else {
            throw AdaptyUIError.componentNotFound("main_image_relative_height")
        }

        let style = try config.extractDefaultStyle()

        return .init(coverImage: try style.coverImage,
                     coverImageHeightMultilpyer: coverImageHeightMultilpyer,
                     contentShape: try style.contentShape,
                     titleRows: style.titleRows,
                     featuresBlock: style.featureBlock,
                     productsBlock: style.productBlock,
                     purchaseButton: try style.purchaseButton,
                     footerBlock: style.footerBlock,
                     closeButton: try style.closeButton,
                     initialProducts: products)
    }

    static func createTransparent(config: AdaptyUI.LocalizedViewConfiguration,
                                  products: [ProductInfoModel]) throws -> TemplateLayoutBuilderTransparent {
        let style = try config.extractDefaultStyle()
        
        return .init(background: .image(try style.backgroundImage),
                     contentShape: try style.contentShape,
                     titleRows: style.titleRows,
                     featuresBlock: style.featureBlock,
                     productsBlock: style.productBlock,
                     purchaseButton: try style.purchaseButton,
                     footerBlock: style.footerBlock,
                     closeButton: try style.closeButton,
                     initialProducts: products)
    }

    static func createFlat(config: AdaptyUI.LocalizedViewConfiguration,
                           products: [ProductInfoModel]) throws -> TemplateLayoutBuilderFlat {
        guard let coverImageHeightMultilpyer = config.mainImageRelativeHeight else {
            throw AdaptyUIError.componentNotFound("main_image_relative_height")
        }

        let style = try config.extractDefaultStyle()
        
        return .init(background: try style.background,
                     contentShape: try style.contentShape,
                     coverImage: try style.coverImageShape,
                     coverImageHeightMultilpyer: coverImageHeightMultilpyer,
                     titleRows: style.titleRows,
                     featuresBlock: style.featureBlock,
                     productsBlock: style.productBlock,
                     purchaseButton: try style.purchaseButton,
                     footerBlock: style.footerBlock,
                     closeButton: try style.closeButton,
                     initialProducts: products)
    }

    static func createLayoutFromConfiguration(_ viewConfiguration: AdaptyUI.LocalizedViewConfiguration,
                                              products: [ProductInfoModel]) throws -> LayoutBuilder {
        switch viewConfiguration.templateId {
        case "basic":
            return try createBasic(config: viewConfiguration, products: products)
        case "transparent":
            return try createTransparent(config: viewConfiguration, products: products)
        case "flat":
            return try createFlat(config: viewConfiguration, products: products)
        default:
            throw AdaptyUIError.unsupportedTemplate(viewConfiguration.templateId)
        }
    }
}
