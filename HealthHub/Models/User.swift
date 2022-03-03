//
//  User.swift
//  HealthHub
//
//  Created by Carlotta Chen on 2/14/22.
//

import UIKit
import CloudKit

struct UserStrings {
    static let userKey = "User"
    static let usernameKey = "username"
    static let reportCountKey = "reportCount"
    static let appleUserReferenceKey = "appleUserReference"
    fileprivate static let photoAssetKey = "photoAsset"
    static let blockedUsersKey = "blockedUsers"
}

class User {
    var username: String
    var reportCount: Int
    var blockedUsers: [String]
    
    var profilePhoto: UIImage? {
        get {
            guard let photoData = self.photoData else { return nil }
            return UIImage(data: photoData)
        } set {
            self.photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    var photoData: Data?
    
    // CloudKit Properties
    var recordID: CKRecord.ID
    var appleUserReference: CKRecord.Reference
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
    
    init(username: String, reportCount: Int, blockedUsers: [String] = [], profilePhoto: UIImage? = nil, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), appleUserReference: CKRecord.Reference) {
        self.username = username
        self.reportCount = reportCount
        self.blockedUsers = blockedUsers
        self.recordID = recordID
        self.appleUserReference = appleUserReference
        self.profilePhoto = profilePhoto
    }
}

extension User {
    convenience init?(ckRecord: CKRecord) {
        guard let username = ckRecord[UserStrings.usernameKey] as? String,
              let reportCount = ckRecord[UserStrings.reportCountKey] as? Int,
              let appleUserReference = ckRecord[UserStrings.appleUserReferenceKey] as? CKRecord.Reference
        else { return nil }
        
        var blockedUsers: [String] = []
        if let result = ckRecord[UserStrings.blockedUsersKey] as? [String] {
            blockedUsers = result
        }
        
        var foundPhoto: UIImage?
        if let photoAsset = ckRecord[UserStrings.photoAssetKey] as? CKAsset {
            do {
                let data = try Data(contentsOf: photoAsset.fileURL!)
                foundPhoto = UIImage(data: data)
            } catch {
                print("Couldn't transform asset to data")
            }
        }
        self.init(username: username, reportCount: reportCount, blockedUsers: blockedUsers, profilePhoto: foundPhoto, recordID: ckRecord.recordID, appleUserReference: appleUserReference)
    }
}

extension CKRecord {
    convenience init(user: User) {
        self.init(recordType: UserStrings.userKey, recordID: user.recordID)
        self.setValue(user.username, forKey: UserStrings.usernameKey)
        self.setValue(user.reportCount, forKey: UserStrings.reportCountKey)
        self.setValue(user.appleUserReference, forKey: UserStrings.appleUserReferenceKey)
        self.setValue(user.photoAsset, forKey: UserStrings.photoAssetKey)
    
        if user.blockedUsers.count > 0 {
            self.setValue(user.blockedUsers, forKey: UserStrings.blockedUsersKey)
        }
    }
}
