//
//  Incident+CoreDataClass.swift
//  projectsafe-coredata
//
//  Created by noah macri on 6/10/2016.
//  Copyright © 2016 noah macri. All rights reserved.
//

import Foundation
import CoreData


public class Incident: NSManagedObject {
    func toString() -> String
    {
        return "ID: \(self.id!), Title: \(self.title!), Activity: \(self.activity!), Severity: \(self.severity!), Year: \(self.year!), Location: \(self.location!), Hazards: TODO"
    }
}
