import Foundation
import CryptoKit

public enum ManifestError: Error, Equatable { case empty, forbiddenPath(String), missingTarget(String), symbolicLink(String), changedTarget(String), expired, digestMismatch }

public struct ManifestValidator {
    public init() {}
    public func validate(_ manifest: CleanupManifest) throws {
        guard !manifest.targets.isEmpty else { throw ManifestError.empty }
        let home = FileManager.default.homeDirectoryForCurrentUser.standardizedFileURL.path
        let forbidden = ["/", "/System", "/Library", "/private", home, home + "/Library"]
        for target in manifest.targets {
            let url = URL(fileURLWithPath: target.canonicalPath).standardizedFileURL
            let path = url.path
            if forbidden.contains(path) || path.isEmpty || path.contains("*") { throw ManifestError.forbiddenPath(path) }
            guard FileManager.default.fileExists(atPath: path) else { throw ManifestError.missingTarget(path) }
            let values = try url.resourceValues(forKeys: [.isSymbolicLinkKey])
            if values.isSymbolicLink == true { throw ManifestError.symbolicLink(path) }
            if fingerprint(url) != target.fingerprint { throw ManifestError.changedTarget(path) }
        }
    }
    public func digest(_ manifest: CleanupManifest) throws -> String {
        let encoder = JSONEncoder(); encoder.outputFormatting = [.sortedKeys]; encoder.dateEncodingStrategy = .iso8601
        return SHA256.hash(data: try encoder.encode(manifest)).map { String(format: "%02x", $0) }.joined()
    }
    public func receipt(for manifest: CleanupManifest, validFor seconds: TimeInterval = 300, now: Date = Date()) throws -> AuthorizationReceipt {
        try validate(manifest)
        return AuthorizationReceipt(manifestDigest: try digest(manifest), targetIDs: manifest.targets.map(\.id), expiresAt: now.addingTimeInterval(seconds), confirmedAt: now)
    }
    public func validate(_ receipt: AuthorizationReceipt, for manifest: CleanupManifest, now: Date = Date()) throws {
        if now > receipt.expiresAt { throw ManifestError.expired }
        if try digest(manifest) != receipt.manifestDigest || receipt.targetIDs != manifest.targets.map(\.id) { throw ManifestError.digestMismatch }
        try validate(manifest)
    }
    public func fingerprint(_ url: URL) -> String {
        let values = try? url.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey, .fileResourceIdentifierKey])
        let basis = "\(url.standardizedFileURL.path)|\(values?.fileSize ?? -1)|\(values?.contentModificationDate?.timeIntervalSince1970 ?? -1)|\(String(describing: values?.fileResourceIdentifier))"
        return SHA256.hash(data: Data(basis.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}

public struct CleanupResult: Codable, Sendable { public let staged: [String]; public let failed: [String]; public let observedFreeBytes: Int64 }

public struct CleanupExecutor {
    public init() {}
    public func stage(_ manifest: CleanupManifest, receipt: AuthorizationReceipt) throws -> CleanupResult {
        let validator = ManifestValidator(); try validator.validate(receipt, for: manifest)
        var staged: [String] = [], failed: [String] = []
        for target in manifest.targets {
            do { try FileManager.default.trashItem(at: URL(fileURLWithPath: target.canonicalPath), resultingItemURL: nil); staged.append(target.canonicalPath) }
            catch { failed.append(target.canonicalPath) }
        }
        let free = (try? FileManager.default.homeDirectoryForCurrentUser.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage) ?? 0
        return CleanupResult(staged: staged, failed: failed, observedFreeBytes: free)
    }
}

public struct InspectorResult: Codable, Sendable { public let kind: String; public let summary: String; public let confidence: Double; public let evidence: [Evidence] }

public struct ReadOnlyInspector {
    public init() {}
    public func inspectInstaller(at url: URL) -> InspectorResult {
        let ext = url.pathExtension.lowercased(); let supported = ["dmg", "pkg"].contains(ext)
        return InspectorResult(kind: "installer", summary: supported ? "安装介质；需确认对应应用已安装。" : "不是已识别的安装介质。", confidence: supported ? 0.9 : 0.3, evidence: [])
    }
    public func inspectModel(at url: URL) -> InspectorResult {
        let local = FileManager.default.fileExists(atPath: url.path)
        return InspectorResult(kind: "model", summary: local ? "本地模型权重；删除后相关本地推理需重新下载。" : "本地未找到该模型。", confidence: 0.95, evidence: [])
    }
}
