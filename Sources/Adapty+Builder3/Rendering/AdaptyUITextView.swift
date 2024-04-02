//
//  AdaptyUITextView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

import Adapty
import SwiftUI

struct AdaptyUITextView: View {
    var text: AdaptyUI.RichText
    var properties: AdaptyUI.Element.Properties?

    init(_ text: AdaptyUI.RichText, _ properties: AdaptyUI.Element.Properties?) {
        self.text = text
        self.properties = properties
    }

    var body: some View {
        Text("RichText")
    }
}
