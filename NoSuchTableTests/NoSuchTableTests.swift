//
//  NoSuchTableTests.swift
//  NoSuchTableTests
//
//  Created by Richard Hult on 2022-12-07.
//

import XCTest
import GRDB
@testable import NoSuchTable

struct ModelInTest: Codable, Identifiable {
    static var databaseTableName: String = "testModel"
    let id: String
}
extension ModelInTest: FetchableRecord, TableRecord, PersistableRecord { }

private func createDatabaseInTest() throws -> DatabaseWriter {
    let database: DatabaseWriter
    let path = documentsURL().appendingPathComponent(UUID().uuidString).path
    database = try DatabasePool(path: path)

    return database
}

private func migrateInTest(database: DatabaseWriter) throws {
    var migrator = DatabaseMigrator()

    migrator.registerMigration("v1") { db in
        try db.execute(sql: v1)
    }

    try migrator.migrate(database)
}

private func writeModelInTest(database: DatabaseWriter) throws {
    try database.write { db in
        let model = ModelInTest(id: "id")
        try model.save(db)
    }
}

final class NoSuchTableTests: XCTestCase {

    // OK
    func test1() throws {
        let database = try createDatabaseInTest()
        try migrateInTest(database: database)
        try writeModelInTest(database: database)
    }

    // OK
    func test2() throws {
        let database = try createDatabaseInApp()
        try migrateInApp(database: database)
        try writeModelInApp(database: database)
    }

    // "Database was not used on the correct thread"
    func test3() throws {
        let database = try createDatabaseInApp()
        try migrateInTest(database: database)
        try writeModelInApp(database: database)
    }

    // "Database was not used on the correct thread"
    func test4() throws {
        let database = try createDatabaseInApp()
        try migrateInApp(database: database)

        try database.write { db in
            try saveModelInApp(db)
        }
    }

    // "SQLite error 1: no such table: testModel"
    func test5() throws {
        let database = try createDatabaseInTest()
        try migrateInTest(database: database)

        try database.write { db in
            try saveModelInApp(db)
        }
    }

}
