<h1 align="center" style="border-bottom: none">
<b>
    <a href="https://adapty.io/?utm_source=github&utm_medium=referral&utm_campaign=AdaptySDK-iOS">
        <img src="https://adapty-portal-media-production.s3.amazonaws.com/github/logo-adapty-new.svg">
    </a>
</b>
<br>Adapty UI
</h1>

<p align="center">
<a href="https://go.adapty.io/subhub-community-ios-rep"><img src="https://img.shields.io/badge/Adapty-discord-purple"></a>
<a href="http://bit.ly/3qXy7cf"><img src="https://img.shields.io/cocoapods/v/AdaptyUI.svg?style=flat"></a>
<a href="https://github.com/adaptyteam/AdaptyUI-iOS/blob/master/LICENSE"><img src="https://img.shields.io/cocoapods/l/AdaptyUI.svg?style=flat"></a>
<a href="http://bit.ly/3qXy7cf2"><img src="https://img.shields.io/cocoapods/p/Adapty.svg?style=flat"></a>
<a href="https://docs.adapty.io/docs/paywall-builder-installation">
<img src="https://img.shields.io/badge/SwiftPM-compatible-orange.svg"></a>
</p>

**AdaptyUI** is an open-source framework that is an extension to the Adapty SDK that allows you to easily add purchase screens to your application. It’s 100% open-source, native, and lightweight.

### [1. Fetching Paywalls & ViewConfiguration](https://docs.adapty.io/docs/paywall-builder-fetching)

Paywall can be obtained in the way you are already familiar with:

```swift
import Adapty

Adapty.getPaywall("YOUR_PAYWALL_ID") { result in
    switch result {
    case let .success(paywall):
        // handle the error
    case let .failure(error):
        self?.paywallsStates[id] = .failed(error)
    }
}
```

After fetching the paywall call the `AdaptyUI.getViewConfiguration(paywall:)` method to load the view configuration:

```swift
import Adapty

AdaptyUI.getViewConfiguration(paywall: paywall) { result in
    switch result {
    case let .success(viewConfiguration):
        // use loaded configuration
    case let .failure(error):
        // handle the error
    }
}
```

### [2. Presenting Visual Paywalls](https://docs.adapty.io/docs/paywall-builder-presenting)

In order to display the visual paywall on the device screen, you must first configure it. To do this, call the method `.paywallController(for:products:viewConfiguration:delegate:)`:

```swift
import Adapty
import AdaptyUI

let visualPaywall = AdaptyUI.paywallController(
    for: <paywall object>,
    products: <paywall products array>,
    viewConfiguration: <ViewConfiguration>,
    delegate: <AdaptyPaywallControllerDelegate>
)
```

After the object has been successfully created, you can display it on the screen of the device:

```swift
present(visualPaywall, animated: true)
```

### 3. Full Documentation and Next Steps

We recommend that you read the [full documentation](https://docs.adapty.io/docs/paywall-builder-getting-started). If you are not familiar with Adapty, then start [here](https://docs.adapty.io/docs).

## Contributing

- Feel free to open an issue, we check all of them or drop us an email at [support@adapty.io](mailto:support@adapty.io) and tell us everything you want.
- Want to suggest a feature? Just contact us or open an issue in the repo.

## Like AdaptyUI?

So do we! Feel free to star the repo ⭐️⭐️⭐️ and make our developers happy!

## License

AdaptyUI is available under the MIT license. [Click here](https://github.com/adaptyteam/AdaptyUI-iOS/blob/master/LICENSE) for details.

---
