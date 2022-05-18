import Foundation

@available(iOS 13.0.0, *)
struct Helper{
    public static func getEventAddress(_ url: String) -> String {
        func getWithoutParams (_ url: String, _ delimiter: Character) -> String {
            if let sIndex = url.firstIndex(of: delimiter){
                return String(url[...url.index(before: sIndex)])
            }
            else{
                return url
            }
        }
        
        let mainPart = url.replacingOccurrences(of: "https://www.", with: "").replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://www.", with: "").replacingOccurrences(of: "http://", with: "")
        
        let result = getWithoutParams(getWithoutParams(mainPart, "/"), "?")
        return result
    }
    
    public static func getEventId(_ url: String) -> String {
        let eventAddress = getEventAddress(url)
        if let index = eventAddress.firstIndex(of: ".") {
            return String(eventAddress[...eventAddress.index(index, offsetBy: -1)])
        }
        else{
            return ""
        }
    }
    
    public static func createHtmlFile(filePath: URL, html: String, noOverlay: Bool, baseUrl: String, eventId: String, autoInit: Bool) throws {
        let content = html
            .replacingOccurrences(of: "$url#", with: baseUrl)
            .replacingOccurrences(of: "$eventId#", with: eventId)
            .replacingOccurrences(of: "$noOverlay#", with: String(noOverlay))
            .replacingOccurrences(of: "$autoInit#", with: String(autoInit))
        
        let fileDirectory = filePath.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: fileDirectory.path){
            try! FileManager.default.createDirectory(atPath: fileDirectory.path, withIntermediateDirectories: true, attributes: nil)
        }
        
        try content.write(to: filePath, atomically: true, encoding: String.Encoding.utf8)
    }
    
    public static func getCacheDirectory() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    public static func getDefaultConfiguration(baseUrl: String) -> Configuration {
        let files = [
            FileInfo(name: "fp.svg.js", serverUrl: "\(baseUrl)/data/fp.svg.js", cachePath: "data/fp.svg.js", version: "1"),
            FileInfo(name: "data.js", serverUrl: "\(baseUrl)/data/data.js", cachePath: "data/data.js", version: "1"),
            FileInfo(name: "wf.data.js", serverUrl: "\(baseUrl)/data/wf.data.js", cachePath: "data/wf.data.js", version: "1"),
            FileInfo(name: "demo.png", serverUrl: "\(baseUrl)/data/demo.png", cachePath: "data/demo.png", version: "1"),
            
            FileInfo(name: "expofp.js", serverUrl: "\(baseUrl)/packages/master/expofp.js", cachePath: "expofp.js", version: "1"),
            FileInfo(name: "floorplan.js", serverUrl: "\(baseUrl)/packages/master/floorplan.js", cachePath: "floorplan.js", version: "1"),
            FileInfo(name: "vendors~floorplan.js", serverUrl: "\(baseUrl)/packages/master/vendors~floorplan.js", cachePath: "vendors~floorplan.js", version: "1"),
            FileInfo(name: "expofp-overlay.png", serverUrl: "\(baseUrl)/packages/master/expofp-overlay.png", cachePath: "expofp-overlay.png", version: "1"),
            FileInfo(name: "free.js", serverUrl: "\(baseUrl)/packages/master/free.js", cachePath: "free.js", version: "1"),
            FileInfo(name: "slider.js", serverUrl: "\(baseUrl)/packages/master/slider.js", cachePath: "slider.js", version: "1"),
            
            FileInfo(name: "oswald-v17-cyrillic_latin-300.woff2", serverUrl: "\(baseUrl)/packages/master/fonts/oswald-v17-cyrillic_latin-300.woff2", cachePath: "fonts/oswald-v17-cyrillic_latin-300.woff2", version: "1"),
            FileInfo(name: "oswald-v17-cyrillic_latin-500.woff2", serverUrl: "\(baseUrl)/packages/master/fonts/oswald-v17-cyrillic_latin-500.woff2", cachePath: "fonts/oswald-v17-cyrillic_latin-500.woff2", version: "1"),
            
            FileInfo(name: "fontawesome-all.min.css", serverUrl: "\(baseUrl)/packages/master/vendor/fa/css/fontawesome-all.min.css", cachePath: "vendor/fa/css/fontawesome-all.min.css", version: "1"),
            
            FileInfo(name: "fa-brands-400.woff2", serverUrl: "\(baseUrl)/packages/master/vendor/fa/webfonts/fa-brands-400.woff2", cachePath: "vendor/fa/webfonts/fa-brands-400.woff2", version: "1"),
            FileInfo(name: "fa-light-300.woff2", serverUrl: "\(baseUrl)/packages/master/vendor/fa/webfonts/fa-light-300.woff2", cachePath: "vendor/fa/webfonts/fa-light-300.woff2", version: "1"),
            FileInfo(name: "fa-regular-400.woff2", serverUrl: "\(baseUrl)/packages/master/vendor/fa/webfonts/fa-regular-400.woff2", cachePath: "vendor/fa/webfonts/fa-regular-400.woff2", version: "1"),
            FileInfo(name: "fa-solid-900.woff2", serverUrl: "\(baseUrl)/packages/master/vendor/fa/webfonts/fa-solid-900.woff2", cachePath: "vendor/fa/webfonts/fa-solid-900.woff2", version: "1"),
            
            FileInfo(name: "perfect-scrollbar.css", serverUrl: "\(baseUrl)/packages/master/vendor/perfect-scrollbar/css/perfect-scrollbar.css", cachePath: "vendor/perfect-scrollbar/css/perfect-scrollbar.css", version: "1"),
            FileInfo(name: "sanitize.css", serverUrl: "\(baseUrl)/packages/master/vendor/sanitize-css/sanitize.css", cachePath: "vendor/sanitize-css/sanitize.css", version: "1"),
            
            FileInfo(name: "ar.json", serverUrl: "\(baseUrl)/packages/master/locales/ar.json", cachePath: "locales/ar.json", version: "1"),
            FileInfo(name: "de.json", serverUrl: "\(baseUrl)/packages/master/locales/de.json", cachePath: "locales/de.json", version: "1"),
            FileInfo(name: "es.json", serverUrl: "\(baseUrl)/packages/master/locales/es.json", cachePath: "locales/es.json", version: "1"),
            FileInfo(name: "fr.json", serverUrl: "\(baseUrl)/packages/master/locales/fr.json", cachePath: "locales/fr.json", version: "1"),
            FileInfo(name: "it.json", serverUrl: "\(baseUrl)/packages/master/locales/it.json", cachePath: "locales/it.json", version: "1"),
            FileInfo(name: "ko.json", serverUrl: "\(baseUrl)/packages/master/locales/ko.json", cachePath: "locales/ko.json", version: "1"),
            FileInfo(name: "nl.json", serverUrl: "\(baseUrl)/packages/master/locales/nl.json", cachePath: "locales/nl.json", version: "1"),
            FileInfo(name: "pt.json", serverUrl: "\(baseUrl)/packages/master/locales/pt.json", cachePath: "locales/pt.json", version: "1"),
            FileInfo(name: "ru.json", serverUrl: "\(baseUrl)/packages/master/locales/ru.json", cachePath: "locales/ru.json", version: "1"),
            FileInfo(name: "sv.json", serverUrl: "\(baseUrl)/packages/master/locales/sv.json", cachePath: "locales/sv.json", version: "1"),
            FileInfo(name: "th.json", serverUrl: "\(baseUrl)/packages/master/locales/th.json", cachePath: "locales/th.json", version: "1"),
            FileInfo(name: "tr.json", serverUrl: "\(baseUrl)/packages/master/locales/tr.json", cachePath: "locales/tr.json", version: "1"),
            FileInfo(name: "vi.json", serverUrl: "\(baseUrl)/packages/master/locales/vi.json", cachePath: "locales/vi.json", version: "1"),
            FileInfo(name: "zh.json", serverUrl: "\(baseUrl)/packages/master/locales/zh.json", cachePath: "locales/zh.json", version: "1"),
        ]
        
        return Configuration(noOverlay: true, androidHtmlUrl: nil, iosHtmlUrl: nil, files: files)
    }
    
    public static func downloadFile(_ url: URL, _ filePath: URL, callback: @escaping (()->Void)){
        let fileDirectory = filePath.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: fileDirectory.path){
            try! FileManager.default.createDirectory(atPath: fileDirectory.path, withIntermediateDirectories: true, attributes: nil)
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath.path, contents: data)
            callback()
        })
        task.resume()
    }
    
    public static func downloadFiles(_ files: [FileInfo], _ directory: URL!, _ callback: @escaping (() -> Void)){
        var count = 0
        for(_, file) in files.enumerated(){
            downloadFile(URL(string: file.serverUrl)!, directory.appendingPathComponent(file.cachePath)){
                count += 1
                if(count == files.count){
                    callback()
                }
            }
        }
    }
    
    public static func getDefaultHtmlFile() -> String {
        return
"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="user-scalable=no, initial-scale=1.0, maximum-scale=1.0, width=device-width" />
    <style>
      html,
      body {
        touch-action: none;
        margin: 0;
        padding: 0;
        height: 100%;
        width: 100%;
        background: #ebebeb;
        position: fixed;
        overflow: hidden;
      }
      @media (max-width: 820px) and (min-width: 500px) {
        html {
          font-size: 13px;
        }
      }
    </style>
    <style>
      .lds-grid {
        top: 42vh;
        margin: 0 auto;
        display: block;
        position: relative;
        width: 64px;
        height: 64px;
      }

      .lds-grid div {
        position: absolute;
        width: 13px;
        height: 13px;
        background: #aaa;
        border-radius: 50%;
        animation: lds-grid 1.2s linear infinite;
      }

      .lds-grid div:nth-child(1) {
        top: 6px;
        left: 6px;
        animation-delay: 0s;
      }

      .lds-grid div:nth-child(2) {
        top: 6px;
        left: 26px;
        animation-delay: -0.4s;
      }

      .lds-grid div:nth-child(3) {
        top: 6px;
        left: 45px;
        animation-delay: -0.8s;
      }

      .lds-grid div:nth-child(4) {
        top: 26px;
        left: 6px;
        animation-delay: -0.4s;
      }

      .lds-grid div:nth-child(5) {
        top: 26px;
        left: 26px;
        animation-delay: -0.8s;
      }

      .lds-grid div:nth-child(6) {
        top: 26px;
        left: 45px;
        animation-delay: -1.2s;
      }

      .lds-grid div:nth-child(7) {
        top: 45px;
        left: 6px;
        animation-delay: -0.8s;
      }

      .lds-grid div:nth-child(8) {
        top: 45px;
        left: 26px;
        animation-delay: -1.2s;
      }

      .lds-grid div:nth-child(9) {
        top: 45px;
        left: 45px;
        animation-delay: -1.6s;
      }

      @keyframes lds-grid {
        0%,
        100% {
          opacity: 1;
        }

        50% {
          opacity: 0.5;
        }
      }
    </style>
</head>
<body>
<div id="floorplan">
    <div class="lds-grid">
        <div></div>
        <div></div>
        <div></div>
        <div></div>
        <div></div>
        <div></div>
        <div></div>
        <div></div>
        <div></div>
    </div>
</div>
<script>
      function initFloorplan() {
        window.floorplan = new ExpoFP.FloorPlan({
          element: document.querySelector("#floorplan"),
          dataUrl: "$url#/data/",
          eventId: "$eventId#",
          noOverlay: $noOverlay#,
          onBoothClick: e => {
             window.webkit?.messageHandlers?.onBoothClickHandler?.postMessage(e.target.name);
          },
          onFpConfigured: () => {
             window.webkit?.messageHandlers?.onFpConfiguredHandler?.postMessage("FLOOR PLAN CONFIGURED");
          },
          onDirection: (e) => {
             window.webkit?.messageHandlers?.onDirectionHandler?.postMessage(JSON.stringify(e));
          }
        });
      }

      function init() {
        const expofpScript = document.createElement("script");
        expofpScript.src = "$url#/expofp.js";
        expofpScript.crossorigin = "anonymous";
        expofpScript.onload = function() {
            initFloorplan();
        };

        document.body.appendChild(expofpScript);
      }


      function autoInit() {
        if($autoInit#){
            init();
        }
      }
      autoInit();
    </script>
</body>
</html>
""";
    }
}

