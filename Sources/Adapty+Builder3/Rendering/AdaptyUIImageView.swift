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

    init(_ image: AdaptyUI.Image) {
        self.image = image
    }

    var body: some View {
        switch image.asset {
        case let .raster(data):
            if let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                EmptyView()
            }
        case let .url(url, preview):
            if #available(iOS 14.0, *) {
                KFImage
                    .url(url)
                    .resizable()
                    .fade(duration: 0.25)
                    .placeholder {
                        if let preview, let uiImage = UIImage(data: preview) {
                            Image(uiImage: uiImage)
                        } else {
                            EmptyView()
                        }
                    }
            } else {
                // TODO: implement AsyncImage logic
                if let preview, let uiImage = UIImage(data: preview) {
                    Image(uiImage: uiImage)
                } else {
                    EmptyView()
                }
            }
        case .none:
            EmptyView()
        }
    }
}
