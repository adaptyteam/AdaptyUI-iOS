//
//  Style+ProductsBlock.swift
//
//
//  Created by Alexey Goncharov on 14.8.23..
//

import Adapty
import Foundation

extension AdaptyUI {
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

extension AdaptyUI.ProductObject {
    func toProductInfo(id: String) -> AdaptyUI.ProductInfo? {
        .init(
            id: id,
            title: properties["title"]?.asText,
            subtitle: properties["subtitle"]?.asText,
            subtitlePayAsYouGo: properties["subtitle_payasyougo"]?.asText,
            subtitlePayUpFront: properties["subtitle_payupfront"]?.asText,
            subtitleFreeTrial: properties["subtitle_freetrial"]?.asText,
            secondTitle: properties["second_title"]?.asText,
            secondSubitle: properties["second_subtitle"]?.asText,
            button: properties["button"]?.asButton,
            tagText: properties["tag_text"]?.asText,
            tagShape: properties["tag_shape"]?.asShape
        )
    }
}
