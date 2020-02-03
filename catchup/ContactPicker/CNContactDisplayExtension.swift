//
//  CNContactDisplayExtension.swift
//  catchup
//
//  Created by Sidhant Gandhi on 2/3/20.
//  Copyright © 2020 newnoetic. All rights reserved.
//

import Contacts

extension CNContact {
    var displayName: String {
        var nameFormatter: CNContactFormatter {
            let f = CNContactFormatter()
            f.style = .fullName
            return f
        }
        return nameFormatter.string(from: self) ?? "\(self.givenName) \(self.familyName)"
    }

}
