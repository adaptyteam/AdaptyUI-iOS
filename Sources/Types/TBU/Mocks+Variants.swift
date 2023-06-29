//
//  File.swift
//
//
//  Created by Alexey Goncharov on 29.6.23..
//

import UIKit

extension Mock.Color {
    static let blue = Mock.Color(.blue)
    static let red = Mock.Color(.red)
    static let white = Mock.Color(.white)
}

extension Mock.Text {
    static func body(_ value: String, _ color: UIColor = .darkText) -> Mock.Text {
        .init(value: value, uiFont: .systemFont(ofSize: 15.0), uiColor: color)
    }

    static func mediumBody(_ value: String, _ color: UIColor = .darkText) -> Mock.Text {
        .init(value: value, uiFont: .systemFont(ofSize: 20.0, weight: .bold), uiColor: color)
    }
}

extension Mock.LinearGradient {
    static var purple: Mock.LinearGradient {
        .init(startPoint: (0.0, 0.5),
              endPoint: (1.0, 0.5),
              values: [
                  (0.0, .red),
                  (0.5, .purple),
              ])
    }

    static var orange: Mock.LinearGradient {
        .init(startPoint: (0.0, 0.0),
              endPoint: (1.0, 1.0),
              values: [
                  (0.0, .yellow),
                  (1.0, .orange),
              ])
    }
    
    static var transparent: Mock.LinearGradient {
        .init(startPoint: (0.5, 0.0),
              endPoint: (0.5, 1.0),
              values: [
                (0.0, .clear),
                (1.0, .black),
              ])
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

    static var roundedRectGradient: Mock.Shape {
        .init(background: .gradient(Mock.LinearGradient.purple),
              mask: .rect,
              rectCornerRadius: 16.0)
    }

    static var circle: Mock.Shape {
        .init(background: .gradient(Mock.LinearGradient.orange),
              mask: .circle,
              rectCornerRadius: 0.0)
    }

    static var closeImage: Mock.Shape {
        .init(background: .image(UIImage(systemName: "xmark.circle.fill")!),
              mask: .circle,
              rectCornerRadius: 0.0)
    }

    static var curveUp: Mock.Shape {
        .init(background: .gradient(Mock.LinearGradient.orange),
              mask: .curveUp,
              rectCornerRadius: 0.0)
    }

    static var curveDown: Mock.Shape {
        .init(background: .color(Mock.Color.blue),
              mask: .curveDown,
              rectCornerRadius: 0.0)
    }
    
    static var transparent: Mock.Shape {
        .init(background: .gradient(Mock.LinearGradient.transparent),
              mask: .rect,
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

    static var continueButton3: Mock.Button {
        .init(shape: .roundedRectGradient,
              text: .body("Continue", .white),
              align: .fill)
    }

    static var circleTextButton: Mock.Button {
        .init(shape: .circle,
              text: .mediumBody("Test", .white),
              align: .center)
    }

    static var closeButton: Mock.Button {
        .init(shape: .closeImage,
              text: nil,
              align: .leading)
    }
}

