# Wire™
[![Build Status](https://travis-ci.org/wireapp/wire-ios-link-preview.svg?branch=master)](https://travis-ci.org/wireapp/wire-ios-link-preview)

![Wire logo](https://github.com/wireapp/wire/blob/master/assets/logo.png?raw=true)

This repository is part of the source code of Wire. You can find more information at [wire.com](https://wire.com) or by contacting opensource@wire.com.

You can find the published source code at [github.com/wireapp/wire](https://github.com/wireapp/wire).

For licensing information, see the attached LICENSE file and the list of third-party licenses at [wire.com/legal/licenses/](https://wire.com/legal/licenses/).

#ZMCLinkPreview

This framework is part of Wire iOS SyncEngine. Visit [iOS SyncEngine repository](http://github.com/wireapp/zmessaging-cocoa) for an overview of the architecture.

ZMCLinkPreview is a Swift framework that can be used to fetch and parse Open Graph data that is present on most webpages (see http://ogp.me/ for more information and https://developers.facebook.com/tools/debug/sharing to debug open graph data).

### How to build

This framework is using Carthage to manage its dependencies. To pull the dependencies binaries, `run carthage bootstrap --platform ios`.

You can now open the Xcode project and build.

### Usage:

Consumers of this framework should mostly interact with the `LinkPreviewDetector` type, it can be used to check if a given text contains a link using the `containsLink:inText` method and if it does it can be used to download the previews asynchronously using `downloadLinkPreviews:inText:completion`.

```swift
let text = "Text containing a link to your awesome tweet"
let detector = LinkPreviewDetector(resultsQueue: .mainQueue())

guard detector.containsLink(inText: text) else { return }
detector.downloadLinkPreviews(inText: text) { previews in
    // Do something with the previews
}
```

A call to this method will also download the images specified in the Open Graph data. The completion returns an array of `LinkPreview` objects which currently are either of type `Article` or `TwitterStatus`, while the count of elements in the array is also limited to one at for now.
