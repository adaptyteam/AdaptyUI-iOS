//
//  AdaptyUIStackView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

import Adapty
import SwiftUI

struct AdaptyUIStackView: View {
    var stack: AdaptyUI.Stack
    var properties: AdaptyUI.Element.Properties?

    init(_ stack: AdaptyUI.Stack, _ properties: AdaptyUI.Element.Properties?) {
        self.stack = stack
        self.properties = properties
    }

    var body: some View {
        Text("Stack")
    }
}
