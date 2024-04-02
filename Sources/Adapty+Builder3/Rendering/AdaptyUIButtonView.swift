//
//  AdaptyUIButtonView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

import Adapty
import SwiftUI

struct AdaptyUIButtonView: View {
    var button: AdaptyUI.Button
    var properties: AdaptyUI.Element.Properties?

    init(_ button: AdaptyUI.Button, _ properties: AdaptyUI.Element.Properties?) {
        self.button = button
        self.properties = properties
    }

    var body: some View {
        Button(action: {}, label: {
            Text("Button")
        })
    }
}
