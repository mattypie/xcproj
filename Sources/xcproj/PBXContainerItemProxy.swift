import Foundation

// This is the element for to decorate a target item.
public class PBXContainerItemProxy: PBXObject, Hashable {

    public enum ProxyType: UInt, Decodable {
        case nativeTarget = 1
        case reference = 2
        case other
    }
    
    /// The object is a reference to a PBXProject element.
    public var containerPortal: String
    
    /// Element proxy type.
    public var proxyType: ProxyType
    
    /// Element remote global ID reference.
    public var remoteGlobalIDString: String
    
    /// Element remote info.
    public var remoteInfo: String?
    
    /// Initializes the container item proxy with its attributes.
    ///
    /// - Parameters:
    ///   - reference: reference to the element.
    ///   - containerPortal: reference to the container portal.
    ///   - remoteGlobalIDString: reference to the remote global ID.
    ///   - remoteInfo: remote info.
    public init(reference: String,
                containerPortal: String,
                remoteGlobalIDString: String,
                proxyType: ProxyType = .nativeTarget,
                remoteInfo: String? = nil) {
        self.containerPortal = containerPortal
        self.remoteGlobalIDString = remoteGlobalIDString
        self.remoteInfo = remoteInfo
        self.proxyType = proxyType
        super.init(reference: reference)
    }
    
    public static func == (lhs: PBXContainerItemProxy,
                           rhs: PBXContainerItemProxy) -> Bool {
        return lhs.reference == rhs.reference &&
            lhs.proxyType == rhs.proxyType &&
            lhs.containerPortal == rhs.containerPortal &&
            lhs.remoteGlobalIDString == rhs.remoteGlobalIDString &&
            lhs.remoteInfo == rhs.remoteInfo
    }
    
    // MARK: - Decodable
    
    fileprivate enum CodingKeys: String, CodingKey {
        case containerPortal
        case proxyType
        case remoteGlobalIDString
        case remoteInfo
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.containerPortal = try container.decode(.containerPortal)
        let proxyTypeString: String = try container.decode(.proxyType)
        self.proxyType = UInt(proxyTypeString).flatMap({ProxyType(rawValue: $0)}) ?? .other
        self.remoteGlobalIDString = try container.decode(.remoteGlobalIDString)
        self.remoteInfo = try container.decodeIfPresent(.remoteInfo)
        try super.init(from: decoder)
    }
    
}

// MARK: - PBXContainerItemProxy Extension (PlistSerializable)

extension PBXContainerItemProxy: PlistSerializable {
    
    func plistKeyAndValue(proj: PBXProj) -> (key: CommentedString, value: PlistValue) {
        var dictionary: [CommentedString: PlistValue] = [:]
        dictionary["isa"] = .string(CommentedString(PBXContainerItemProxy.isa))
        dictionary["containerPortal"] = .string(CommentedString(containerPortal, comment: "Project object"))
        dictionary["proxyType"] = .string(CommentedString("\(proxyType.rawValue)"))
        dictionary["remoteGlobalIDString"] = .string(CommentedString(remoteGlobalIDString))
        if let remoteInfo = remoteInfo {
            dictionary["remoteInfo"] = .string(CommentedString(remoteInfo))
        }
        return (key: CommentedString(self.reference,
                                                 comment: "PBXContainerItemProxy"),
                value: .dictionary(dictionary))
    }

}