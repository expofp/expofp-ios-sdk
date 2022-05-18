import Foundation

///Fplan configuration
public struct Configuration : Codable {
    
    ///Hides the panel with information about exhibitors
    public let noOverlay: Bool
    
    ///URL index.html for Android version
    public let androidHtmlUrl: String?
    
    ///URL index.html for iOS version
    public let iosHtmlUrl: String?
    
    ///Array of cached files
    public let files: [FileInfo]
}
