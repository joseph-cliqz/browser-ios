/* This Source Code Form is subject to the terms of the Mozilla Public
* License, v. 2.0. If a copy of the MPL was not distributed with this
* file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import WebKit
import Storage
import WebImage


class FaviconManager : TabHelper {
    let profile: Profile!
    weak var tab: Tab?

    init(tab: Tab, profile: Profile) {
        self.profile = profile
        self.tab = tab

        if let path = NSBundle.mainBundle().pathForResource("Favicons", ofType: "js") {
            if let source = try? NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String {
                let userScript = WKUserScript(source: source, injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: true)
                tab.webView!.configuration.userContentController.addUserScript(userScript)
            }
        }
    }

    class func name() -> String {
        return "FaviconsManager"
    }

    func scriptMessageHandlerName() -> String? {
        return "faviconsMessageHandler"
    }

    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        let manager = SDWebImageManager.sharedManager()
        self.tab?.favicons.removeAll(keepCapacity: false)
        if let tab = self.tab,
            let currentURL = tab.url,
            let url = tab.url?.absoluteString {
                let site = Site(url: url, title: "")
                var favicons = [Favicon]()
                if let icons = message.body as? [String: Int] {
                    for icon in icons {
                        if let _ = NSURL(string: icon.0), iconType = IconType(rawValue: icon.1) {
                            let favicon = Favicon(url: icon.0, date: NSDate(), type: iconType)
                            favicons.append(favicon)
                        }
                    }
                }

                let options = tab.isPrivate ?
                    [SDWebImageOptions.LowPriority, SDWebImageOptions.CacheMemoryOnly] : [SDWebImageOptions.LowPriority]

                for icon in favicons {
                    if let iconUrl = NSURL(string: icon.url) {
                        manager.downloadImageWithURL(iconUrl, options: SDWebImageOptions(options), progress: nil, completed: { (img, err, cacheType, success, url) -> Void in
                            // Cliqz: [iOS10] fixed compilation error for optional value
                            if let urlString = url.absoluteString {
                                let fav = Favicon(url: urlString,
                                                  date: NSDate(),
                                                  type: icon.type)
                                
                                if let img = img {
                                    fav.width = Int(img.size.width)
                                    fav.height = Int(img.size.height)
                                } else {
                                    if favicons.count == 1 && favicons[0].type == .Guess {
                                        // No favicon is indicated in the HTML
                                        self.noFaviconAvailable(tab, atURL: currentURL)
                                    }
                                    return
                                }
                                
                                if !tab.isPrivate {
                                    self.profile.favicons.addFavicon(fav, forSite: site)
                                    if tab.favicons.isEmpty {
                                        self.makeFaviconAvailable(tab, atURL: currentURL, favicon: fav, withImage: img)
                                    }
                                }
                                tab.favicons.append(fav)
                            }
                            
                        })
                    }
                }
        }
    }

    func makeFaviconAvailable(tab: Tab, atURL url: NSURL, favicon: Favicon, withImage image: UIImage) {
        let helper = tab.getHelper(name: "SpotlightHelper") as? SpotlightHelper
        helper?.updateImage(image, forURL: url)
    }

    func noFaviconAvailable(tab: Tab, atURL url: NSURL) {
        let helper = tab.getHelper(name: "SpotlightHelper") as? SpotlightHelper
        helper?.updateImage(forURL: url)

    }
}
