//
//  FoodPost.swift
//  HealthHub
//
//  Created by Carlotta Chen on 2/27/22.
//

import UIKit
import CloudKit

struct FoodStrings {
    static let recordTypeKey = "FoodPost"
    fileprivate static let bodyKey = "body"
    static let userReferenceKey = "userReference"
    fileprivate static let photoAssetKey = "photoAsset"
    fileprivate static let timestampKey = "timestamp"
    static let reportCountKey = "reportCount"
    static let commentsKey = "comments"
    static let commentCountKey = "commentCount"
    static let usernameKey = "username"
}

class FoodPost {
    var photoData: Data?
    var username: String
    var body: String
    var timestamp: Date
    var reportCount: Int
    var commentCount: Int
    var comments: [Comment]
    
    var foodPhoto: UIImage? {
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
    
    init(username: String, body: String, timestamp: Date = Date(), reportCount: Int, foodPhoto: UIImage? = nil, comments: [Comment] = [], recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), userReference: CKRecord.Reference?, commentCount: Int = 0) {
        self.username = username
        self.body = body
        self.timestamp = timestamp
        self.reportCount = reportCount
        self.comments = comments
        self.recordID = recordID
        self.userReference = userReference
        self.commentCount = commentCount
        self.foodPhoto = foodPhoto
    }
}


extension FoodPost {
    convenience init?(ckRecord: CKRecord) {
        guard let body = ckRecord[FoodStrings.bodyKey] as? String,
              let timestamp = ckRecord[FoodStrings.timestampKey] as? Date,
              let username = ckRecord[FoodStrings.usernameKey] as? String,
              let reportCount = ckRecord[FoodStrings.reportCountKey] as? Int,
              let commentCount = ckRecord[FoodStrings.commentCountKey] as? Int
        else { return nil }
        
        let userReference = ckRecord[FoodStrings.userReferenceKey] as? CKRecord.Reference
        
        var foundPhoto: UIImage?
        if let photoAsset = ckRecord[FoodStrings.photoAssetKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL!)
                foundPhoto = UIImage(data: data)
            } catch {
                print("Couldn't transform asset to data")
            }
        }
        self.init(username: username, body: body, timestamp: timestamp, reportCount: reportCount, foodPhoto: foundPhoto, comments: [], recordID: ckRecord.recordID, userReference: userReference, commentCount: commentCount)
    }
}

extension FoodPost: Equatable {
    static func == (lhs: FoodPost, rhs: FoodPost) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}

extension CKRecord {
    convenience init(foodPost: FoodPost) {
        self.init(recordType: FoodStrings.recordTypeKey, recordID: foodPost.recordID)
        self.setValue(foodPost.body, forKey: FoodStrings.bodyKey)
        self.setValue(foodPost.timestamp, forKey: FoodStrings.timestampKey)
        self.setValue(foodPost.reportCount, forKey: FoodStrings.reportCountKey)
        self.setValue(foodPost.username, forKey: FoodStrings.usernameKey)
        self.setValue(foodPost.userReference, forKey: FoodStrings.userReferenceKey)
        self.setValue(foodPost.photoAsset, forKey: FoodStrings.photoAssetKey)
        self.setValue(foodPost.commentCount, forKey: FoodStrings.commentCountKey)
    }
}
