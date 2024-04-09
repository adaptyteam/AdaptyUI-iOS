//
//  AdaptyUIImageView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

import Adapty
import SwiftUI

extension View {
    @ViewBuilder
    func aspectRatio(_ aspect: AdaptyUI.AspectRatio) -> some View {
        switch aspect {
        case .fit:
            aspectRatio(contentMode: .fit)
        case .fill:
            aspectRatio(contentMode: .fill)
        case .stretch:
            self
        }
    }
}

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
                    .aspectRatio(image.aspect)
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
                    .aspectRatio(image.aspect)
            } else {
                // TODO: implement AsyncImage logic
                if let preview, let uiImage = UIImage(data: preview) {
                    Image(uiImage: uiImage)
                        .aspectRatio(image.aspect)
                } else {
                    EmptyView()
                }
            }
        case .none:
            EmptyView()
        }
    }
}

@testable import Adapty

extension AdaptyUI.ImageData {
    static var urlDog: Self {
        .url(URL(string: "https://media.istockphoto.com/id/1411469044/photo/brown-dog-beagle-sitting-on-path-in-autumn-natural-park-location-among-orange-yellow-fallen.jpg?s=612x612&w=0&k=20&c=Ul6dwTVshdIYOACMbUEbA0WDiNbbTamtXL5GOL0KKK0=")!,
             previewRaster: nil)
    }
}

extension AdaptyUI.Image {
    static var test: Self {
        .init(asset: .urlDog,
              aspect: .fit,
              tint: nil)
    }
}

#Preview {
    AdaptyUIImageView(.test)
}
