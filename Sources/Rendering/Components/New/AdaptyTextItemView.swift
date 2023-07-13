//
//  AdaptyTextItemView.swift
//
//
//  Created by Alexey Goncharov on 2023-01-19.
//

import Adapty
import UIKit

extension AdaptyUI.HorizontalAlign {
    var textAlignment: NSTextAlignment {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        }
    }
}

class AdaptyTextItemView: UIStackView {
    private let text: AdaptyUI.Text

    init(text: AdaptyUI.Text) {
        self.text = text

        super.init(frame: .zero)

        axis = .horizontal
        spacing = 8.0
        alignment = .top
        translatesAutoresizingMaskIntoConstraints = false

        setupView()
        setupConstraints()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private weak var imageView: UIImageView?
    private weak var textLabel: UILabel!

    private func setupView() {
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.backgroundColor = .clear
        
        textLabel.attributedText = text.attributedString()
//        textLabel.text = text.value
//        textLabel.textAlignment = text.horizontalAlign.textAlignment
//        textLabel.textColor = text.fill?.asColor?.uiColor ?? .darkText
//        textLabel.font = text.font?.uiFont ?? .systemFont(ofSize: 14.0)
        textLabel.numberOfLines = 0
//        textLabel.backgroundColor = .red

//        if let bullet = text.bullet {
//            let imageView = UIImageView(image: bullet.uiImage)
//            imageView.translatesAutoresizingMaskIntoConstraints = false
//
//            addArrangedSubview(imageView)
//
//            self.imageView = imageView
//        }

        addArrangedSubview(textLabel)

        self.textLabel = textLabel
    }

    private func setupConstraints() {
        if let imageView {
            addConstraints([
                imageView.widthAnchor.constraint(equalToConstant: 16.0),
                imageView.heightAnchor.constraint(equalToConstant: 16.0),
            ])
        }
    }
}
