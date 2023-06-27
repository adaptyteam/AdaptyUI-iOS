//
//  AdaptyMainInfoComponent.swift
//
//
//  Created by Alexey Goncharov on 2023-01-19.
//

import Adapty
import UIKit

class AdaptyMainInfoComponent: UIStackView {
    private let title: AdaptyUI.Text
    private let textRows: AdaptyUI.TextRows
    private let imageColor: UIColor

    init(title: AdaptyUI.Text, textRows: AdaptyUI.TextRows, imageColor: UIColor) {
        self.title = title
        self.textRows = textRows
        self.imageColor = imageColor

        super.init(frame: .zero)

        setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private weak var titleLabel: UILabel!
    private weak var featuresList: AdaptyTextRowsComponent!

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        spacing = 16.0
        alignment = .fill

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title.value
        titleLabel.backgroundColor = .clear
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.font = title.uiFont
        titleLabel.textColor = title.color?.uiColor ?? .darkText

        let featuresList = AdaptyTextRowsComponent(textRows: textRows, imageColor: imageColor)

        self.titleLabel = titleLabel
        self.featuresList = featuresList

        addArrangedSubview(titleLabel)
        addArrangedSubview(featuresList)
    }
}
