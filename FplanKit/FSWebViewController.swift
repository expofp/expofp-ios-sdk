import Foundation
import WebKit
import UniformTypeIdentifiers

class FSWebViewController: UIViewController, WKURLSchemeHandler, WKNavigationDelegate {
    var wkWebView: WKWebView? = nil
    
    var selectedBooth: String?
    var route: Route?
    var currentPosition: BlueDotPoint?
    
    var expoCacheDirectory: String = ""
    var expoUrl: String = ""
    
    var loadedAction: (() -> Void)? = nil
    
    func setExpo(_ expoUrl: String, _ expoCacheDirectory: String, _ loadedAction: (() -> Void)? = nil){
        self.expoUrl = expoUrl
        self.expoCacheDirectory = expoCacheDirectory
        self.loadedAction = loadedAction
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if(navigationAction.navigationType == WKNavigationType.other){
            decisionHandler(.allow)
            return
        }
        
        if let url = navigationAction.request.url {
            if url.scheme == "https" || url.scheme == "http" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        if(urlSchemeTask.request.url == nil || urlSchemeTask.request.url?.scheme != Constants.scheme){
            return
        }
        
        var realPath = urlSchemeTask.request.url!.absoluteString.replacingOccurrences(of: Constants.scheme, with: "file")
        if let index = realPath.firstIndex(of: "?"){
            realPath = String(realPath[..<index])
        }
        
        let realUrl = URL.init(string: realPath)
        
        if(!FileManager.default.fileExists(atPath: realUrl!.path)){
            let dir = realUrl!.deletingLastPathComponent().path
            try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
            
            let pth = realPath.lowercased().replacingOccurrences(of: expoCacheDirectory.lowercased(), with: "")
            let reqUrl = expoUrl + pth
            
            Helper.downloadFile(URL.init(string: reqUrl)!, realUrl!){
                self.setData(urlSchemeTask: urlSchemeTask, dataURL: realUrl!)
            }
        }
        else {
            setData(urlSchemeTask: urlSchemeTask, dataURL: realUrl!)
        }
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            if(loadedAction != nil && wkWebView != nil && wkWebView!.estimatedProgress == 1.0 ){
                loadedAction!();
            }
        }
    }
    
    private func setData(urlSchemeTask: WKURLSchemeTask, dataURL: URL){
        let data = try? Data(contentsOf: dataURL)
        if(data == nil) {
            let urlResponse = URLResponse(url: urlSchemeTask.request.url!, mimeType: nil, expectedContentLength: -1, textEncodingName: "gzip")
            urlSchemeTask.didReceive(urlResponse)
            urlSchemeTask.didFinish()
            return
        }
        
        let mimeType = dataURL.mimeType()
        let urlResponse = URLResponse(url: urlSchemeTask.request.url!, mimeType: mimeType, expectedContentLength: data!.count, textEncodingName: "gzip")
        urlSchemeTask.didReceive(urlResponse)
        
        urlSchemeTask.didReceive(data!)
        urlSchemeTask.didFinish()
    }
}

