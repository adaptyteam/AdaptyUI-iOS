//
//  AdaptyTextRowComponent.swift
//
//
//  Created by Alexey Goncharov on 2023-01-19.
//

import Adapty
import UIKit

class AdaptyTextRowComponent: UIStackView {
    private let textRows: AdaptyUI.TextRows
    private let textRow: AdaptyUI.TextRow
    private let imageColor: UIColor

    init(textRows: AdaptyUI.TextRows,
         index: Int,
         imageColor: UIColor) {
        self.textRows = textRows
        textRow = textRows.rows[index]
        self.imageColor = imageColor

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

    private weak var imageView: UIImageView!
    private weak var textLabel: UILabel!

    private func setupView() {
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.text = textRow.value
        textLabel.backgroundColor = .clear
        textLabel.textAlignment = .left
        textLabel.font = .systemFont(ofSize: 14, weight: .medium)
        textLabel.textColor = textRow.color?.uiColor ?? .darkText
        textLabel.font = textRows.font?.uiFont(overrideSize: textRow.size)
        textLabel.numberOfLines = 0

        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = imageColor

        addArrangedSubview(imageView)
        addArrangedSubview(textLabel)

        self.imageView = imageView
        self.textLabel = textLabel
    }

    private func setupConstraints() {
        addConstraints([
            imageView.widthAnchor.constraint(equalToConstant: 16.0),
            imageView.heightAnchor.constraint(equalToConstant: 16.0),
        ])
    }
}
