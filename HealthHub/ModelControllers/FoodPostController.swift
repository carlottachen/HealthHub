//
//  FoodPostController.swift
//  HealthHub
//
//  Created by Carlotta Chen on 2/27/22.
//

import UIKit
import CloudKit

class FoodPostController {
    static let shared = FoodPostController()
    var foodPosts: [FoodPost] = []
    let publicDB = CKContainer.default().publicCloudDatabase
    
    func addComment(text: String, foodPost: FoodPost, completion: @escaping (Result<Comment?, CloudError>) -> Void) {
        
        guard let username = UserController.shared.currentUser?.username else { return }
        let reportCount = 0
        
        let postReference = CKRecord.Reference(recordID: foodPost.recordID, action: .deleteSelf)
        let comment = Comment(username: username, text: text, reportCount: reportCount, postReference: postReference)
        foodPost.comments.append(comment)
        let record = CKRecord(comment: comment)
        
        publicDB.save(record) { (record, error) in
            if let error = error {
                print("Comment Not Saved")
                return completion(.failure(.ckError(error)))
            }
            guard let record = record else {
                return completion(.failure(.noRecord))
            }
            let comment = Comment(ckRecord: record)
            completion(.success(comment))
            print("Comment saved successfully")
        }
    }
    
    func fetchComments(for foodPost: FoodPost, completion: @escaping (Result<[Comment]?, CloudError>) -> Void) {
        let postReference = foodPost.recordID
        let predicate = NSPredicate(format: "%K == %@", CommentStrings.postReferenceKey, postReference)
        let query = CKQuery(recordType: CommentStrings.recordType, predicate: predicate)
        var operation = CKQueryOperation(query: query)
        var fetchedComments: [Comment] = []

        operation.recordMatchedBlock = { (_, result) in
            switch result {
            case .success(let record):
                guard let fetchedComment = Comment(ckRecord: record) else {
                    return completion(.failure(.noRecord))
                }
                fetchedComments.append(fetchedComment)
            case .failure(let error):
                return completion(.failure(.ckError(error)))
            }
        }
        
        operation.queryResultBlock = { result in
            switch result {
            case .success(let cursor):
                if let cursor = cursor {
                    let nextOperation = CKQueryOperation(cursor: cursor)
                    nextOperation.queryResultBlock = operation.queryResultBlock
                    nextOperation.recordMatchedBlock = operation.recordMatchedBlock
                    operation = nextOperation
                    self.publicDB.add(nextOperation)
                } else {
                    return completion(.success(fetchedComments))
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.ckError(error)))
            }
        }
        publicDB.add(operation)
    }
    
    func savePost(with text: String, photo: UIImage?, completion: @escaping (Bool) -> Void) {
        guard let currentUser = UserController.shared.currentUser,
        let username = UserController.shared.currentUser?.username
        else { completion(false) ; return }
        let reportCount = 0
        let reference = CKRecord.Reference(recordID: currentUser.recordID, action: .deleteSelf)
        let newPost = FoodPost(username: username, body: text, reportCount: reportCount, foodPhoto: photo, userReference: reference)
        let postRecord = CKRecord(foodPost: newPost)
        
        publicDB.save(postRecord) { (record, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            guard let record = record,
                  let savedPost = FoodPost(ckRecord: record)
            else { completion(false) ; return }
            
            print("Saved Food Post")
            self.foodPosts.insert(savedPost, at: 0)
            completion(true)
        }
    }
    
    func fetchPosts(completion: @escaping (Result<[FoodPost]?, CloudError>) -> Void) {
        guard let currentUser = UserController.shared.currentUser else { return }
        
        let predicate = NSPredicate(format: "NOT(username IN %@)", argumentArray: [currentUser.blockedUsers])
        let query = CKQuery(recordType: FoodStrings.recordTypeKey, predicate: predicate)
        var operation = CKQueryOperation(query: query)
        var fetchedPosts: [FoodPost] = []
        
        operation.recordMatchedBlock = { (_, result) in
            switch result {
            case .success(let record):
                guard let fetchedPost = FoodPost(ckRecord: record) else {
                    return completion(.failure(.noPost))
                }
                fetchedPosts.append(fetchedPost)
            case .failure(let error):
                return completion(.failure(.ckError(error)))
            }
        }
        
        operation.queryResultBlock = { result in
            switch result {
            case .success(let cursor):
                if let cursor = cursor {
                    let nextOperation = CKQueryOperation(cursor: cursor)
                    nextOperation.queryResultBlock = operation.queryResultBlock
                    nextOperation.recordMatchedBlock = operation.recordMatchedBlock
                    operation = nextOperation
                    self.publicDB.add(nextOperation)
                } else {
                    let sortedPosts = fetchedPosts.sorted(by: { $0.timestamp > $1.timestamp })
                    return completion(.success(sortedPosts))
                }
            case .failure(let error):
                return completion(.failure(.ckError(error)))
            }
        }
        publicDB.add(operation)
    }
    
    func fetchMyPosts(completion: @escaping (Result<[FoodPost]?, CloudError>) -> Void) {
        
        let userReference = UserController.shared.currentUser?.recordID
        let predicate = NSPredicate(format: "%K == %@", FoodStrings.userReferenceKey, userReference!)
        let query = CKQuery(recordType: FoodStrings.recordTypeKey, predicate: predicate)
        var operation = CKQueryOperation(query: query)
        var fetchedPosts: [FoodPost] = []
        
        operation.recordMatchedBlock = { (_, result) in
            switch result {
            case .success(let record):
                guard let fetchedPost = FoodPost(ckRecord: record) else {
                    return completion(.failure(.noPost))
                }
                fetchedPosts.append(fetchedPost)
            case .failure(let error):
                return completion(.failure(.ckError(error)))
            }
        }
        
        operation.queryResultBlock = { result in
            switch result {
            case .success(let cursor):
                if let cursor = cursor {
                    let nextOperation = CKQueryOperation(cursor: cursor)
                    nextOperation.queryResultBlock = operation.queryResultBlock
                    nextOperation.recordMatchedBlock = operation.recordMatchedBlock
                    operation = nextOperation
                    self.publicDB.add(nextOperation)
                } else {
                    return completion(.success(fetchedPosts))
                }
            case .failure(let error):
                return completion(.failure(.ckError(error)))
            }
        }
        publicDB.add(operation)
    }
    
    func update(_ foodPost: FoodPost, completion: @escaping (Result<FoodPost, CloudError>) -> Void) {
        let record = CKRecord(foodPost: foodPost)
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record])
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        
        operation.modifyRecordsResultBlock = { result in
            switch result {
            case .success():
                print("Updated record")
                return completion(.success(foodPost))
            case .failure(let error):
                print("Not Updated")
                return completion(.failure(.ckError(error)))
            }
        }
        publicDB.add(operation)
    }
    
    func delete(_ foodPost: FoodPost, completion: @escaping (Bool) -> Void) {
        let operation = CKModifyRecordsOperation(recordIDsToDelete: [foodPost.recordID])
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsResultBlock = { result in
            switch result {
            case .success():
                print("Post deleted")
                return completion(true)
            case .failure(_):
                print("Issue attempting to delete post")
                return completion(false)
            }
        }
        publicDB.add(operation)
    }

    // exact same function as in FitPostController
    func deleteComment(_ comment: Comment, completion: @escaping (Bool) -> Void) {
        let operation = CKModifyRecordsOperation( recordIDsToDelete: [comment.recordID])
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsResultBlock = { result in
            switch result {
            case .success():
                print("Comment deleted")
                return completion(true)
            case .failure(_):
                print("Issue deleting comment")
                return completion(false)
            }
        }
        publicDB.add(operation)
    }
    
    func blockUserOfPost(for foodPost: FoodPost, completion: (Bool) -> Void) {
        guard let currentUser = UserController.shared.currentUser?.username else { return }
        let postUsername = foodPost.username
        
        UserController.shared.fetchUsername(with: postUsername) { result in
            switch result {
            case .success(let user):
                print(user[0].username)
                user[0].blockedUsers.append(currentUser)
                UserController.shared.update(user[0]) { result in
                    switch result {
                    case .success(_):
                        print("Blocked user")
                        print(user[0].blockedUsers)
                    case .failure(_):
                        print("Issue blocking user")
                    }
                }
            case .failure(_):
                print("error")
            }
        }
    }
}
