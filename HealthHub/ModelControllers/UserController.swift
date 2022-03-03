//
//  UserController.swift
//  HealthHub
//
//  Created by Carlotta Chen on 2/14/22.
//

import UIKit
import CloudKit

class UserController {
    
    static let shared = UserController()
    var currentUser: User?
    let publicDB = CKContainer.default().publicCloudDatabase
    
    func createUser(with username: String, profilePhoto: UIImage?, completion: @escaping (Bool) -> Void) {
        fetchAppleUserReference { reference in
            guard let reference = reference else { completion(false) ; return }
            let reportCount = 0
            
            let newUser = User(username: username, reportCount: reportCount, profilePhoto: profilePhoto, appleUserReference: reference)
            let record = CKRecord(user: newUser)
            
            self.publicDB.save(record) { (record, error) in
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    completion(false)
                    return
                }
                guard let record = record,
                      let savedUser = User(ckRecord: record) else { completion(false) ; return }
                self.currentUser = savedUser
                print("Created user: \(record.recordID.recordName) successfully")
                completion(true)
            }
        }
    }
    
    func updatePhoto(_ user: User, completion: @escaping (Result<User, CloudError>) -> Void) {
    }
    
    func update(_ user: User, completion: @escaping (Result<String, CloudError>) -> Void) {
        let record = CKRecord(user: user)
        
        let operation = CKModifyRecordsOperation(recordsToSave: [record])
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        
        operation.modifyRecordsResultBlock = { result in
            switch result {
            case .success():
                print("Updated record")
                return completion(.success("Successfully updated user"))
            case .failure(let error):
                print("Not Updated")
                return completion(.failure(.ckError(error)))
            }
        }
        publicDB.add(operation)
    }
    
    func fetchUser(completion: @escaping (Bool) -> Void) {
        fetchAppleUserReference { [self] reference in
            guard let reference = reference else { completion(false) ; return }
            
            let predicate = NSPredicate(format: "%K == %@", argumentArray: [UserStrings.appleUserReferenceKey, reference])
            let query = CKQuery(recordType: UserStrings.userKey, predicate: predicate)
            let operation = CKQueryOperation(query: query)
            
            operation.recordMatchedBlock = { (error, result) in
                switch result {
                case .success(let record):
                    guard let foundUser = User(ckRecord: record)
                    else { completion(false) ; return }
                    
                    self.currentUser = foundUser

                    print("Fetched User: \(record.recordID.recordName) successfully")
                    completion(true)
                case .failure(_):
                    return completion(false)
                }
            }
            publicDB.add(operation)
        }
    }
    
    func fetchUsername(with username: String, completion: @escaping (Result<[User], CloudError>) -> Void) {
        let predicate = NSPredicate(format: "%K == %@", UserStrings.usernameKey, username)
        let query = CKQuery(recordType: UserStrings.userKey, predicate: predicate)
        var operation = CKQueryOperation(query: query)
        var fetchedUsers: [User] = []
        
        operation.recordMatchedBlock = { (_, result) in
            switch result {
            case .success(let record):
                guard let fetchedUser = User(ckRecord: record) else {
                    return completion(.failure(.noRecord))
                }
                fetchedUsers.append(fetchedUser)
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
                    return completion(.success(fetchedUsers))
                }
            case .failure(let error):
                return completion(.failure(.ckError(error)))
            }
        }
        publicDB.add(operation)
    }
    
    func fetchAppleUserReference(completion: @escaping (CKRecord.Reference?) -> Void) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
                return
            }
            guard let recordID = recordID else { completion(nil) ; return }
            let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            completion(reference)
        }
    }
}
