import Foundation
import SwiftUI
import Combine
import WebKit
import UIKit

public struct Route {
    let distance: String
    let duration: TimeInterval
}

public struct JRoute : Decodable {
    let distance: String
    let time: Int
}

@available(iOS 13.0, *)
public class FpHandler : NSObject, WKScriptMessageHandler {
    
    private let fplanReadyHandler: () -> Void
    
    public init(_ fplanReadyHandler: (() -> Void)!) {
        self.fplanReadyHandler = fplanReadyHandler
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        fplanReadyHandler()
    }
}

@available(iOS 13.0, *)
public class BoothHandler : NSObject, WKScriptMessageHandler {
    
    private let boothSelectionHandler: (_ boothName: String) -> Void
    
    public init(_ boothSelectionHandler: ((_ boothName: String) -> Void)!) {
        self.boothSelectionHandler = boothSelectionHandler
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let boothName = message.body as? String{
            boothSelectionHandler(boothName)
        }
    }
}

@available(iOS 13.0, *)
public class RouteHandler : NSObject, WKScriptMessageHandler {
    
    private let routeBuildHandler: (_ route: Route) -> Void
    
    public init(_ routeBuildHandler: ((_ route: Route) -> Void)!) {
        self.routeBuildHandler = routeBuildHandler
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let json = message.body as? String{
            let decoder = JSONDecoder()
            guard let jRoute = try? decoder.decode(JRoute.self, from: json.data(using: .utf8)!) else {
                return
            }
            routeBuildHandler(Route(distance: jRoute.distance, duration: TimeInterval(jRoute.time)))
        }
    }
}

@available(iOS 13.0, *)
public struct FplanView: UIViewRepresentable {
    
    private let url: String
    private let webView: WKWebView
    private let fplanReadyHandler: (() -> Void)?
    private let boothSelectionHandler: ((_ boothName: String) -> Void)?
    private let routeBuildHandler: ((_ route: Route) -> Void)?
    
    public init(_ url: String, fplanReadyHandler: (() -> Void)? = nil,
         boothSelectionHandler: ((_ boothName: String) -> Void)? = nil,
         routeBuildHandler: ((_ route: Route) -> Void)? = nil){
        
        self.url = url
        self.fplanReadyHandler = fplanReadyHandler
        self.boothSelectionHandler = boothSelectionHandler
        self.routeBuildHandler = routeBuildHandler
        
        let preferences = WKPreferences()
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        self.webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        self.webView.allowsBackForwardNavigationGestures = true
        self.webView.scrollView.isScrollEnabled = true
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    public func selectBooth(_ boothName:String){
        webView.evaluateJavaScript("window.selectBooth('\(boothName)');")
        
    }
    
    public func buildRoute(_ from: String, _ to: String, _ exceptUnaccessible: Bool = false){
        webView.evaluateJavaScript("window.selectRoute('\(from)', '\(to)', \(exceptUnaccessible))")
    }
    
    public func updateUIView(_ webView: WKWebView, context: Context) {
        if let requestUrl = URL(string: url) {
            webView.load(URLRequest(url: requestUrl))
            
            if let handle = fplanReadyHandler{
                webView.configuration.userContentController.add(FpHandler(handle), name: "onFpConfiguredHandler")
            }
                        
            if let handle = boothSelectionHandler{
                webView.configuration.userContentController.add(BoothHandler(handle), name: "onBoothClickHandler")
            }
            
            if let handle = routeBuildHandler{
                webView.configuration.userContentController.add(RouteHandler(handle), name: "onDirectionHandler")
            }
        }
    }
}

public struct FplanView_Previews: PreviewProvider {
    public init(){
        
    }
    public static var previews: some View {
        FplanView("https://developer.expofp.com/examples/autumnfair.html")
    }
}
