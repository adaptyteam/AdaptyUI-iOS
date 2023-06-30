//
//  AdaptyCoverImageScrollDelegate.swift
//  
//
//  Created by Alexey Goncharov on 2023-01-18.
//

import UIKit

class AdaptyCoverImageScrollDelegate: NSObject, UIScrollViewDelegate {
    var coverView: UIView?
    let maxOffset: CGFloat = 100.0

    private func modifyContentOffset(_ contentOffset: CGPoint) -> CGPoint {
        if contentOffset.y < -maxOffset {
            return CGPoint(x: contentOffset.x, y: -maxOffset)
        }
        
        if contentOffset.y > maxOffset {
            return CGPoint(x: contentOffset.x, y: maxOffset)
        }

        return contentOffset
    }

    private func modifyCoverViewTransform(_ contentOffset: CGPoint) {
        guard let coverView = coverView else { return }
        
        if contentOffset.y < 0.0 {
            let diff = abs(contentOffset.y)
            let scale = (coverView.bounds.size.height + 2.0 * diff) / coverView.bounds.size.height
            coverView.transform = .init(scaleX: scale, y: scale)
        } else if contentOffset.y > 0.0 {
            coverView.transform = .init(translationX: 0.0, y: -contentOffset.y / 2.0)
        } else {
            coverView.transform = .identity
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = modifyContentOffset(scrollView.contentOffset)
        modifyCoverViewTransform(contentOffset)
        scrollView.contentOffset = contentOffset
    }
}
