defmodule AngleTest do
  use ExUnit.Case, async: true
  alias GeoPotion.Angle
  doctest Angle

  @conv_delta 0.0000001

  test "angle - create new - 0", do: assert Angle.new(0) == %Angle{value: 0, units: :degrees}
  test "angle - create new", do: assert Angle.new(310) == %Angle{value: 310 , units: :degrees}
  test "angle - create new - 359.9", do: assert Angle.new(359.9) == %Angle{value: 359.9, units: :degrees}
  test "angle - create new - negative", do: assert Angle.new(-254) == %Angle{value: -254, units: :degrees}

  #test degrees are normailized correctly on creation 
  test "angle - degrees normalized - 370", do: assert Angle.new(370) |> Angle.normalize == %Angle{value: 10, units: :degrees}
  test "angle - degrees normalized - -10", do: assert Angle.new(-10) |> Angle.normalize == %Angle{value: 350, units: :degrees}
  test "angle - degrees normalized - 360", do: assert Angle.new(360) |> Angle.normalize == %Angle{value: 0, units: :degrees}
  
  test "angle - new degrees with atom - 310", do: assert Angle.new(310, :degrees) == %Angle{value: 310 , units: :degrees}
  test "angle - new degrees with atom - 0", do: assert Angle.new(0, :degrees) == %Angle{value: 0, units: :degrees}
  test "angle - new degrees with atom - float", do: assert Angle.new(359.9, :degrees) == %Angle{value: 359.9, units: :degrees}
  #test degrees are normailized correctly on creation 
  test "angle - new degrees with atom - 390", do: assert Angle.new(390, :degrees) |> Angle.normalize  == %Angle{value: 30, units: :degrees}
  test "angle - new degrees with atom - -20", do: assert Angle.new(-20, :degrees) |> Angle.normalize  == %Angle{value: 340, units: :degrees}
  test "angle - new degrees with atom - 360", do: assert Angle.new(360, :degrees) |> Angle.normalize  == %Angle{value: 0, units: :degrees}

  #test radians
  test "angle - new radians", do: assert Angle.new(0.0, :radians) == %Angle{value: 0.0, units: :radians}
  test "angle - new radians", do: assert Angle.new(:math.pi(), :radians) == %Angle{value: :math.pi(), units: :radians}

  #test radians are normalized properly on creation 
  test "angle - new radians normalized - -pi", do: assert Angle.new(-:math.pi(), :radians) |> Angle.normalize  == %Angle{value: :math.pi(), units: :radians}
  test "angle - new radians normalized - 2 pi", do: assert Angle.new(:math.pi()*2, :radians) |> Angle.normalize  == %Angle{value: 0.0, units: :radians}
  test "angle - new radians normalized - 3 pi", do: assert Angle.new(:math.pi()*3, :radians) |> Angle.normalize  == %Angle{value: :math.pi(), units: :radians}

  test "angle - is normalized - 0.0 degrees", do: assert Angle.is_normalized?(Angle.new(0.0)) == true    
  test "angle - is normalized - 180.0 degrees", do: assert Angle.is_normalized?(Angle.new(180.0)) == true    
  test "angle - is normalized - 0.0 radians", do: assert Angle.is_normalized?(Angle.new(0.0, :radians)) == true    
  test "angle - is normalized - pi, radians", do: assert Angle.is_normalized?(Angle.new(:math.pi, :radians)) == true    
  test "angle - is normalized - -pi, radians", do: assert Angle.is_normalized?(Angle.new(-:math.pi, :radians)) == false    
  test "angle - is normalized - 455.0 degrees", do: assert Angle.is_normalized?(Angle.new(455.0)) == false    
  test "angle - is normalized - -10.0 degrees", do: assert Angle.is_normalized?(Angle.new(-10.0)) == false    
  test "angle - is normalized - 4pi, radians", do: assert Angle.is_normalized?(Angle.new(4* :math.pi, :radians)) == false   

  test "angle - degrees to radians" do
   conversion = Angle.degrees_to_radians(180.0) 
   true = assert_in_delta(conversion,:math.pi(),@conv_delta)
  end

  test "angle  - to_radians - 180.0" do
   convAngle = Angle.to_radians(Angle.new(180.0))
   assert convAngle.units == :radians
   true = assert_in_delta(convAngle.value, :math.pi(), @conv_delta)
  end

  test "angle - radians to degrees" do
    conversion = Angle.radians_to_degrees(:math.pi())
    true = assert_in_delta(conversion,180.0,@conv_delta) 
  end

  test "angle - to_degrees - pi" do
    convAngle = Angle.to_degrees(Angle.new(:math.pi(), :radians))
    assert convAngle.units == :degrees
    true = assert_in_delta(convAngle.value, 180.0, @conv_delta)
  end

  test "angle - to degrees - no conversion needed" do
    original = Angle.new(270.0)
    conv = Angle.to_degrees(original)
    assert conv == original
  end

  test "angle - to radians - no conversion needed" do
    original = Angle.new(:math.pi() * 1.5, :radians)
    conv = Angle.to_radians(original)
    assert conv == original
  end
end
