//
//  ImageDataProcessor.swift
//
//
//  Created by Aleksey Goncharov on 11.3.24..
//

import Foundation

private let sharedProcessingQueue: CallbackQueue =
    .dispatch(DispatchQueue(label: "com.onevcat.Kingfisher.ImageDownloader.Process"))

// Handles image processing work on an own process queue.
class ImageDataProcessor {
    let data: Data
    let callbacks: [SessionDataTask.TaskCallback]
    let queue: CallbackQueue

    // Note: We have an optimization choice there, to reduce queue dispatch by checking callback
    // queue settings in each option...
    let onImageProcessed = Delegate<(Result<KFCrossPlatformImage, KingfisherError>, SessionDataTask.TaskCallback), Void>()

    init(data: Data, callbacks: [SessionDataTask.TaskCallback], processingQueue: CallbackQueue?) {
        self.data = data
        self.callbacks = callbacks
        queue = processingQueue ?? sharedProcessingQueue
    }

    func process() {
        queue.execute(doProcess)
    }

    private func doProcess() {
        var processedImages = [String: KFCrossPlatformImage]()
        for callback in callbacks {
            let processor = callback.options.processor
            var image = processedImages[processor.identifier]
            if image == nil {
                image = processor.process(item: .data(data), options: callback.options)
                processedImages[processor.identifier] = image
            }

            let result: Result<KFCrossPlatformImage, KingfisherError>
            if let image = image {
                let finalImage = callback.options.backgroundDecode ? image.decoded : image
                result = .success(finalImage)
            } else {
                let error = KingfisherError.processorError(
                    reason: .processingFailed(processor: processor, item: .data(data)))
                result = .failure(error)
            }
            onImageProcessed.call((result, callback))
        }
    }
}
