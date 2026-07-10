import Foundation
import Components

struct GeneralOBData: Codable {
    var demo: Int?
}


extension GeneralOBData {
    
    private static let cachedUrl = {
        Dir.documentsUrl.appending(path: "GeneralOBData.json")
    }()
    
    private static let cache = {
        if let data = try? Data(
            contentsOf: cachedUrl
        ), let res = try? JSONDecoder().decode(
            GeneralOBData.self,
            from: data
        ) {
            return res
        } else {
            return GeneralOBData()
        }
    }()
    
    static var shared: GeneralOBData = cache {
        didSet {
            do {
                let data = try JSONEncoder().encode(shared)
                try data.write(to: cachedUrl)
            } catch {
                print("data persistence error", error.localizedDescription)
            }
        }
    }
}
