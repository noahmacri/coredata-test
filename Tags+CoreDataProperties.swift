//
//  Tags+CoreDataProperties.swift
//  projectsafe-coredata
//
//  Created by noah macri on 16/10/2016.
//  Copyright © 2016 noah macri. All rights reserved.
//

import Foundation
import CoreData


extension Tags {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Tags> {
        return NSFetchRequest<Tags>(entityName: "Tags");
    }

    @NSManaged public var name: String?

}
