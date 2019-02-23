class Movie < ActiveRecord::Base
	def self.with_ratings(ratings)
		where(rating: ratings)
	end
end
