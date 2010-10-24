require 'rubygems'
require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database=>":memory:")
class TestApp < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
    end
    create_table :rankings do |t|
      t.belongs_to :photo
      t.integer :score
    end
  end
end
TestApp.up

class Ranking < ActiveRecord::Base
  belongs_to :photo
  include Comparable
  def <=>(other); self.score <=> other.score end
  def to_i; score end
end
class Photo < ActiveRecord::Base
  has_many :rankings
  def self.highest_ranked
    Ranking.first(:order=>'score DESC').photo rescue nil
  end
  def highest_ranked
    rankings.any? ? rankings.max.score : nil
  end
end


require 'test/unit'
require 'machinist/active_record'
Photo.blueprint {}
Ranking.blueprint {|p| photo; score }