class Ranking
  include Comparable
  attr_accessor :rank
  def initialize(rank); @rank=rank end
  def <=>(other); self.rank < other.rank end
end
class Photo < ActiveRecord::Base
  attr_accessor :rankings
  def self.highest_ranked
    Photo.new.rankings << Ranking.new(5)
  end
  def highest_ranked
    @rankings.max
  end
end