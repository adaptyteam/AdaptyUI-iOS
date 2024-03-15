//
//  Image+UIKit.swift
//
//
//  Created by Alexey Goncharov on 10.8.23..
//

import Adapty
import UIKit

extension UIImageView {
    func setImage(_ img: AdaptyUI.Image,
                  renderingMode: UIImage.RenderingMode = .automatic) {
        switch img {
        case let .raster(data):
            image = UIImage(data: data)?.withRenderingMode(renderingMode)
        case let .url(url, previewData):
            let previewImage: UIImage? = if let previewData { UIImage(data: previewData) } else { nil }

            kf.setImage(
                with: .network(url),
                placeholder: previewImage?.withRenderingMode(renderingMode),
                options: [
                    .targetCache(AdaptyUI.imageCache),
                    .downloader(AdaptyUI.imageDownloader),
                    .imageModifier(RenderingModeImageModifier(renderingMode: renderingMode)),
                ]
            )
        }
    }
}

extension UIButton {
    func setBackgroundImage(_ img: AdaptyUI.Image,
                            for state: UIControl.State,
                            renderingMode: UIImage.RenderingMode = .automatic) {
        switch img {
        case let .raster(data):
            setBackgroundImage(UIImage(data: data), for: state)
        case let .url(url, previewData):
            let previewImage: UIImage? = if let previewData { UIImage(data: previewData) } else { nil }

            kf.setBackgroundImage(
                with: .network(url),
                for: state,
                placeholder: previewImage?.withRenderingMode(renderingMode),
                options: [
                    .targetCache(AdaptyUI.imageCache),
                    .downloader(AdaptyUI.imageDownloader),
                    .imageModifier(RenderingModeImageModifier(renderingMode: renderingMode)),
                ]
            )
        }
    }
}
