//
//  AdaptyTemplateReader.swift
//
//
//  Created by Alexey Goncharov on 2023-01-23.
//

import Adapty
import Foundation

class AdaptyTemplateReader {
    private let logId: String
    private let templateId = "template_1"
    private let styleId = "default"
    private let configuration: AdaptyUI.LocalizedViewConfiguration
    private let style: AdaptyUI.LocalizedViewStyle

    init(logId: String, configuration: AdaptyUI.LocalizedViewConfiguration) throws {
        self.logId = logId

        guard configuration.templateId == templateId else {
            throw AdaptyUIError.unsupportedTemplate(configuration.templateId)
        }

        self.configuration = configuration

        guard let style = configuration.styles[styleId] else {
            throw AdaptyUIError.styleNotFound(styleId)
        }

        self.style = style
    }

    var showCloseButton: Bool { !configuration.isHard }

    func termsURL() -> URL? {
        nil
    }

    func privacyURL() -> URL? {
        nil
    }

    func colorMainAccent() throws -> AdaptyUI.Color {
        try style.commonColor(id: "accent_color0")
    }

    func colorSecondaryAccent() throws -> AdaptyUI.Color {
        try style.commonColor(id: "accent_color1")
    }

    func colorProductButtonBackground() throws -> AdaptyUI.Color {
        try style.commonColor(id: "product_background")
    }

    func colorProductTitle() throws -> AdaptyUI.Color {
        try style.commonColor(id: "product_title")
    }

    func colorProductSubtitle() throws -> AdaptyUI.Color {
        try style.commonColor(id: "product_secondary_title")
    }

    func colorProductPriceSubtitle() throws -> AdaptyUI.Color {
        try style.commonColor(id: "product_price_week")
    }

    func coverImage() throws -> AdaptyUI.Image {
        try style.commonImage(id: "cover_image")
    }

    func contentBackgroundColor() throws -> AdaptyUI.Color {
        try style.commonColor(id: "background")
    }

    func titleText() throws -> AdaptyUI.Text {
        try style.commonText(id: "title")
    }

    func featuresRows() throws -> AdaptyUI.СompoundText {
        try style.customTextRows(id: "features")
    }

    func textProductTag() throws -> AdaptyUI.Text {
        try style.customText(id: "main_product_tag_text")
    }

    func purchaseButtonText() throws -> AdaptyUI.Text {
        try style.commonText(id: "purchase_button_text")
    }

    func termsButtonText() throws -> AdaptyUI.Text {
        try style.commonText(id: "terms_button")
    }

    func privacyButtonText() throws -> AdaptyUI.Text {
        try style.commonText(id: "privacy_button")
    }

    func restoreButtonText() throws -> AdaptyUI.Text {
        try style.commonText(id: "restore_button")
    }
}
