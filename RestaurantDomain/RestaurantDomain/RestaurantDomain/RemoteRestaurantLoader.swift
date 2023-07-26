//

import Foundation

protocol NetworkClient {
	func request(from url: URL)
}

final class RemoteRestaurantLoader {
	let url: URL
	let network: NetworkClient

	init(url: URL, networkClient: NetworkClient) {
		self.url = url
		self.network = networkClient
	}

	func load() {
		network.request(from: url)
	}
}
