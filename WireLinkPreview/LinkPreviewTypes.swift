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


@objc open class LinkPreview : NSObject {
    
    open let originalURLString: String
    open let permanentURL: URL?
    open let resolvedURL: URL?
    open let characterOffsetInText: Int
    open var imageURLs = [URL]()
    open var imageData = [Data]()
    
    public typealias DownloadCompletion = (_ successful: Bool) -> Void
    
    public init(originalURLString: String, permamentURLString: String, resolvedURLString: String, offset: Int) {
        self.originalURLString = originalURLString
        permanentURL = URL(string: permamentURLString)
        resolvedURL = URL(string: resolvedURLString)
        characterOffsetInText = offset
        super.init()
    }
    
    func requestAssets(withImageDownloader downloader: ImageDownloaderType, completion: @escaping DownloadCompletion) {
        guard let imageURL = imageURLs.first else { return completion(false) }
        downloader.downloadImage(fromURL: imageURL) { [weak self] imageData in
            guard let `self` = self, let data = imageData else { return completion(false) }
            self.imageData.append(data)
            completion(imageData != nil)
        }
    }

}


@objc public class Article : LinkPreview {
    public var title : String?
    public var summary : String?
}

@objc public class FoursquareLocation : LinkPreview {
    public var title : String?
    public var subtitle : String?
    public var latitude: Float?
    public var longitude: Float?
}

@objc public class InstagramPicture : LinkPreview {
    public var title : String?
    public var subtitle : String?
}

@objc public class TwitterStatus : LinkPreview {
    public var message : String?
    public var username : String?
    public var author : String?
}
