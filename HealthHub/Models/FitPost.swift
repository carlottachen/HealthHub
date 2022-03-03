//
//  FitPost.swift
//  HealthHub
//
//  Created by Carlotta Chen on 2/16/22.
//

import UIKit
import CloudKit

struct FitStrings {
    static let recordTypeKey = "FitPost"
    fileprivate static let bodyKey = "body"
    static let userReferenceKey = "userReference"
    fileprivate static let photoAssetKey = "photoAsset"
    fileprivate static let timestampKey = "timestamp"
    static let reportCountKey = "reportCount"
    static let commentsKey = "comments"
    static let commentCountKey = "commentCount"
    static let usernameKey = "username"
}

class FitPost {
    var photoData: Data?
    var username: String
    var body: String
    var timestamp: Date
    var reportCount: Int
    var commentCount: Int
    var comments: [Comment]
    
    var fitPhoto: UIImage? {
        get {
            guard let photoData = self.photoData else { return nil }
            return UIImage(data: photoData)
        } set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    // CloudKit Properties
    var recordID: CKRecord.ID
    var userReference: CKRecord.Reference?
    var photoAsset: CKAsset? {
        get {
            let tempDir = NSTemporaryDirectory()
            let tempDirURL = URL(fileURLWithPath: tempDir)
            let fileURL = tempDirURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            
            do {
                try photoData?.write(to: fileURL)
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    init(username: String, body: String, timestamp: Date = Date(), reportCount: Int, fitPhoto: UIImage? = nil, comments: [Comment] = [], recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), userReference: CKRecord.Reference?, commentCount: Int = 0) {
        self.username = username
        self.body = body
        self.timestamp = timestamp
        self.reportCount = reportCount
        self.comments = comments
        self.recordID = recordID
        self.userReference = userReference
        self.commentCount = commentCount
        self.fitPhoto = fitPhoto
    }
}

extension FitPost {
    convenience init?(ckRecord: CKRecord) {
        guard let body = ckRecord[FitStrings.bodyKey] as? String,
              let timestamp = ckRecord[FitStrings.timestampKey] as? Date,
              let reportCount = ckRecord[FitStrings.reportCountKey] as? Int,
              let username = ckRecord[FitStrings.usernameKey] as? String,
              let commentCount = ckRecord[FitStrings.commentCountKey] as? Int
        else { return nil }
        
        let userReference = ckRecord[FitStrings.userReferenceKey] as? CKRecord.Reference
        
        var foundPhoto: UIImage?
        if let photoAsset = ckRecord[FitStrings.photoAssetKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL!)
                foundPhoto = UIImage(data: data)
            } catch {
                print("Couldn't transform asset to data")
            }
        }
        self.init(username: username, body: body, timestamp: timestamp, reportCount: reportCount, fitPhoto: foundPhoto, comments: [], recordID: ckRecord.recordID, userReference: userReference, commentCount: commentCount)
    }
}

extension FitPost: Equatable {
    static func == (lhs: FitPost, rhs: FitPost) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}

extension CKRecord {
    convenience init(fitPost: FitPost) {
        self.init(recordType: FitStrings.recordTypeKey, recordID: fitPost.recordID)
        self.setValue(fitPost.body, forKey: FitStrings.bodyKey)
        self.setValue(fitPost.timestamp, forKey: FitStrings.timestampKey)
        self.setValue(fitPost.reportCount, forKey: FitStrings.reportCountKey)
        self.setValue(fitPost.username, forKey: FitStrings.usernameKey)
        self.setValue(fitPost.userReference, forKey: FitStrings.userReferenceKey)
        self.setValue(fitPost.photoAsset, forKey: FitStrings.photoAssetKey)
        self.setValue(fitPost.commentCount, forKey: FitStrings.commentCountKey)
    }
}
