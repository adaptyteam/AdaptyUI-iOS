//
//  Style+Common.swift
//  
//
//  Created by Alexey Goncharov on 1.9.23..
//

import Adapty
import Foundation

extension AdaptyUI.LocalizedViewStyle {
    var purchaseButtonOfferTitle: AdaptyUI.RichText? {
        items["purchase_button_intro_offer_title"]?.asText
    }
}
