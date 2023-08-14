//
//  Style+TemplateBasic.swift
//
//
//  Created by Alexey Goncharov on 14.8.23..
//

import Adapty

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
