defmodule AngleTest do
  use ExUnit.Case
  #doctest

  @conv_delta 0.0000001

  test "angle - create new degrees" do
    #test creation on Angle in degrees
    assert Angle.new(310) == %Angle{value: 310 , units: :degrees}
    assert Angle.new(0) == %Angle{value: 0, units: :degrees}
    assert Angle.new(359.9) == %Angle{value: 359.9, units: :degrees}
    assert Angle.new(-254) == %Angle{value: -254, units: :degrees}

  end

  test "angle - degrees normalized" do
    #test degrees are normailized correctly on creation 
    assert Angle.new(370) |> Angle.normalize == %Angle{value: 10, units: :degrees}
    assert Angle.new(-10) |> Angle.normalize == %Angle{value: 350, units: :degrees}
    assert Angle.new(360) |> Angle.normalize == %Angle{value: 0, units: :degrees}
  end
  
  test "angle - new degrees with atom" do
    assert Angle.new(310, :degrees) == %Angle{value: 310 , units: :degrees}
    assert Angle.new(0, :degrees) == %Angle{value: 0, units: :degrees}
    assert Angle.new(359.9, :degrees) == %Angle{value: 359.9, units: :degrees}
    #test degrees are normailized correctly on creation 
    assert Angle.new(370, :degrees) |> Angle.normalize  == %Angle{value: 10, units: :degrees}
    assert Angle.new(-10, :degrees) |> Angle.normalize  == %Angle{value: 350, units: :degrees}
    assert Angle.new(360, :degrees) |> Angle.normalize  == %Angle{value: 0, units: :degrees}
  end

  test "angle - new radians" do
    #test radians
    assert Angle.new(0.0, :radians) == %Angle{value: 0.0, units: :radians}
    assert Angle.new(:math.pi(), :radians) == %Angle{value: :math.pi(), units: :radians}
  end

  test "angle - new radians normalized" do
    #test radians are normalized properly on creation 
    assert Angle.new(-:math.pi(), :radians) |> Angle.normalize  == %Angle{value: :math.pi(), units: :radians}
    assert Angle.new(:math.pi()*2, :radians) |> Angle.normalize  == %Angle{value: 0.0, units: :radians}
    assert Angle.new(:math.pi()*3, :radians) |> Angle.normalize  == %Angle{value: :math.pi(), units: :radians}
  end
  
  test "angle - normalize" do
    assert Angle.new(370) |> Angle.normalize == %Angle{value: 10, units: :degrees}
  end

  test "angle - is normalized" do
    assert Angle.is_normalized(Angle.new(0.0)) == true    
    assert Angle.is_normalized(Angle.new(180.0)) == true    
    assert Angle.is_normalized(Angle.new(0.0, :radians)) == true    
    assert Angle.is_normalized(Angle.new(:math.pi, :radians)) == true    
    assert Angle.is_normalized(Angle.new(-:math.pi, :radians)) == false    
    assert Angle.is_normalized(Angle.new(455.0)) == false    
    assert Angle.is_normalized(Angle.new(-10.0)) == false    
    assert Angle.is_normalized(Angle.new(4* :math.pi, :radians)) == false   
  end

  test "angle - degrees to radians" do
   conversion = Angle.degrees_to_radians(180.0) 
   true = assert_in_delta(conversion,:math.pi(),@conv_delta)

   convAngle = Angle.to_radians(Angle.new(180.0))
   assert convAngle.units == :radians
   true = assert_in_delta(convAngle.value, :math.pi(), @conv_delta)
  end

  test "angle - radians to degrees" do
    conversion = Angle.radians_to_degrees(:math.pi())
    true = assert_in_delta(conversion,180.0,@conv_delta) 

    convAngle = Angle.to_degrees(Angle.new(:math.pi(), :radians))
    assert convAngle.units == :degrees
    true = assert_in_delta(convAngle.value, 180.0, @conv_delta)
  end

  test "angle - to degrees" do
    original = Angle.new(270.0)
    conv = Angle.to_degrees(original)
    assert conv == original
  end

  test "angle - to radians" do
    original = Angle.new(:math.pi() * 1.5, :radians)
    conv = Angle.to_radians(original)
    assert conv == original
  end
end
