//
//  AdaptyPaywallPresenter.swift
//
//
//  Created by Alexey Goncharov on 2023-01-24.
//

import Adapty
import Combine
import Foundation

protocol AdaptyPaywallPresenterDelegate: NSObject {
    func didFailLoadingProducts(with error: AdaptyError) -> Bool
}

class AdaptyPaywallPresenter {
    fileprivate let logId: String
    private let queue = DispatchQueue(label: "AdaptyUI.SDK.PaywallPresenterQueue")

    let paywall: AdaptyPaywall

    weak var delegate: AdaptyPaywallPresenterDelegate?

    @Published var viewConfiguration: AdaptyUI.LocalizedViewConfiguration
    @Published var products: [AdaptyPaywallProduct]?
    @Published var introductoryOffersEligibilities: [String : AdaptyEligibility]?
    @Published var selectedProduct: AdaptyPaywallProduct?
    @Published var productsFetchingInProgress: Bool = false
    @Published var purchaseInProgress: Bool = false
    @Published var restoreInProgress: Bool = false

    private var cancellable = Set<AnyCancellable>()

    var onPurchase: ((AdaptyResult<AdaptyPurchasedInfo>, AdaptyPaywallProduct) -> Void)?
    var onRestore: ((AdaptyResult<AdaptyProfile>) -> Void)?

    public init(
        logId: String,
        paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]?,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration
    ) {
        self.logId = logId
        self.paywall = paywall
        self.products = products
        self.viewConfiguration = viewConfiguration

        selectedProduct = products?.first
    }

    func selectProduct(id: String) {
        log(.verbose, "select product: \(id)")
        selectedProduct = products?.first(where: { $0.vendorProductId == id })
    }

    func logShowPaywall() {
        log(.verbose, "logShowPaywall begin")

        AdaptyUI.logShowPaywall(paywall,
                                viewConfiguration: viewConfiguration) { [weak self] error in
            if let error = error {
                self?.log(.error, "logShowPaywall fail: \(error)")
            } else {
                self?.log(.verbose, "logShowPaywall success")
            }
        }
    }

    func makePurchase() {
        guard let selectedProduct = selectedProduct else { return }

        log(.verbose, "makePurchase begin")

        purchaseInProgress = true
        Adapty.makePurchase(product: selectedProduct) { [weak self] result in
            self?.onPurchase?(result, selectedProduct)
            self?.purchaseInProgress = false

            switch result {
            case .success:
                self?.log(.verbose, "makePurchase success")
            case let .failure(error):
                self?.log(.error, "makePurchase fail: \(error)")
            }
        }
    }

    func restorePurchases() {
        log(.verbose, "restorePurchases begin")

        restoreInProgress = true
        Adapty.restorePurchases { [weak self] result in
            self?.onRestore?(result)
            self?.restoreInProgress = false

            switch result {
            case .success:
                self?.log(.verbose, "restorePurchases success")
            case let .failure(error):
                self?.log(.error, "restorePurchases fail: \(error)")
            }
        }
    }

    // MARK: - Products Fetching

    func loadProductsIfNeeded() {
        guard !productsLoadingInProgress else { return }

        guard products != nil, introductoryOffersEligibilities == nil else {
            loadProducts()
            return
        }

        loadProductsIntroductoryEligibilities()
    }

    private var productsLoadingInProgress = false

    private func loadProducts() {
        productsLoadingInProgress = true

        log(.verbose, "loadProducts begin")

        queue.async { [weak self] in
            guard let self = self else { return }

            Adapty.getPaywallProducts(paywall: self.paywall) { [weak self] result in
                switch result {
                case let .success(products):
                    self?.log(.verbose, "loadProducts success")

                    self?.products = products

                    if self?.selectedProduct == nil {
                        self?.selectedProduct = products.first
                    }

                    self?.productsLoadingInProgress = false
                    self?.loadProductsIntroductoryEligibilities()
                case let .failure(error):
                    self?.log(.error, "loadProducts fail: \(error)")
                    self?.productsLoadingInProgress = false

                    if self?.delegate?.didFailLoadingProducts(with: error) ?? false {
                        self?.queue.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
                            self?.loadProducts()
                        }
                    }
                }
            }
        }
    }
    
    private func loadProductsIntroductoryEligibilities() {
        guard let products = products else { return  }
        
        Adapty.getProductsIntroductoryOfferEligibility(products: products) { [weak self] result in
            self?.introductoryOffersEligibilities = try? result.get()
        }
    }
}

extension AdaptyPaywallPresenter {
    func log(_ level: AdaptyLogLevel, _ message: String) {
        AdaptyUI.writeLog(level: level, message: "#\(logId)# \(message)")
    }
}
