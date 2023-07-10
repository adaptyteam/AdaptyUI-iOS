//
//  AdaptyUI+StyleExtractor.swift
//
//
//  Created by Alexey Goncharov on 2023-01-23.
//

import Adapty
import Foundation

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

    func commonText(id: String) throws -> AdaptyUI.Text {
        let comp = try extractCommonComponent(id)
        if let value = comp.asText {
            return value
        } else {
            throw AdaptyUIError.wrongComponentType(id)
        }
    }
    
    func customText(id: String) throws -> AdaptyUI.Text {
        let comp = try extractCustomComponent(id)
        if let value = comp.asText {
            return value
        } else {
            throw AdaptyUIError.wrongComponentType(id)
        }
    }

    func customTextRows(id: String) throws -> AdaptyUI.TextItems {
        let comp = try extractCustomComponent(id)
        if let value = comp.asTextItems {
            return value
        } else {
            throw AdaptyUIError.wrongComponentType(id)
        }
    }
}
