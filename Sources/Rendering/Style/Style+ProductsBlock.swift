//
//  Style+ProductsBlock.swift
//
//
//  Created by Alexey Goncharov on 14.8.23..
//

import Adapty

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

    // TODO: remove
    var productTitle: AdaptyUI.CompoundText {
        get throws {
            guard let result = items["product_title"]?.asText else {
                throw AdaptyUIError.componentNotFound("product_title")
            }
            return result
        }
    }

    // TODO: remove
    var productOffer: AdaptyUI.CompoundText {
        get throws {
            guard let result = items["product_offer"]?.asText else {
                throw AdaptyUIError.componentNotFound("product_offer")
            }
            return result
        }
    }

    // TODO: remove
    var productPrice: AdaptyUI.CompoundText {
        get throws {
            guard let result = items["product_price"]?.asText else {
                throw AdaptyUIError.componentNotFound("product_price")
            }
            return result
        }
    }

    // TODO: remove
    var productPriceCalculated: AdaptyUI.CompoundText {
        get throws {
            guard let result = items["product_price_calculated"]?.asText else {
                throw AdaptyUIError.componentNotFound("product_price_calculated")
            }
            return result
        }
    }
}
