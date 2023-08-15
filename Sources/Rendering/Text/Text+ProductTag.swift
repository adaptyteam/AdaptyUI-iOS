//
//  Text+ProductTag.swift
//
//
//  Created by Alexey Goncharov on 15.8.23..
//

import Adapty
import Foundation

extension AdaptyUI.Text {
    typealias ProductTagConverter = (ProductTag) -> String?

    enum ProductTag: String {
        case price = "PRICE"

        static func fromRawMatch(_ match: String) -> ProductTag? {
            let cleanedMatch = match
                .replacingOccurrences(of: "</", with: "")
                .replacingOccurrences(of: "/>", with: "")

            return .init(rawValue: cleanedMatch)
        }
    }
}

extension String {
    func replaceAllTags(converter: AdaptyUI.Text.ProductTagConverter) -> String {
        guard let regex = try? NSRegularExpression(pattern: "</[a-zA-Z_0-9-]+/>") else {
            return self
        }

        var result = self
        var stop = false

        while !stop {
            let range = NSRange(result.startIndex ..< result.endIndex, in: result)

            guard let match = regex.firstMatch(in: result, range: range),
                  let matchRange = Range(match.range, in: result) else {
                stop = true
                break
            }

            let matchTag = result[matchRange]
            guard let tag = AdaptyUI.Text.ProductTag.fromRawMatch(String(matchTag)),
                  let replacement = converter(tag) else {
                result = result.replacingOccurrences(of: matchTag, with: "")
                continue
            }
            result = result.replacingOccurrences(of: matchTag, with: replacement)
        }

        return result
    }
}
