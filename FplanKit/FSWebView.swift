import Foundation
import WebKit

/**
 Full screen WKWebView
 */
public class FSWebView: WKWebView {
    
    public var selectedBooth: String?
    
    public var route: Route?
    
    public var currentPosition: Point?
    
    public override var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
