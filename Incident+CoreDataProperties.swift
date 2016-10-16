//
//  Incident+CoreDataProperties.swift
//  projectsafe-coredata
//
//  Created by noah macri on 16/10/2016.
//  Copyright © 2016 noah macri. All rights reserved.
//

import Foundation
import CoreData

extension Incident {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Incident> {
        return NSFetchRequest<Incident>(entityName: "Incident");
    }

    @NSManaged public var activity: String?
    @NSManaged public var id: String?
    @NSManaged public var location: String?
    @NSManaged public var severity: String?
    @NSManaged public var title: String?
    @NSManaged public var year: String?
    @NSManaged public var tags: NSSet?

}

// MARK: Generated accessors for tags
extension Incident {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tags)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tags)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}
