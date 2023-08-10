//
//  AdaptyTimelineComponentView.swift
//
//
//  Created by Alexey Goncharov on 13.7.23..
//

import Adapty
import UIKit

extension AdaptyUI {
    struct TimelineEntry {
        let text: AdaptyUI.СompoundText
        let image: AdaptyUI.Image
        let gradient: AdaptyUI.ColorGradient
    }
}

extension AdaptyUI.LocalizedViewItem {
    var asTimelineEntry: AdaptyUI.TimelineEntry? {
        guard
            case let .object(customObject) = self,
            customObject.type == "timeline_entry",
            let text = customObject.properties["text"]?.asText,
            let image = customObject.properties["image"]?.asImage,
            let gradient = customObject.properties["gradient"]?.asColorGradient
        else { return nil }

        return .init(text: text, image: image, gradient: gradient)
    }
}

final class AdaptyTimelineEntrySideComponentView: UIView {
    let image: AdaptyUI.Image
    let gradient: AdaptyUI.ColorGradient

    init(image: AdaptyUI.Image,
         gradient: AdaptyUI.ColorGradient) throws {
        self.image = image
        self.gradient = gradient

        super.init(frame: .zero)
        try setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer?.frame = gradientView?.bounds ?? .zero
    }
    
    private var gradientView: UIView?
    private var gradientLayer: CAGradientLayer?
    
    private func setupView() throws {
        translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(data: image.data)
        
        let gradientView = UIView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        let gradientLayer = CAGradientLayer.create(gradient)
        gradientLayer.frame = gradientView.bounds
        gradientView.layer.addSublayer(gradientLayer)
        
        addSubview(gradientView)
        addSubview(imageView)

        addConstraints([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 28.0),
            
            gradientView.centerXAnchor.constraint(equalTo: centerXAnchor),
            gradientView.topAnchor.constraint(equalTo: imageView.centerYAnchor),
            gradientView.widthAnchor.constraint(equalToConstant: 3.0),
            gradientView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        self.gradientView = gradientView
        self.gradientLayer = gradientLayer
    }
}

final class AdaptyTimelineComponentView: UIStackView {
    let block: AdaptyUI.FeaturesBlock

    init(block: AdaptyUI.FeaturesBlock) throws {
        guard block.type == .timeline else {
            throw AdaptyUIError.wrongComponentType("type")
        }

        self.block = block

        super.init(frame: .zero)
        try setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createItemView(_ entry: AdaptyUI.TimelineEntry) throws -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8.0
        stack.alignment = .fill
        
        let sideView = try AdaptyTimelineEntrySideComponentView(image: entry.image, gradient: entry.gradient)
        stack.addArrangedSubview(sideView)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.attributedText = entry.text.attributedString(paragraph: .init(lineSpacing: 2.0))

        stack.addArrangedSubview(label)
        
        stack.addConstraint(sideView.widthAnchor.constraint(equalToConstant: 28.0))

        return stack
    }

    private func setupView() throws {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        alignment = .fill
        distribution = .equalSpacing
        spacing = 8.0

        let entries = block.orderedItems.compactMap { $0.value.asTimelineEntry }

        for entry in entries {
            addArrangedSubview(try createItemView(entry))
        }
    }
}
