defmodule PositionTest do
  use ExUnit.Case, async: true
  alias GeoPotion.Position
  doctest Position

  test "position - new" do
    assert Position.new(35.145,-86.256) == %Position{altitude: 0.0, latitude: 35.145, longitude: -86.256 }
    assert Position.new(-65.345, 123.6543, 234.654) == %Position{altitude: 234.654, latitude: -65.345, longitude: 123.6543 }
  
    assert Position.new(-123.445, 45.123) == nil
  end
end
