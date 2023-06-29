//
//  CAShapeLayer+Extensions.swift
//
//
//  Created by Alexey Goncharov on 29.6.23..
//

import UIKit

extension CAShapeLayer {
    static func circleLayer(in rect: CGRect) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor

        let radius = min(rect.height, rect.width) / 2.0

        layer.path = UIBezierPath(arcCenter: .init(x: rect.midX, y: rect.midY),
                                  radius: radius,
                                  startAngle: 0.0,
                                  endAngle: .pi * 2.0,
                                  clockwise: true).cgPath

        return layer
    }

    static func curveUpShapeLayer(in rect: CGRect) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor

        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))

        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + 36.0))

        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + 36.0),
                          controlPoint: CGPoint(x: rect.midX, y: rect.minY))

//        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + 36.0))
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        layer.path = path.cgPath

        return layer
    }
    
    static func curveDownShapeLayer(in rect: CGRect) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor

        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))

        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                          controlPoint: CGPoint(x: rect.midX, y: rect.minY + 36.0))
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        layer.path = path.cgPath

        return layer
    }
}
