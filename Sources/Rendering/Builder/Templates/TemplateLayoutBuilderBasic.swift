//
//  TemplateLayoutBuilderBasic.swift
//
//
//  Created by Alexey Goncharov on 30.6.23..
//

import Adapty
import UIKit

extension AdaptyUI.Shape {
    fileprivate var recommendedContentOverlap: CGFloat {
        switch type {
        case let .rectangle(cornerRadius): return cornerRadius.value ?? 0.0
        case .curveUp, .curveDown: return AdaptyBaseContentView.curveHeight
        case .circle: return 0.0
        }
    }
}

class TemplateLayoutBuilderBasic: LayoutBuilder {
    private let coverImage: AdaptyUI.Image
    private let coverImageHeightMultilpyer: CGFloat
    private let contentShape: AdaptyUI.Shape
    private let titleRows: AdaptyUI.TextItems?
    private let featuresBlock: AdaptyUI.FeaturesBlock?
    private let productsBlock: AdaptyUI.ProductsBlock
    private let purchaseButton: AdaptyUI.Button
    private let closeButton: AdaptyUI.Button?

    private let scrollViewDelegate = AdaptyCoverImageScrollDelegate()

    init(
        coverImage: AdaptyUI.Image,
        coverImageHeightMultilpyer: CGFloat,
        contentShape: AdaptyUI.Shape,
        titleRows: AdaptyUI.TextItems?,
        featuresBlock: AdaptyUI.FeaturesBlock?,
        productsBlock: AdaptyUI.ProductsBlock,
        purchaseButton: AdaptyUI.Button,
        closeButton: AdaptyUI.Button?
    ) {
        self.coverImage = coverImage
        self.coverImageHeightMultilpyer = coverImageHeightMultilpyer
        self.contentShape = contentShape
        self.titleRows = titleRows
        self.featuresBlock = featuresBlock
        self.productsBlock = productsBlock
        self.purchaseButton = purchaseButton
        self.closeButton = closeButton
    }

    private weak var contentViewComponentView: AdaptyBaseContentView?
    private weak var closeButtonComponentView: AdaptyButtonComponentView?

    func onCloseButtonPressed(_ callback: @escaping () -> Void) {
        closeButtonComponentView?.onTap = callback
    }

    func buildInterface(on view: UIView) {
        let backgroundView = AdaptyBackgroundComponentView(background: nil)
        layoutBackground(backgroundView, on: view)

        let imageView = UIImageView(image: coverImage.uiImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        layoutCoverImageView(imageView, on: view, multiplier: coverImageHeightMultilpyer, minHeight: 300.0)
        scrollViewDelegate.coverView = imageView

        let scrollView = AdaptyBaseScrollView()
        scrollView.delegate = scrollViewDelegate

        AdaptyInterfaceBilder.layoutScrollView(scrollView, on: view)

        let contentView = AdaptyBaseContentView(
            layout: .basic(multiplier: coverImageHeightMultilpyer),
            shape: contentShape
        )

        layoutContentView(
            contentView,
            multiplier: coverImageHeightMultilpyer,
            overlap: contentShape.recommendedContentOverlap,
            on: scrollView
        )

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24.0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.layoutContent(stackView, inset: UIEdgeInsets(top: contentShape.recommendedContentOverlap,
                                                                 left: 24,
                                                                 bottom: 24,
                                                                 right: 24))

        if let titleRows {
            let titleRowsView = AdaptyTextItemsComponentView(textItems: titleRows)
            stackView.addArrangedSubview(titleRowsView)
        }
        
        if let featuresBlock {
            switch featuresBlock.type {
            case .list:
                guard let items = featuresBlock.items["list"]?.asTextItems else {
                    // TODO: throw an error
                    break
                }
                
                let featuresListView = AdaptyTextItemsComponentView(textItems: items)
                stackView.addArrangedSubview(featuresListView)
            case .timeline:
                guard let items = featuresBlock.items["timeline"]?.asTextItems else {
                    // TODO: throw an error
                    break
                }
                
                let featuresListView = AdaptyTextItemsComponentView(textItems: items)
                stackView.addArrangedSubview(featuresListView)
            }
        }
        
        if let productsView = try? AdaptyHorizontalProductsComponentView(productsBlock: productsBlock) {
            stackView.addArrangedSubview(productsView)
            
            // TODO: throw rendering error
        }
        
        let continueButtonView = AdaptyButtonComponentView(component: purchaseButton)
        stackView.addArrangedSubview(continueButtonView)
        stackView.addConstraint(
            continueButtonView.heightAnchor.constraint(equalToConstant: 58.0)
        )

        contentViewComponentView = contentView

        if let component = closeButton {
            let closeButton = AdaptyButtonComponentView(component: component)

            layoutCloseButton(closeButton, on: view)
            closeButtonComponentView = closeButton
        }
    }

    func viewDidLayoutSubviews(_ view: UIView) {
        contentViewComponentView?.updateSafeArea(view.safeAreaInsets)
    }

    // MARK: - Layout

    private func layoutContentView(_ contentView: AdaptyBaseContentView,
                                   multiplier: CGFloat,
                                   overlap: CGFloat,
                                   on scrollView: UIScrollView) {
        scrollView.addSubview(contentView)

        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.backgroundColor = .clear

        scrollView.addSubview(spacerView)
        scrollView.addConstraints([
            spacerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            spacerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            spacerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            spacerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor,
                                               multiplier: multiplier),
        ])

        scrollView.addConstraints([
            contentView.topAnchor.constraint(equalTo: spacerView.bottomAnchor,
                                             constant: -overlap),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor,
                                                multiplier: 1.0 - multiplier,
                                                constant: overlap + 32.0),
        ])
    }
}
