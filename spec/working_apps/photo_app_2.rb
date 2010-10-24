class Ranking
  include Comparable
  def initialize(rank); @rank=rank end
  def <=>(other); self.rank < other.rank end
end
class Photo < ActiveRecord::Base
  composed_of :ranking, :mapping => %w(rank rank)
  def self.highest_ranked
    Photo.create(:rank => 5)
  end
  def highest_ranked
    @rankings.max
  end
end