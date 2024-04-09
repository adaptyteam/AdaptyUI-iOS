//
//  AdaptyUIImageView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

import Adapty
import SwiftUI

struct AdaptyUIImageView: View {
    var image: AdaptyUI.ImageData
    
    var body: some View {
        switch image {
        case .raster(let data):
            if let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
            }
        case .url:
            EmptyView()
        case .none:
            EmptyView()
        }
    }
}
