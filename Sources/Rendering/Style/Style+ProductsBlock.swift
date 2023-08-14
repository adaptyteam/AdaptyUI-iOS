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

    var mainProductTagBackground: AdaptyUI.Color? {
        items["main_product_tag_background"]?.asColor
    }

    var mainProductTagText: AdaptyUI.СompoundText? {
        items["main_product_tag_text"]?.asText
    }

    var productTitle: AdaptyUI.СompoundText {
        get throws {
            guard let result = items["product_title"]?.asText else {
                throw AdaptyUIError.componentNotFound("product_title")
            }
            return result
        }
    }

    var productOffer: AdaptyUI.СompoundText {
        get throws {
            guard let result = items["product_offer"]?.asText else {
                throw AdaptyUIError.componentNotFound("product_offer")
            }
            return result
        }
    }

    var productPrice: AdaptyUI.СompoundText {
        get throws {
            guard let result = items["product_price"]?.asText else {
                throw AdaptyUIError.componentNotFound("product_price")
            }
            return result
        }
    }

    var productPriceCalculated: AdaptyUI.СompoundText {
        get throws {
            guard let result = items["product_price_calculated"]?.asText else {
                throw AdaptyUIError.componentNotFound("product_price_calculated")
            }
            return result
        }
    }
}
