//
//  Comment.swift
//  HealthHub
//
//  Created by Carlotta Chen on 2/20/22.
//

import Foundation
import CloudKit

struct CommentStrings {
    static let recordType = "Comment"
    static let textKey = "text"
    fileprivate static let timestampKey = "timestamp"
    static let postReferenceKey = "post"
    static let usernameKey = "username"
    static let reportCountKey = "reportCount"
}

class Comment {
    let text: String
    let username: String
    let recordID: CKRecord.ID
    var timestamp: Date
    var reportCount: Int
    var postReference: CKRecord.Reference?
    
    init(username: String, text: String, timestamp: Date = Date(), reportCount: Int, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), postReference: CKRecord.Reference?) {
        self.text = text
        self.timestamp = timestamp
        self.reportCount = reportCount
        self.username = username
        self.recordID = recordID
        self.postReference = postReference
    }
}

extension Comment {
    
    convenience init?(ckRecord: CKRecord) {
        guard let text = ckRecord[CommentStrings.textKey] as? String,
              let timestamp = ckRecord[CommentStrings.timestampKey] as? Date,
              let reportCount = ckRecord[CommentStrings.reportCountKey] as? Int,
                let username = ckRecord[CommentStrings.usernameKey] as? String
        else { return nil }
        let postReference = ckRecord[CommentStrings.postReferenceKey] as? CKRecord.Reference
        
        self.init(username: username, text: text, timestamp: timestamp, reportCount: reportCount, recordID: ckRecord.recordID, postReference: postReference)
    }
}

extension Comment: Equatable {
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}

extension CKRecord {
    
    convenience init(comment: Comment) {
        self.init(recordType: CommentStrings.recordType, recordID: comment.recordID)
        self.setValuesForKeys([
            CommentStrings.textKey : comment.text,
            CommentStrings.timestampKey : comment.timestamp,
            CommentStrings.reportCountKey : comment.reportCount,
            CommentStrings.usernameKey: comment.username
        ])
        
        if let reference = comment.postReference {
            self.setValue(reference, forKey: CommentStrings.postReferenceKey)
        }
    }
}
