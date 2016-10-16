//
//  Incident+CoreDataProperties.swift
//  projectsafe-coredata
//
//  Created by noah macri on 6/10/2016.
//  Copyright © 2016 noah macri. All rights reserved.
//

import Foundation
import CoreData


extension Incident {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Incident> {
        return NSFetchRequest<Incident>(entityName: "Incident");
    }

    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var activity: String?
    @NSManaged public var severity: String?
    @NSManaged public var year: String?
    @NSManaged public var location: String?
    @NSManaged public var hazards: [String]?
}
