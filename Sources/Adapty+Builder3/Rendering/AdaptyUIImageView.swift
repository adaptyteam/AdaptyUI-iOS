//
//  AdaptyUIImageView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

import Adapty
import SwiftUI

struct AdaptyUIImageView: View {
    var image: AdaptyUI.Image
    var properties: AdaptyUI.Element.Properties?

    init(_ image: AdaptyUI.Image, _ properties: AdaptyUI.Element.Properties?) {
        self.image = image
        self.properties = properties
    }

    var body: some View {
        Text("Image")
    }
}
