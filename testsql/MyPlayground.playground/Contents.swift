//: Playground - noun: a place where people can play

import SQLite
import Foundation
/*
print("starting")

let db = try Connection("db.sqlite3")
print("connected")
let users = Table("users")
let id = Expression<Int64>("id")
let name = Expression<String?>("name")
let email = Expression<String>("email")
func getExp () -> Expression<Bool>{
    return id == 1
}

/*try db.run(users.create { t in
    t.column(id, primaryKey: true)
    t.column(name)
    t.column(email, unique: true)
})
// CREATE TABLE "users" (
//     "id" INTEGER PRIMARY KEY NOT NULL,
//     "name" TEXT,
//     "email" TEXT NOT NULL UNIQUE
// )*/

var insert = users.insert(name <- "Alice", email <- "alice@mac.com")
var rowid = try db.run(insert)
// INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')

for user in try db.prepare(users) {
    print("id: \(user[id]), name: \(user[name]), email: \(user[email])")
    // id: 1, name: Optional("Alice"), email: alice@mac.com
}
// SELECT * FROM "users"

let alice = users.filter(id == rowid)

try db.run(alice.update(email <- email.replace("mac.com", with: "me.com")))
// UPDATE "users" SET "email" = replace("email", 'mac.com', 'me.com')
// WHERE ("id" = 1)

try db.run(alice.delete())
// DELETE FROM "users" WHERE ("id" = 1)

try db.scalar(users.count) // 0
// SELECT count(*) FROM "users

insert = users.insert(name <- "Alice", email <- "alice@mac.com")
rowid = try db.run(insert)
insert = users.insert(name <- "AJamese", email <- "james@mac.com")
rowid = try db.run(insert)

let james = users.filter( id == 1 || id == 2)
let john = users.filter(getExp())
print ("Completed")
*/
/*
print (Date())


func getDate (date: Date) ->Int {
    let cal = Calendar.current
    let hour =  cal.component(.hour, from: date)
    var newDate = cal.date(bySettingHour: 18, minute: 0, second: 0,  of: date)!
    if hour < 18 {
        newDate = cal.date(byAdding: .day, value: -1, to: newDate)!
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"
    dateFormatter.timeZone = cal.timeZone
    let dateString = dateFormatter.string(from: newDate)
    return Int(dateString)!
}
 func  formatDate(date dateInt: Int) -> String {
    // from an int to a usable date format string
    let date = getCalDate(date: dateInt)
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .none
    dateFormatter.timeZone = Calendar.current.timeZone
    print ("ready")
    return dateFormatter.string(from: date)
}
 func getCalDate (date dateInt: Int) -> Date {
    // from an integer to a date object
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"
    dateFormatter.timeZone = Calendar.current.timeZone
    print("convert")
    return dateFormatter.date(from: String(dateInt))!
}


print (getDate(date: Date()))

*/
//let x = CheckInController.getCalDate(Date())
