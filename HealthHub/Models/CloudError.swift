//
//  CloudError.swift
//  HealthHub
//
//  Created by Carlotta Chen on 2/17/22.
//

import Foundation

enum CloudError: LocalizedError {
    
    case ckError(Error)
    case noRecord
    case noPost
    
    var localizedDescription: String {
        switch self {
        case .ckError(let error):
            return "There was an error returned from cloudkit. Error: \(error)"
        case .noRecord:
            return "No record was returned from cloudkit"
        case .noPost:
            return "The post was not found"
        }
    }
}
