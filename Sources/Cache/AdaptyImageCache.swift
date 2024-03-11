//
//  AdaptyImageCache.swift
//
//
//  Created by Aleksey Goncharov on 11.3.24..
//

import Adapty
import Foundation

public class AdaptyImageCache {
    static let manager = KingfisherManager(downloader: .default, cache: .default)

    static func chacheImagesIfNeeded(viewConfiguration: AdaptyUI.ViewConfiguration, locale: String) {
        let urls = viewConfiguration.extractImageUrls(locale)

        let prefetcher = ImagePrefetcher(sources: urls.map { .network($0) },
                                         options: .empty,
                                         manager: Self.manager) { _, _, _ in
            print("")
        }

        prefetcher.start()
    }
}

// TODO: move to tests
extension AdaptyImageCache {
    static let url1 = URL(string: "https://media.istockphoto.com/id/1267021092/photo/funny-winking-kitten.jpg?s=612x612&w=0&k=20&c=9PoFYkqKZ30F_ubxX90_azwsR22ENwrFnOjxV0RaoTo=")!

    static let url2 = URL(string: "https://i.pinimg.com/564x/08/cc/57/08cc57559adcbdf6d70426101511befb.jpg")!

    public static func runTest() {
        let prefetcher = ImagePrefetcher(sources: [url1, url2].map { .network($0) },
                                         options: .empty,
                                         manager: Self.manager) { skip, fail, complete in
            print("#TEST# skip: \(skip), fail: \(fail), complete: \(complete)")

            Self.checkImages()
        }

        prefetcher.start()
    }

    static func checkImages() {
        manager.retrieveImage(with: url1, options: .empty) { result in
            switch result {
            case let .success(imgResult):
                break
            case let .failure(error):
                break
            }
        }
    }
}
