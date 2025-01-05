//
//  IsotopeRespository.swift
//  nonoptimized
//
//  Created by Samuel Owino on 21/12/2024.
//
import Foundation
import RealmSwift
struct IsotopeRespository {
    static func countIsotopes() async -> Int{
        guard let database = BaseRepository.getDatabase() else { return 0 }
        let result: Int = database.objects(IsotopeEntity.self).count
        return result
    }
    static func getIsotopes() async -> [IsotopeModel] {
        guard let database = BaseRepository.getDatabase() else { return [] }
        // The call to 'filter()' here is bogus!
        // I have used extractValues() for realm objects to convert
        // from Result<[IsotopeEntity]> to [IsotopeEntity] to avoid 'Realm accessed from incorrect thread' errors
        // but it doesn't seem to work anymore
        // There should be a more elegant way to make this conversion...to be done
        let result: [IsotopeEntity] = database.objects(IsotopeEntity.self).freeze().filter { !$0.name.isEmpty }
        print("getIsotopes : \(result.count)")
        return await withTaskGroup(of: IsotopeModel.self){ group in
            for entity in result {
                group.addTask {
                    return IsotopeModel(
                        id: entity.id,
                        name: entity.name,
                        atomicNumber: entity.atomicNumber,
                        neutronCount: entity.neutronCount,
                        massNumber: entity.massNumber,
                        halfLife: entity.halfLife,
                        decayMode: entity.decayMode,
                        isotopicAbundance: entity.isotopicAbundance,
                        stability: entity.stability
                    )
                }
            }
            var result = [IsotopeModel]()
            for await model in group {
                result.append(model)
            }
            result.sort {$0.massNumber > $1.massNumber}
            return result
        }
    }
    static func saveIsotopes(_ isotopes: [IsotopeModel]) async {
        print("saveIsotopes() : \(isotopes.count)")
        guard let database = BaseRepository.getDatabase() else { return }
        do {
            try database.write {
                let entities: [IsotopeEntity] = isotopes.map { $0.toEntity()}
                print("Finished propagating Isotopes...")
                database.add(entities)
            }
        } catch {
            print(error.localizedDescription)
        }
        print("Finished storing Isotopes...")
    }
    static func deleteAll() async {
        do {
            guard let database = BaseRepository.getDatabase() else { return }
            try database.write {
                database.objects(IsotopeEntity.self)
                    .forEach { database.delete($0)}
            }
        } catch {
            print("Error in  delete \(error.localizedDescription)")
        }
    }
}
struct BaseRepository {
    static func getDatabase() -> Realm? {
        do {
            let databaseConfig = IsotopeDatabaseConfig()
            return try databaseConfig.getDatabase()
        } catch {
            return nil
        }
    }
}
class IsotopeEntity: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var name: String
    @Persisted var decayMode: String
    @Persisted var stability: String
    @Persisted var atomicNumber: Int
    @Persisted var neutronCount: Int
    @Persisted var massNumber: Int
    @Persisted var halfLife: TimeInterval
    @Persisted var atomicWeight: Double
    @Persisted var isotopicAbundance: Double
    @Persisted var group: Int
    @Persisted var period: Int
    @Persisted var isodescription: String
    @Persisted var imageURL: String
}
class IsotopeDatabaseConfig{
    init(){}
    func getDatabase() throws -> Realm {
        var database: Realm
        let configuration = Realm.Configuration(schemaVersion: 1,
                                                migrationBlock: nil,
                                                deleteRealmIfMigrationNeeded: false)
        Realm.Configuration.defaultConfiguration = configuration
        database = try Realm()
        print(database.configuration.fileURL!.path)
        return database
    }
}
