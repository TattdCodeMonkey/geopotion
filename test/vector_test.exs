defmodule VectorTest do
  use ExUnit.Case, async: true
  alias GeoPotion.Position
  alias GeoPotion.Vector
  doctest Vector

  def getNashvillePos() do Position.new(36.151366, -86.796530) end
  def getAshevillePos() do Position.new(35.594736, -82.554802) end

  test "distance over ground - nash to ashe" do
    #Nashville - 36.151366, -86.796530
    #Asheville - 35.594736, -82.554802
    #DoG =  387.8207 km

    nashville = getNashvillePos() 
    asheville = getAshevillePos()
    dist1 = Vector.distanceOverGround(nashville,asheville)
    dist2 = Vector.distanceOverGround(asheville,nashville)

    true = assert_in_delta(dist1.value, 387.8207, 0.001)
    true = assert_in_delta(dist1.value, dist2.value, 0.00001)
  end

  test "bearing to - nash to ___" do
    #36.166471, -86.771285
    #53.19 - 2.83 km
    nash1 = getNashvillePos()
    nash2 = Position.new(36.166471, -86.771285)

    bearing = Vector.bearingTo(nash1, nash2)

    true = assert_in_delta(bearing.value, 53.571197,0.0001)
  end

  #TODO  Add tests for all 4 quadrants, corssing anti meridian etc.
end
