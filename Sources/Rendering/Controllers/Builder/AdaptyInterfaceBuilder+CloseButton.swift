//
//  AdaptyInterfaceBuilder+CloseButton.swift
//  
//
//  Created by Alexey Goncharov on 27.6.23..
//

import UIKit

struct AdaptyCloseButtonConfiguration {
    
}

extension AdaptyInterfaceBilder {
    static func buildCloseButton(
        on superview: UIView,
        onTap: @escaping () -> Void
    ) -> AdaptyCloseButton {
        let button = AdaptyCloseButton(onTap: onTap)
        
        superview.addSubview(button)
        superview.addConstraints([
            button.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 24.0),
            button.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: 16.0),
        ])
        
        return button
    }
}
