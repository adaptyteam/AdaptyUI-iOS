//
//  AdaptyImageCache.swift
//
//
//  Created by Aleksey Goncharov on 11.3.24..
//

import Adapty
import Foundation

class AdaptyImageCache {
    
    static func chacheImagesIfNeeded(viewConfiguration: AdaptyUI.ViewConfiguration, locale: String) {
        let urls = viewConfiguration.extractImageUrls(locale)
        
        let prefetcher = ImagePrefetcher(sources: urls.map { .network($0) },
                                         options: .empty) { skippedSources, failedSources, completedSources in
            print("")
        }
        
        prefetcher.start()
    }
}
