//
//  AdaptyShowcaseController.swift
//
//
//  Created by Alexey Goncharov on 27.6.23..
//

import Adapty
import UIKit

extension Mock.Text {
    static func body(_ value: String, _ color: UIColor = .darkText) -> Mock.Text {
        .init(value: value, uiFont: .systemFont(ofSize: 15.0), uiColor: color)
    }
}

extension Mock.Shape {
    static var defaultRect: Mock.Shape {
        .init(background: .color(Mock.Color(.lightGray)),
              mask: .rect,
              rectCornerRadius: 0.0)
    }

    static var roundedRect: Mock.Shape {
        .init(background: .color(Mock.Color(.blue)),
              mask: .rect,
              rectCornerRadius: 16.0)
    }
    
    static var circle: Mock.Shape {
        .init(background: .color(Mock.Color(.orange)),
              mask: .circle,
              rectCornerRadius: 0.0)
    }
    
    static var closeImage: Mock.Shape {
        .init(background: .image(UIImage(systemName: "xmark.circle.fill")!),
              mask: .circle,
              rectCornerRadius: 0.0)
    }
}

extension Mock.Button {
    static var continueButton1: Mock.Button {
        .init(shape: .defaultRect,
              text: .body("Continue", .white),
              align: .fill)
    }

    static var continueButton2: Mock.Button {
        .init(shape: .roundedRect,
              text: .body("Continue", .white),
              align: .fill)
    }
    
    static var circleTextButton: Mock.Button {
        .init(shape: .circle,
              text: .body("Hey", .white),
              align: .center)
    }
    
    static var closeButton: Mock.Button {
        .init(shape: .closeImage,
              text: nil,
              align: .leading)
    }
}

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
    }

    private func buildInterface() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        view.addConstraints([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24.0),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24.0),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
        
        let button1 = AdaptyButtonComponentView(component: Mock.Button.continueButton1) {
            print("button pressed")
        }
        
        let button2 = AdaptyButtonComponentView(component: Mock.Button.continueButton2) {
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
        stackView.addArrangedSubview(button3)
        stackView.addArrangedSubview(button4)
        
        stackView.addConstraint(button1.heightAnchor.constraint(equalToConstant: 58.0))
        stackView.addConstraint(button2.heightAnchor.constraint(equalToConstant: 58.0))
        stackView.addConstraint(button3.heightAnchor.constraint(equalToConstant: 100.0))
        stackView.addConstraint(button3.widthAnchor.constraint(equalToConstant: 100.0))
        stackView.addConstraint(button4.heightAnchor.constraint(equalToConstant: 64.0))
        stackView.addConstraint(button4.widthAnchor.constraint(equalToConstant: 64.0))
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
