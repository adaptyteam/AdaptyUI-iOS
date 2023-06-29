//
//  AdaptyShowcaseController.swift
//
//
//  Created by Alexey Goncharov on 27.6.23..
//

import Adapty
import UIKit

public final class AdaptyShowcaseController: UIViewController {
    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        buildInterface()

//        experiment()
    }

    private weak var contentView: AdaptyBaseContentView!

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        contentView.updateSafeArea(view.safeAreaInsets)
    }

    private func buildInterface() {
        let image = UIImage(named: "background")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill

        view.addSubview(imageView)
        view.addConstraints([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let scrollView = AdaptyBaseScrollView()
        scrollView.backgroundColor = .clear

        AdaptyInterfaceBilder.layoutScrollView(scrollView, on: view)

        let contentView = AdaptyBaseContentView(
//            layout: .basic(multiplier: 0.45),
//            shape: Mock.Shape.roundedRectGradient
//            layout: .transparent,
//            shape: Mock.Shape.transparent
            layout: .flat,
            shape: Mock.Shape.defaultRect
        )

        AdaptyInterfaceBilder.layoutContentView(contentView, on: scrollView)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 64.0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.layoutContent(stackView, inset: UIEdgeInsets(top: 48,
                                                                 left: 24,
                                                                 bottom: 24,
                                                                 right: 24))

        let button1 = AdaptyButtonComponentView(component: Mock.Button.continueButton1) {
            print("button pressed")
        }

        let button2 = AdaptyButtonComponentView(component: Mock.Button.continueButton2) {
            print("button pressed")
        }

        let button5 = AdaptyButtonComponentView(component: Mock.Button.continueButton3) {
            print("button pressed")
        }

        let button3 = AdaptyButtonComponentView(component: Mock.Button.circleTextButton) {
            print("button pressed")
        }

        let button4 = AdaptyButtonComponentView(component: Mock.Button.closeButton) {
            print("button pressed")
        }

        stackView.addArrangedSubview(button1)
        stackView.addArrangedSubview(button2)
        stackView.addArrangedSubview(button5)
        stackView.addArrangedSubview(button3)
        stackView.addArrangedSubview(button4)

        stackView.addConstraint(button1.heightAnchor.constraint(equalToConstant: 58.0))
        stackView.addConstraint(button2.heightAnchor.constraint(equalToConstant: 58.0))
        stackView.addConstraint(button5.heightAnchor.constraint(equalToConstant: 58.0))
        stackView.addConstraint(button3.heightAnchor.constraint(equalToConstant: 100.0))
        stackView.addConstraint(button3.widthAnchor.constraint(equalToConstant: 100.0))
        stackView.addConstraint(button4.heightAnchor.constraint(equalToConstant: 64.0))
        stackView.addConstraint(button4.widthAnchor.constraint(equalToConstant: 64.0))

        self.contentView = contentView
    }

    private func layoutStackView(
        _ stackView: UIStackView,
        on superview: UIView
    ) -> (NSLayoutConstraint, NSLayoutConstraint) {
        let contentTopConstraint = stackView.topAnchor.constraint(equalTo: superview.topAnchor)
        let contentBottomConstraint = stackView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)

        superview.addSubview(stackView)
        superview.addConstraints([
            stackView.leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor, constant: 24.0),
            stackView.trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor, constant: -24.0),
            contentTopConstraint,
            contentBottomConstraint,
        ])

        return (contentTopConstraint, contentBottomConstraint)
    }
}

extension UIView {
    func layoutButton(
        _ component: AdaptyButtonComponentView
    ) {
        addSubview(component)
        addConstraints([
            component.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24.0),
            component.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24.0),
            component.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16.0),
            component.heightAnchor.constraint(equalToConstant: 58.0),
        ])
    }
}
