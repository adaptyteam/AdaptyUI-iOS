//
//  AdaptyUI+StyleExtractor.swift
//
//
//  Created by Alexey Goncharov on 2023-01-23.
//

import Adapty
import Foundation

extension AdaptyUI.LocalizedViewConfiguration {
    func extractStyle(_ id: String) throws -> AdaptyUI.LocalizedViewStyle {
        guard let style = styles[id] else {
            throw AdaptyUIError.styleNotFound(id)
        }
        return style
    }
}

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

// TODO: remove
extension AdaptyUI.LocalizedViewStyle {
    func extractCommonComponent(_ id: String) throws -> AdaptyUI.LocalizedViewItem {
        throw AdaptyUIError.componentNotFound(id)
    }

    private func extractCustomComponent(_ id: String) throws -> AdaptyUI.LocalizedViewItem {
        throw AdaptyUIError.componentNotFound(id)
    }

    func commonImage(id: String) throws -> AdaptyUI.Image {
        let comp = try extractCommonComponent(id)
        if let value = comp.asImage {
            return value
        } else {
            throw AdaptyUIError.wrongComponentType(id)
        }
    }

    func commonColor(id: String) throws -> AdaptyUI.Color {
        let comp = try extractCommonComponent(id)
        if let value = comp.asColor {
            return value
        } else {
            throw AdaptyUIError.wrongComponentType(id)
        }
    }

    // TODO: remove
    func commonText(id: String) throws -> AdaptyUI.Text {
//        let comp = try extractCommonComponent(id)
//        if let value = comp.asText {
//            return value
//        } else {
        throw AdaptyUIError.wrongComponentType(id)
//        }
    }

    // TODO: remove
    func customText(id: String) throws -> AdaptyUI.Text {
//        let comp = try extractCustomComponent(id)
//        if let value = comp.asText {
//            return value
//        } else {
        throw AdaptyUIError.wrongComponentType(id)
//        }
    }

    func customTextRows(id: String) throws -> AdaptyUI.СompoundText {
        let comp = try extractCustomComponent(id)
        if let value = comp.asText {
            return value
        } else {
            throw AdaptyUIError.wrongComponentType(id)
        }
    }
}

// TODO: Move this out
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
