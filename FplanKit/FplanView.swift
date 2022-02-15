import Foundation
import SwiftUI
import Combine
import WebKit
import UIKit

/**
 Views to display the floor plan

 You can create a floor plan on the site https://expofp.com
 */
@available(iOS 13.0, *)
public struct FplanView: UIViewRepresentable {
    
    private let url: String
    private let route: Route?
    private let currentPosition: Point?
    private let focusOnCurrentPosition: Bool
    
    @Binding var selectedBooth: String?
    
    /**
     This function initializes the view.
      
     **Parameters:**
         - url: Floor plan URL address in the format https://[expo_name].expofp.com
     */
    public init(_ url: String,
                selectedBooth: Binding<String?>? = nil,
                route: Route? = nil,
                currentPosition: Point? = nil,
                focusOnCurrentPosition: Bool = false){
        self.url = url
        self._selectedBooth = selectedBooth ?? Binding.constant(nil)
        self.route = route
        self.currentPosition = currentPosition
        self.focusOnCurrentPosition = focusOnCurrentPosition

        
        print("[FplanView.init] url: \(url); selectedBooth: \(String(describing: selectedBooth))")
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        print("[FplanView.makeUIView]")
        
        let preferences = WKPreferences()
        preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        preferences.setValue(true, forKey: "offlineApplicationCacheIsEnabled")
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        
        webView.configuration.userContentController.add(FpHandler(webView, fpReady), name: "onFpConfiguredHandler")
        webView.configuration.userContentController.add(BoothHandler(webView, selectBooth), name: "onBoothClickHandler")
        webView.configuration.userContentController.add(DirectionHandler(webView, buildDirection), name: "onDirectionHandler")

        return webView
    }
    
    public func updateUIView(_ webView: WKWebView, context: Context) {
        print("[FplanView.updateUIView]")
        
        let eventAddress = url.replacingOccurrences(of: "https://www.", with: "").replacingOccurrences(of: "https://", with: "")
        if(!(webView.url?.path.contains(eventAddress) ?? false)){
            initWebView(webView)
        }
        else if(self.selectedBooth != nil){
            webView.evaluateJavaScript("window.selectBooth('\(self.selectedBooth!)');")
        }
        else if(self.route != nil){
            webView.evaluateJavaScript("window.selectRoute(\(self.route!.from), \(self.route!.to), \(self.route!.exceptInaccessible));")
        }
        else if(self.currentPosition != nil){
            webView.evaluateJavaScript("window.setCurrentPosition(\(self.currentPosition!.x), \(self.currentPosition!.y), \(focusOnCurrentPosition));")
        }
    }
    
    private func initWebView(_ webView: WKWebView) {
        let fileManager = FileManager.default
        let netReachability = NetworkReachability()
        
        let eventAddress = url.replacingOccurrences(of: "https://www.", with: "").replacingOccurrences(of: "https://", with: "")
        let eventUrl = "https://\(eventAddress)"
        let eventId = String(eventAddress[...eventAddress.index(eventAddress.firstIndex(of: ".")!, offsetBy: -1)])
        
        let fplanDirectory = Helper.getCacheDirectory().appendingPathComponent("fplan/")
        let directory = fplanDirectory.appendingPathComponent("\(eventAddress)/")
        let indexPath = directory.appendingPathComponent("index.html")
        
        do {
            if(netReachability.checkConnection()){
                if fileManager.fileExists(atPath: fplanDirectory.path){
                    try fileManager.removeItem(at: fplanDirectory)
                }
                
                let expofpJsUrl = "\(eventUrl)/packages/master/expofp.js"
                try createHtmlFile(filePath: indexPath, directory: directory,expofpJsUrl: expofpJsUrl, eventId: eventId )
                
                let requestUrl = URLRequest(url: indexPath, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
                webView.load(requestUrl)
                
                try Helper.updateAllFiles(baseUrl: URL(string: eventUrl), directory: directory)
            }
            else{
                let expofpJsUrl = "\(directory.path)/expofp.js"
                try createHtmlFile(filePath: indexPath, directory: directory, expofpJsUrl: expofpJsUrl, eventId: eventId )
                
                let requestUrl = URLRequest(url: indexPath, cachePolicy: .returnCacheDataElseLoad)
                webView.load(requestUrl)
            }
        } catch {
            print(error)
        }
        
    }
    
    func fpReady(_ webView: WKWebView){
        print("[FplanView.makeUIView.initWebView] fpReady")
        
        if(self.selectedBooth != nil){
            webView.evaluateJavaScript("window.selectBooth('\(self.selectedBooth!)');")
        }
        else if(self.route != nil){
            webView.evaluateJavaScript("window.selectRoute(\(self.route!.from), \(self.route!.to), \(self.route!.exceptInaccessible));")
        }
        else if(self.currentPosition != nil){
            webView.evaluateJavaScript("window.setCurrentPosition(\(self.currentPosition!.x), \(self.currentPosition!.y), \(focusOnCurrentPosition));")
        }
    }
    
    func selectBooth(_ webView: WKWebView, _ boothName: String){
        self.selectedBooth = boothName
    }
    
    func buildDirection(_ webView: WKWebView, _ direction: Direction){
        print("buildDirection")
        print(direction)
    }
    
    private func createHtmlFile(filePath: URL, directory: URL, expofpJsUrl: String, eventId: String) throws {
        let fileManager = FileManager.default
        let html = Helper.getIndexHtml()
            .replacingOccurrences(of: "$expofp_js_url#", with: expofpJsUrl)
            .replacingOccurrences(of: "$eventId#", with: eventId)
        
        if !fileManager.fileExists(atPath: filePath.path){
            try! fileManager.createDirectory(atPath: directory.path, withIntermediateDirectories: true, attributes: nil)
        }
        try html.write(to: filePath, atomically: true, encoding: String.Encoding.utf8)
    }
}

public struct FplanView_Previews: PreviewProvider {
    @State private static var selectedBooth: String? = nil
    
    public init(){
        
    }
    
    @available(iOS 13.0.0, *)
    public static var previews: some View {
        FplanView("https://wayfinding.expofp.com", selectedBooth: $selectedBooth)
    }
}
