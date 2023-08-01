//

import Foundation

struct RestaurantRoot: Decodable {
	let items: [RestaurantItem]
}

public struct RestaurantItem: Decodable, Equatable {
	let id: UUID
	let name: String
	let location: String
	let distance: Float
	let ratings: Int
	let parasols: Int

	public init(id: UUID, name: String, location: String, distance: Float, ratings: Int, parasols: Int) {
		self.id = id
		self.name = name
		self.location = location
		self.distance = distance
		self.ratings = ratings
		self.parasols = parasols
	}
}
