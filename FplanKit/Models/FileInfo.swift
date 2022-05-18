import Foundation

///Information about the file to be cached
public struct FileInfo : Codable {
    
    ///File name
    public let name: String
    
    ///URL address of the file on the server
    public let serverUrl: String
    
    ///The path to the file in the cache
    public let cachePath: String
    
    ///File version
    public let version: String
}
