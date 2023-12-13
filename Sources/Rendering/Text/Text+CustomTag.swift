//
//  Text+CustomTag.swift
//
//
//  Created by Alexey Goncharov on 1.12.23..
//

import Adapty
import Foundation

extension AdaptyUI.Text {
    typealias CustomTagConverter = (String) -> String?
}

extension String {
    private static let customTagPattern = "</[a-zA-Z_0-9-]+/>"

    private func removingCustomTagBrackets() -> Self {
        replacingOccurrences(of: "</", with: "")
            .replacingOccurrences(of: "/>", with: "")
    }

    func replaceCustomTags(converter: AdaptyUI.Text.CustomTagConverter) -> String {
        guard let regex = try? NSRegularExpression(pattern: Self.customTagPattern) else {
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
            let tag = String(matchTag).removingCustomTagBrackets()

            guard let replacement = converter(tag) else {
                result = result.replacingOccurrences(of: matchTag, with: "")
                continue
            }

            result = result.replacingOccurrences(of: matchTag, with: replacement)
        }

        return result
    }
}
