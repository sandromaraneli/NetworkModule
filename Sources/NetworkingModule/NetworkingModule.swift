import UIKit

public enum CustomErrors: Error, Sendable {
    case wrongResponse
    case statusCode
    case decodingError(String)
}

public final class NetworkService {
    
    public init() {}
    
    public func fetchData<T: Decodable>(urlString: String, modelType: T.Type, completion: @escaping @Sendable (T?, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil, CustomErrors.wrongResponse)
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) {  [weak self] data, response, error in
            print(Thread.current.isMainThread, "✅")
            
            if let error {
                print(error)
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(nil, CustomErrors.wrongResponse)
                }
                return
            }
            
            guard (200...299).contains(response.statusCode) else {
                DispatchQueue.main.async {
                    completion(nil, CustomErrors.statusCode)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, CustomErrors.wrongResponse)
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse, nil)
                }
            } catch let DecodingError.dataCorrupted(context) {
                print("Data corrupted: \(context)")
                DispatchQueue.main.async {
                    completion(nil, CustomErrors.decodingError("Data corrupted: \(context)"))
                }
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found: \(context)")
                DispatchQueue.main.async {
                    completion(nil, CustomErrors.decodingError("Key '\(key)' not found"))
                }
            } catch let DecodingError.typeMismatch(type, context) {
                print("Type '\(type)' mismatch: \(context)")
                DispatchQueue.main.async {
                    completion(nil, CustomErrors.decodingError("Type mismatch for '\(type)'"))
                }
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found: \(context)")
                DispatchQueue.main.async {
                    completion(nil, CustomErrors.decodingError("Value '\(value)' not found"))
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil, CustomErrors.decodingError(error.localizedDescription))
                }
            }
            
        }.resume()
    }
}
