# Harrastuspassi iOS

> Harrastuspassi project consists of Android and iOS mobile applications, a web based admin user interface and a backend system. This is the repository for the iOS application.

[![Swift Version][swift-image]][swift-url]

## Requirements

- MacOS 10.14.4+
- iOS 11.0+
- Xcode 10.2+

## Setting up development environment

Clone this project to your local machine using `git clone`.

To get the project up and running you'll need to create:

`/Harrastupassi/Config.swift`

and add the following contents with an API URL and a valid Google Maps SDK API-key:

```
//  Config.swift
//  Harrastuspassi

import Foundation

class Config {
    static let API_URL: String = "<YOUR_API_URL>"
    static let GM_API_KEY = "<YOUR_GM_API_KEY>"
}
```

After this you'll be able to use `Harrastuspassi.xcworkspace` to start developing in XCode. :sunglasses:

## Related projects

You can view the Harrastuspassi project's main repository, with links to other related projects [here.](https://github.com/City-of-Helsinki/harrastuspassi)

[swift-image]: https://img.shields.io/badge/swift-5.1-orange.svg
[swift-url]: https://swift.org/

