//
//  ViewController.swift
//  AdaptyUIDemo
//
//  Created by Alexey Goncharov on 30.1.23..
//

import Adapty
import AdaptyUI
import UIKit

class ViewController: UIViewController {
    @IBOutlet var textField: UITextField!

    @IBOutlet var spinner: UIActivityIndicatorView!

    @IBOutlet var paywallInfoContainer: UIStackView!
    @IBOutlet var isVisualImageView: UIImageView!
    @IBOutlet var variationLabel: UILabel!
    @IBOutlet var revisionLabel: UILabel!
    @IBOutlet var localeLabel: UILabel!
    @IBOutlet var presentButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: remove
        textField.text = "volkswagen"

        spinner.isHidden = true
//        updatePaywallData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        loadPaywallPressed(self)
        
        let vc = AdaptyShowcaseController()
        vc.modalPresentationStyle = .overFullScreen
        
        present(vc, animated: false)
    }

    private var paywall: AdaptyPaywall?
    private var viewConfiguration: AdaptyUI.ViewConfiguration?

    private func setInProgress(_ inProgress: Bool) {
        spinner.isHidden = !inProgress

        if inProgress {
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
        }
    }

    private func updatePaywallData() {
        guard let paywall = paywall else {
            paywallInfoContainer.isHidden = true
            return
        }

        isVisualImageView.tintColor = paywall.hasViewConfiguration ? .systemGreen : .systemRed
        variationLabel.text = paywall.variationId
        revisionLabel.text = "\(paywall.revision)"
        localeLabel.text = paywall.locale
        presentButton.isEnabled = paywall.hasViewConfiguration
        paywallInfoContainer.isHidden = false
    }

    private func presentErrorAlert(_ error: AdaptyError) {
        let alert = UIAlertController(title: "Error!",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default))

        present(alert, animated: true)
    }

    private func presentPaywall(_ paywall: AdaptyPaywall,
                                products: [AdaptyPaywallProduct]?,
                                viewConfiguration: AdaptyUI.ViewConfiguration) {
        let vc = AdaptyUI.paywallController(
            for: paywall,
            products: products,
            viewConfiguration: viewConfiguration,
            delegate: self,
            productsTitlesResolver: { $0.vendorProductId }
        )

        present(vc, animated: true)
    }

    @IBAction func loadPaywallPressed(_ sender: Any) {
        guard let paywallId = textField.text, !paywallId.isEmpty else { return }

        setInProgress(true)

        Adapty.getPaywall(paywallId) { [weak self] result in
            self?.setInProgress(false)

            switch result {
            case let .success(paywall):
                self?.paywall = paywall
                self?.updatePaywallData()
            case let .failure(error):
                self?.presentErrorAlert(error)
            }
        }
    }

    @IBAction func presentPaywallPressed(_ sender: Any) {
        guard let paywall = paywall else { return }
        
        let vc = AdaptyUI.paywallControllerTest(
            for: paywall,
//            products: nil,
//            viewConfiguration: viewConfiguration,
            delegate: self
//            productsTitlesResolver: { $0.vendorProductId }
        )

        present(vc, animated: true)

//        setInProgress(true)
//
//        AdaptyUI.getViewConfiguration(forPaywall: paywall) { [weak self] result in
//            self?.setInProgress(false)
//
//            switch result {
//            case let .success(viewConfiguration):
//                self?.presentPaywall(paywall, products: nil, viewConfiguration: viewConfiguration)
//            case let .failure(error):
//                self?.presentErrorAlert(error)
//            }
//        }
    }
}

extension ViewController: AdaptyPaywallControllerDelegate {
    public func paywallControllerDidPressCloseButton(_ controller: AdaptyPaywallController) {
        print("#ExampleUI# paywallControllerDidPressCloseButton")
        controller.dismiss(animated: true)
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFinishRestoreWith profile: AdaptyProfile) {
        print("#ExampleUI# didFinishRestoreWith")

        if profile.accessLevels["premium"]?.isActive ?? false {
            controller.dismiss(animated: true)
        }
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailRestoreWith error: AdaptyError) {
        print("#ExampleUI# didFailRestoreWith \(error)")
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didCancelPurchase product: AdaptyPaywallProduct) {
        print("#ExampleUI# paywallControllerDidCancelPurchase")
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFinishPurchase product: AdaptyPaywallProduct,
                                  purchasedInfo: AdaptyPurchasedInfo) {
        print("#ExampleUI# didFinishPurchase")

        controller.dismiss(animated: true)
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailPurchase product: AdaptyPaywallProduct,
                                  error: AdaptyError) {
        print("#ExampleUI# didFailPurchaseWith \(error)")
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailRenderingWith error: AdaptyError) {
        print("#ExampleUI# didFailRenderingWith \(error)")
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailLoadingProductsWith error: AdaptyError) -> Bool {
        print("#ExampleUI# didFailLoadingProductsWith \(error)")
        return false
    }
}
