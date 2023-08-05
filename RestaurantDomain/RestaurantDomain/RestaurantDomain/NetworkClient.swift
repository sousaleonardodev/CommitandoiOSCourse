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
		session.dataTask(with: url) { _, _, _ in

		}.resume()
	}
}
