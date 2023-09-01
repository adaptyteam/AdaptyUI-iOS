//
//  Style+ProductsBlock.swift
//
//
//  Created by Alexey Goncharov on 14.8.23..
//

import Adapty
import Foundation

extension AdaptyUI {
    typealias ProductsInfos = [ProductInfo]

    struct ProductInfo {
        let id: String
        let title: AdaptyUI.CompoundText?

        let subtitle: AdaptyUI.CompoundText?
        let subtitlePayAsYouGo: AdaptyUI.CompoundText?
        let subtitlePayUpFront: AdaptyUI.CompoundText?
        let subtitleFreeTrial: AdaptyUI.CompoundText?

        let secondTitle: AdaptyUI.CompoundText?
        let secondSubitle: AdaptyUI.CompoundText?

        let button: AdaptyUI.Button?
        let tagText: AdaptyUI.CompoundText?
        let tagShape: AdaptyUI.Shape?
    }
}

extension AdaptyUI.LocalizedViewItem {
    func toProductInfo(id: String) -> AdaptyUI.ProductInfo? {
        guard
            case let .object(customObject) = self,
            customObject.type == "product_info"
        else { return nil }

        return .init(
            id: id,
            title: customObject.properties["title"]?.asText,
            subtitle: customObject.properties["subtitle"]?.asText,
            subtitlePayAsYouGo: customObject.properties["subtitle_payasyougo"]?.asText,
            subtitlePayUpFront: customObject.properties["subtitle_payupfront"]?.asText,
            subtitleFreeTrial: customObject.properties["subtitle_freetrial"]?.asText,
            secondTitle: customObject.properties["second_title"]?.asText,
            secondSubitle: customObject.properties["second_subtitle"]?.asText,
            button: customObject.properties["button"]?.asButton,
            tagText: customObject.properties["tag_text"]?.asText,
            tagShape: customObject.properties["tag_shape"]?.asShape
        )
    }

    var asProductsInfos: AdaptyUI.ProductsInfos? {
        guard
            case let .object(customObject) = self,
            customObject.type == "products_infos"
        else { return nil }

        return customObject.orderedProperties.compactMap { $0.value.toProductInfo(id: "123") }
    }
}

extension AdaptyUI.ProductsBlock {
    var productsInfos: AdaptyUI.ProductsInfos {
        get throws {
            guard let result = items["infos"]?.asProductsInfos else {
                throw AdaptyUIError.componentNotFound("infos")
            }
            return result
        }
    }
}
