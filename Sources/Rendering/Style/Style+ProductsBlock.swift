//
//  Style+ProductsBlock.swift
//
//
//  Created by Alexey Goncharov on 14.8.23..
//

import Adapty

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
            secondSubitle: customObject.properties["second_subtitle"]?.asText
        )
    }

    var asProductsInfos: AdaptyUI.ProductsInfos? {
        guard
            case let .object(customObject) = self,
            customObject.type == "products_infos"
        else { return nil }

        return customObject.orderedProperties.compactMap { $0.value.toProductInfo(id: "123") }
//        var infos = [String: AdaptyUI.ProductInfo]()
//
//        for (key, value) in customObject.properties {
//            guard let productInfo = value.toProductInfo(id: key) else { continue }
//            infos[key] = productInfo
//        }
//
//        return infos
    }
}

extension AdaptyUI.ProductsBlock {
    var button: AdaptyUI.Button {
        get throws {
            guard let result = items["button"]?.asButton else {
                throw AdaptyUIError.componentNotFound("button")
            }
            return result
        }
    }

    var productsInfos: AdaptyUI.ProductsInfos {
        get throws {
            guard let result = items["infos"]?.asProductsInfos else {
                throw AdaptyUIError.componentNotFound("infos")
            }
            return result
        }
    }

    var mainProductTagShape: AdaptyUI.Shape? {
        items["main_product_tag_shape"]?.asShape
    }

    var mainProductTagText: AdaptyUI.CompoundText? {
        items["main_product_tag_text"]?.asText
    }
}
