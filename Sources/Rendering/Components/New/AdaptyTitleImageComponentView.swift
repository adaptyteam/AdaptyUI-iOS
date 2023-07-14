//
//  AdaptyTitleImageComponentView.swift
//  
//
//  Created by Alexey Goncharov on 14.7.23..
//

import UIKit
import Adapty

final class AdaptyTitleImageComponentView: UIImageView {
    let shape: AdaptyUI.Shape
    
    init(shape: AdaptyUI.Shape) {
        self.shape = shape
        
        super.init(frame: .zero)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .scaleAspectFill
        clipsToBounds = true
        
        switch shape.background {
        case .image(let img):
            image = img.uiImage
        case .color(let color):
            backgroundColor = color.uiColor
        case .colorLinearGradient(let gradient):
            backgroundColor = gradient.items.first?.color.uiColor
        case .none:
            backgroundColor = .clear
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        updateShapeMask(shape.type)
        updateShapeBorder(shape.border)
    }
    
    private func updateShapeBorder(_ border: AdaptyUI.Shape.Border?) {
        layer.borderColor = border?.filling.asColor?.uiColor.cgColor
        layer.borderWidth = border?.thickness ?? 0.0
    }

    private func updateShapeMask(_ type: AdaptyUI.ShapeType?) {
        guard let type else {
            backgroundColor = .clear
            layer.mask = nil
            return
        }

        switch type {
        case let .rectangle(cornerRadius):
            // TODO: support corners
            layer.cornerRadius = cornerRadius.value ?? 0.0
        case .circle:
            layer.mask = CAShapeLayer.circleLayer(in: bounds)
            layer.mask?.backgroundColor = UIColor.clear.cgColor
            break
        default:
            break
        }
    }
}
