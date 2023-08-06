//

import Foundation

public protocol NetworkClient {
	typealias NetworkResult = Result<(Data, HTTPURLResponse), Error>
	func request(from url: URL, completion: @escaping (NetworkResult) -> Void)
}

final class NetworkService: NetworkClient {
	private let session: URLSession

	init(session: URLSession) {
		self.session = session
	}

	func request(from url: URL, completion: @escaping (NetworkResult) -> Void) {
		session.dataTask(with: url) { data, response, error in
			if let error {
				completion(.failure(error))
			} else if let data, let response = response as? HTTPURLResponse {
				completion(.success((data, response)))
			} else {
				let error = NSError(domain: "Unexpected error", code: -1)
				completion(.failure(error))
			}
		}.resume()
	}
}
