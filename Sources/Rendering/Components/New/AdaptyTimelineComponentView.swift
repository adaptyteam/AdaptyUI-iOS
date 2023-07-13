//
//  AdaptyTimelineComponentView.swift
//  
//
//  Created by Alexey Goncharov on 13.7.23..
//

import UIKit
import Adapty

extension AdaptyUI.FeaturesBlock {
    func getIcon(_ key: String) throws -> AdaptyUI.Image {
        guard let value = items[key]?.asImage else {
            throw AdaptyUIError.componentNotFound(key)
        }
        return value
    }
    
    func getText(_ key: String) throws -> AdaptyUI.TextItems {
        guard let value = items[key]?.asTextItems else {
            throw AdaptyUIError.componentNotFound(key)
        }
        return value
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
    
    private func createItemView(icon: AdaptyUI.Image, texts: AdaptyUI.TextItems) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4.0
        stack.alignment = .top
        
        let image = UIImageView(image: icon.uiImage)
        image.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(image)
        
        stack.addConstraints([
            image.widthAnchor.constraint(equalToConstant: 28),
            image.heightAnchor.constraint(equalToConstant: 28),
        ])
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.attributedText = texts.attributedString()
        
        stack.addArrangedSubview(label)
        
        return stack
    }
    
    private func setupView() throws {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        alignment = .fill
        distribution = .equalSpacing
        spacing = 4.0
        
        addArrangedSubview(createItemView(icon: try block.getIcon("start_icon"),
                                          texts: try block.getText("start_rows")))
        
        addArrangedSubview(createItemView(icon: try block.getIcon("reminder_icon"),
                                          texts: try block.getText("reminder_rows")))
        
        addArrangedSubview(createItemView(icon: try block.getIcon("finish_icon"),
                                          texts: try block.getText("finish_rows")))
    }
}
