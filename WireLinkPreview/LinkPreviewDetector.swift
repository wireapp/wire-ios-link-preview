// 
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 


import Foundation

@objc public protocol LinkPreviewDetectorType {
    @objc optional func downloadLinkPreviews(inText text: String, completion: @escaping ([LinkPreview]) -> Void)
}

public protocol LinkPreviewDetectorDelegate: class {
    func shouldDetectURL(_ url: URL, inRange range: NSRange, inText text: String) -> Bool
}

public final class LinkPreviewDetector : NSObject, LinkPreviewDetectorType {
    
    public weak var delegate: LinkPreviewDetectorDelegate?
    
    private let blacklist = PreviewBlacklist()
    private let linkDetector : NSDataDetector? = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    private let previewDownloader: PreviewDownloaderType
    private let imageDownloader: ImageDownloaderType
    private let workerQueue: OperationQueue
    private let resultsQueue: OperationQueue
    
    public typealias DetectCompletion = ([LinkPreview]) -> Void
    typealias URLWithRange = (URL: URL, range: NSRange)
    
    public convenience init(resultsQueue: OperationQueue) {
        let workerQueue = OperationQueue()
        self.init(
            previewDownloader: PreviewDownloader(resultsQueue: workerQueue),
            imageDownloader: ImageDownloader(resultsQueue: workerQueue),
            resultsQueue: resultsQueue,
            workerQueue: workerQueue
        )
    }
    
    init(previewDownloader: PreviewDownloaderType, imageDownloader: ImageDownloaderType, resultsQueue: OperationQueue, workerQueue: OperationQueue) {
        self.resultsQueue = resultsQueue
        self.workerQueue = workerQueue
        self.previewDownloader = previewDownloader
        self.imageDownloader = imageDownloader
        super.init()
    }
    
    public func containsLink(inText text: String) -> Bool {
        return !containedLinks(inText: text).isEmpty
    }
    
    func containedLinks(inText text: String) -> [URLWithRange] {
        let range = NSRange(location: 0, length: text.characters.count)
        guard let matches = linkDetector?.matches(in: text, options: [], range: range) else { return [] }
        return matches.flatMap {
            guard let url = $0.url,
                delegate?.shouldDetectURL(url, inRange: $0.range, inText: text) ?? true
                else { return nil }
            return (url, $0.range)
        }
    }

    /**
     Downloads the link preview data, including their images, for links contained in the text.
     The preview data is generated from the [Open Graph](http://ogp.me) information contained in the head of the html of the link.
     For debugging Open Graph please use the [Sharing Debugger](https://developers.facebook.com/tools/debug/sharing).

     **Attention: For now this method only downloads the preview data (and only one image for this link preview) 
     for the first link found in the text!**

     - parameter text:       The text with potentially contained links, if links are found the preview data is downloaded.
     - parameter completion: The completion closure called when the link previews (and it's images) have been downloaded.
     */
    public func downloadLinkPreviews(inText text: String, completion : @escaping DetectCompletion) {
        guard let (url, range) = containedLinks(inText: text).first, !blacklist.isBlacklisted(url) else { return callCompletion(completion, result: []) }
        previewDownloader.requestOpenGraphData(fromURL: url) { [weak self] openGraphData in
            guard let `self` = self else { return }
            let originalURLString = (text as NSString).substring(with: range)
            guard let data = openGraphData else { return self.callCompletion(completion, result: []) }

            let linkPreview = data.linkPreview(originalURLString, offset: range.location)
            linkPreview.requestAssets(withImageDownloader: self.imageDownloader) { _ in
                self.callCompletion(completion, result: [linkPreview])
            }
        }
    }
    
    private func callCompletion(_ completion: @escaping DetectCompletion, result: [LinkPreview]) {
        resultsQueue.addOperation { 
            completion(result)
        }
    }
    
}
