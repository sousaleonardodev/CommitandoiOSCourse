//

import Foundation

protocol NetworkClient {
	func request(from url: URL, completion: @escaping (Error) -> Void)
}

final class RemoteRestaurantLoader {
	let url: URL
	let network: NetworkClient

	init(url: URL, networkClient: NetworkClient) {
		self.url = url
		self.network = networkClient
	}

	func load(completion: @escaping (Error) -> Void) {
		network.request(from: url) { error in
			completion(error)
		}
	}
}
