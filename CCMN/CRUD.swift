//
//  CRUD.swift
//  CCMN
//
//  Created by Olga SKULSKA on 11/22/18.
//  Copyright © 2018 Olga SKULSKA. All rights reserved.
//

import Foundation
import CoreData

class CRUD{
    
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    
    func loadFloorsData() -> [Floor] {
        
        var flrArr = [Floor]()
        let request : NSFetchRequest<Floor> = Floor.fetchRequest()
        do {
            flrArr = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        return flrArr
    }
    
    
    func getFloorsData(floor : String) -> Floor?{
        
        let fetchRequest : NSFetchRequest<Floor> = Floor.fetchRequest()
        let predicate = NSPredicate(format: "floorName == %@", floor)
        var selectedContact: Floor? = nil
        
        fetchRequest.predicate = predicate
        do {
            let floorInfo = try context.fetch(fetchRequest)
            selectedContact = floorInfo.first!
        } catch {
            print("No contacts found")
        }
        return selectedContact
    }
    
    
    func saveData() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context\(error)")
        }
    }

    
    func removeAllFloorData() {
        
        let request : NSFetchRequest<Floor> = Floor.fetchRequest()
        request.includesPropertyValues = false
        
        do {
            var cityArray = [Floor]()
            cityArray = try context.fetch(request)
            if !cityArray.isEmpty{
                for item in cityArray {
                    context.delete(item)
                }
                try context.save()
            }
        } catch{
            print("Error removing context\(error)")
        }
    }
    
    
    func getUserForFloor(userFloor : String) -> [ActiveUser] {

        var user = [ActiveUser]()
        let fetchRequest : NSFetchRequest<ActiveUser> = ActiveUser.fetchRequest()
        let predicate = NSPredicate(format: "currentFloor CONTAINS %@", userFloor)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = false
        do {
            user = try context.fetch(fetchRequest)
        } catch {
            print("No contacts found")
        }
        return user
    }
    
    
    func removeAllUserData() {
        
        let request : NSFetchRequest<ActiveUser> = ActiveUser.fetchRequest()
        request.includesPropertyValues = false
        do {
            var cityArray = [ActiveUser]()
            cityArray = try context.fetch(request)
            if !cityArray.isEmpty{
                for item in cityArray {
                    context.delete(item)
                }
                try context.save()
            }
        } catch {
            print("Error removing context\(error)")
        }
    }
}
