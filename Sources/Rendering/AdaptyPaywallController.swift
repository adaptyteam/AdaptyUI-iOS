//
//  AdaptyPaywallController.swift
//
//
//  Created by Alexey Goncharov on 2023-01-17.
//

import Adapty
import Combine
import UIKit

public class AdaptyPaywallController: UIViewController {
    fileprivate let logId: String

    public let id = UUID()
    public var paywall: AdaptyPaywall { presenter.paywall }
    public var viewConfiguration: AdaptyUI.LocalizedViewConfiguration { presenter.viewConfiguration }

    public weak var delegate: AdaptyPaywallControllerDelegate?

    private let productsTitlesResolver: (AdaptyProduct) -> String
    private let scrollViewDelegate = AdaptyCoverImageScrollDelegate()
    private let presenter: AdaptyPaywallPresenter
    private var cancellable = Set<AnyCancellable>()

    init(
        paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]?,
        viewConfiguration: AdaptyUI.ViewConfiguration,
        delegate: AdaptyPaywallControllerDelegate,
        productsTitlesResolver: ((AdaptyProduct) -> String)?
    ) {
        let logId = AdaptyUI.generateLogId()

        AdaptyUI.writeLog(level: .verbose, message: "#Controller_\(logId)# init template: \(viewConfiguration.templateId), products: \(products?.count ?? 0)")

        self.logId = logId
        self.delegate = delegate
        self.productsTitlesResolver = productsTitlesResolver ?? { $0.localizedTitle }

        let localizedConfig = viewConfiguration.extractLocale(paywall.locale)

        presenter = AdaptyPaywallPresenter(logId: logId,
                                           paywall: paywall,
                                           products: products,
                                           viewConfiguration: localizedConfig)

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .fullScreen

        presenter.delegate = self
        presenter.loadProductsIfNeeded()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    deinit {
        log(.verbose, "deinit")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        log(.verbose, "viewDidLoad begin")

        subscribeForDataChange()
        subscribeForEvents()

        do {
            let reader = try AdaptyTemplateReader(logId: logId, configuration: presenter.viewConfiguration)
            try buildTemplateInterface(reader: reader)
        } catch {
            if let error = error as? AdaptyUIError {
                log(.error, "Rendering Error = \(error)")
                delegate?.paywallController(self, didFailRenderingWith: AdaptyError(error))
            } else {
                log(.error, "Unknown Rendering Error = \(error)")
                let adaptyError = AdaptyError(AdaptyUIError.rendering(error))
                delegate?.paywallController(self, didFailRenderingWith: adaptyError)
            }
        }

        presenter.logShowPaywall()
        log(.verbose, "viewDidLoad end")
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        log(.verbose, "viewDidAppear")
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        log(.verbose, "viewDidDisappear")
    }

    private func subscribeForDataChange() {
        presenter.$products
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                let selectedProductId = self?.presenter.selectedProduct?.vendorProductId
                self?.productsList?.updateProducts(value, selectedProductId: selectedProductId)
            }
            .store(in: &cancellable)
        
        presenter.$introductoryOffersEligibilities
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.productsList?.updateIntroEligibilities(value)
            }
            .store(in: &cancellable)

        presenter.$selectedProduct
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.updateSelectedProductId(value)
            }
            .store(in: &cancellable)

        presenter.$selectedProduct
            .receive(on: RunLoop.main)
            .dropFirst()
            .sink { [weak self] value in
                guard let self = self, let delegate = self.delegate, let product = value else {
                    return
                }

                delegate.paywallController(self, didSelectProduct: product)
            }
            .store(in: &cancellable)

        presenter.$purchaseInProgress
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.updatePurchaseInProgress(value)
            }
            .store(in: &cancellable)

        presenter.$restoreInProgress
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.updateGlobalLoadingIndicator(restoreInProgress: value, animated: true)
            }
            .store(in: &cancellable)
    }

    private func subscribeForEvents() {
        presenter.onPurchase = { [weak self] result, product in
            self?.handlePurchaseResult(result, product)
        }

        presenter.onRestore = { [weak self] result in
            self?.handleRestoreResult(result)
        }
    }

    private func handlePurchaseResult(_ result: AdaptyResult<AdaptyPurchasedInfo>,
                                      _ product: AdaptyPaywallProduct) {
        switch result {
        case let .success(info):
            delegate?.paywallController(self,
                                        didFinishPurchase: product,
                                        purchasedInfo: info)
        case let .failure(error):
            if error.adaptyErrorCode == .paymentCancelled {
                delegate?.paywallController(self, didCancelPurchase: product)
            } else if let alertDialog = delegate?.paywallController(
                self,
                buildDialogWith: .error(error),
                onDialogDismissed: { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.paywallController(self, didFailPurchase: product, error: error)
                }
            ) {
                present(alertDialog, animated: true)
            } else {
                delegate?.paywallController(self, didFailPurchase: product, error: error)
            }
        }
    }

    private func handleRestoreResult(_ result: AdaptyResult<AdaptyProfile>) {
        switch result {
        case let .success(profile):
            if let alertDialog = delegate?.paywallController(
                self,
                buildDialogWith: .restored,
                onDialogDismissed: { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.paywallController(self, didFinishRestoreWith: profile)
                }
            ) {
                present(alertDialog, animated: true)
            } else {
                delegate?.paywallController(self, didFinishRestoreWith: profile)
            }

        case let .failure(error):
            guard error.adaptyErrorCode != .paymentCancelled else { break }

            if let alertDialog = delegate?.paywallController(
                self,
                buildDialogWith: .error(error),
                onDialogDismissed: { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.paywallController(self, didFailRestoreWith: error)
                }
            ) {
                present(alertDialog, animated: true)
            } else {
                delegate?.paywallController(self, didFailRestoreWith: error)
            }
        }
    }

    private func updateSelectedProductId(_ product: AdaptyPaywallProduct?) {
        productsList?.updateSelectedState(product?.vendorProductId)
    }

    private func updatePurchaseInProgress(_ inProgress: Bool) {
        productsList?.isUserInteractionEnabled = !inProgress
        continueButton?.updateInProgress(inProgress)
    }

    private func updateGlobalLoadingIndicator(restoreInProgress: Bool, animated: Bool) {
        if restoreInProgress {
            loadingView?.show(animated: animated)
        } else {
            loadingView?.hide(animated: animated)
        }
    }

    // MARK: - Building

    private var loadingView: AdaptyActivityIndicatorView?
    private var coverImageGradient: AdaptyGradientViewComponent?
    private var closeButton: AdaptyCloseButton?
    private var baseStack: UIStackView?
    private var productsList: AdaptyProductsListComponent?
    private var continueButton: AdaptyContinueButton?
    private var serviceButtons: AdaptyServiceButtonsComponent?

    private func buildTemplateInterface(reader: AdaptyTemplateReader) throws {
        view.backgroundColor = try reader.contentBackgroundColor().uiColor

        let coverImageView = try AdaptyInterfaceBilder.buildCoverImageView(on: view, reader: reader)
        scrollViewDelegate.coverView = coverImageView
        let coverImageGradient = AdaptyInterfaceBilder.buildCoverImageGradient(on: view)

        let scrollView = AdaptyInterfaceBilder.buildScrollView(on: view, delegate: scrollViewDelegate)
        let spacerView = AdaptyInterfaceBilder.buildCoverSpacerView(on: scrollView, superview: view)
        let contentView = try AdaptyInterfaceBilder.buildContentView(on: scrollView, spacerView: spacerView, reader: reader)
        let baseStack = AdaptyInterfaceBilder.buildBaseStackView(on: contentView)

        try AdaptyInterfaceBilder.buildMainInfoBlock(on: baseStack, reader: reader)

        let productsList = try AdaptyInterfaceBilder.buildProductsBlock(
            paywall,
            presenter.products,
            presenter.introductoryOffersEligibilities,
            on: baseStack,
            useHaptic: true,
            selectedProductId: presenter.selectedProduct?.vendorProductId,
            reader: reader,
            productsTitlesResolver: productsTitlesResolver,
            onProductSelected: { [weak self] productId in
                self?.presenter.selectProduct(id: productId)
            }
        )

        let continueButton = try AdaptyInterfaceBilder.buildContinueButton(
            on: baseStack,
            reader: reader,
            onTap: { [weak self] in
                guard let self = self else { return }

                self.presenter.makePurchase()

                if let delegate = self.delegate, let product = self.presenter.selectedProduct {
                    delegate.paywallController(self, didStartPurchase: product)
                }
            }
        )

        let serviceButtons = try AdaptyInterfaceBilder.buildServiceButtons(
            on: baseStack,
            reader: reader,
            onTerms: { [weak self] in
                self?.log(.verbose, "onTerms tap")
                guard let url = reader.termsURL(), let self = self else { return }
                self.delegate?.paywallController(self, openURL: url)
            },
            onPrivacy: { [weak self] in
                self?.log(.verbose, "onPrivacy tap")
                guard let url = reader.privacyURL(), let self = self else { return }
                self.delegate?.paywallController(self, openURL: url)
            },
            onRestore: { [weak self] in self?.presenter.restorePurchases() }
        )

        let loadingView = AdaptyInterfaceBilder.buildInProgressView(on: view)

        self.coverImageGradient = coverImageGradient
        self.baseStack = baseStack
        self.productsList = productsList
        self.continueButton = continueButton
        self.serviceButtons = serviceButtons
        self.loadingView = loadingView

        if reader.showCloseButton {
            closeButton = AdaptyInterfaceBilder.buildCloseButton(on: view) { [weak self] in
                self?.log(.verbose, "onClose tap")

                guard let self = self else { return }
                self.delegate?.paywallControllerDidPressCloseButton(self)
            }
        }
    }
}

extension AdaptyPaywallController: AdaptyPaywallPresenterDelegate {
    func didFailLoadingProducts(with error: AdaptyError) -> Bool {
        delegate?.paywallController(self, didFailLoadingProductsWith: error) ?? false
    }
}

extension AdaptyPaywallController {
    func log(_ level: AdaptyLogLevel, _ message: String) {
        AdaptyUI.writeLog(level: level, message: "#\(logId)# \(message)")
    }
}
