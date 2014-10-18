defmodule DistanceTest do
  use ExUnit.Case, async: true
  alias GeoPotion.Distance
  doctest Distance
  
  @conv_delta 0.0001

  test "dist - new - 50 (auto meters)", do: assert Distance.new(50) == %Distance{value: 50, units: :m}
  test "dist - new - 50, meters", do: assert Distance.new(50, :m) == %Distance{value: 50, units: :m}
  test "dist - new - 100, km", do: assert Distance.new(100, :km) == %Distance{value: 100, units: :km}
  test "dist - new - 345, feet", do: assert Distance.new(345, :ft) == %Distance{value: 345, units: :ft}
  test "dist - new - 50, statute miles", do: assert Distance.new(50, :sm) == %Distance{value: 50, units: :sm}
  test "dist - new - 5, nautical miles", do: assert Distance.new(5, :nm) == %Distance{value: 5, units: :nm}

  test "dist - to meters - 100m", do: assert Distance.to_meters(%Distance{value: 100, units: :m}) == %Distance{value: 100, units: :m}
  test "dist - to meters - 1km", do: assert Distance.to_meters(%Distance{value: 1, units: :km}) == %Distance{value: 1000, units: :m}
  test "dist - to meters - 100ft", do: assert Distance.to_meters(%Distance{value: 100, units: :ft}) == %Distance{value: 30.48, units: :m}   
  test "dist - to meters - 1sm", do: assert Distance.to_meters(%Distance{value: 1, units: :sm}) == %Distance{value: 1609.344, units: :m}   
  test "dist - to meters - 1nm", do: assert Distance.to_meters(%Distance{value: 1, units: :nm}) == %Distance{value: 1852, units: :m}   

  test "dist - to kilometers - km", do: assert Distance.to_km(%Distance{value: 1.0, units: :km}) == %Distance{value: 1.0, units: :km}
  test "dist - to kilometers - m", do: assert Distance.to_km(%Distance{value: 1000, units: :m}) == %Distance{value: 1.0, units: :km}
  test "dist - to kilometers - nm", do: assert Distance.to_km(%Distance{value: 1000, units: :nm}) == %Distance{value: 1852.0, units: :km}
  
  test "dist - to kilometers - ft" do  
    ftToKm = Distance.to_km(%Distance{value: 2500, units: :ft})
    assert ftToKm.units == :km
    true = assert_in_delta(ftToKm.value, 0.762, @conv_delta)
  end

  test "dist - to kilometers - sm " do  
    smToKm = Distance.to_km(%Distance{value: 100.0, units: :sm})
    assert smToKm.units == :km
    true = assert_in_delta(smToKm.value,160.9344, @conv_delta)
  end

  test "dist - to feet - ft", do: assert Distance.to_ft(%Distance{value: 500, units: :ft}) == %Distance{value: 500, units: :ft}
  test "dist - to feet - sm", do: assert Distance.to_ft(%Distance{value: 1, units: :sm}) == %Distance{value: 5280, units: :ft}
  test "dist - to feet - m" do  
    mToFt = 300 |> Distance.new |> Distance.to_ft
    assert mToFt.units == :ft
    true = assert_in_delta(mToFt.value, 984.25197, @conv_delta)
  end
  test "dist - to feet - km" do
    kmToFt = %Distance{ value: 7.62, units: :km} |> Distance.to_ft
    assert kmToFt.units == :ft
    true = assert_in_delta(kmToFt.value, 25000, @conv_delta)
  end
  test "dist - to feet - nm" do 
    nmToFt = Distance.new(25, :nm) |> Distance.to_ft
    assert nmToFt.units == :ft
    true = assert_in_delta(nmToFt.value, 151902.88725, @conv_delta)
  end

  test "dist - to miles - sm", do: assert Distance.to_sm(%Distance{value: 100.0, units: :sm}) == %Distance{value: 100.0, units: :sm}
  test "dist - to miles - ft", do: assert Distance.to_sm(%Distance{value: 5280, units: :ft}) == %Distance{value: 1.0, units: :sm}
  test "dist - to miles - km" do
    kmToSm = Distance.new(25.0, :km) |> Distance.to_sm 
    assert kmToSm.units == :sm
    true = assert_in_delta(kmToSm.value, 15.534279, @conv_delta)
  end
  test "dist - to miles - m" do  
    mToSm = 3400.0 |> Distance.new |> Distance.to_sm
    assert mToSm.units == :sm
    true = assert_in_delta(mToSm.value, 2.112662 , @conv_delta)
  end
  test "dist - to miles - nm" do
    nmToSm = Distance.new(200, :nm) |> Distance.to_sm
    assert nmToSm.units == :sm
    true = assert_in_delta(nmToSm.value, 230.15589, @conv_delta)
  end

  test "dist - to nautical miles - nm", do: assert Distance.to_nm(%Distance{value: 152.34, units: :nm}) == %Distance{value: 152.34, units: :nm}
  test "dist - to nautical miles - km", do: assert Distance.to_nm(%Distance{value: 1.852, units: :km}) == %Distance{value: 1.0, units: :nm}
  test "dist - to nautical miles - m", do: assert Distance.to_nm(%Distance{value: 3704, units: :m}) == %Distance{value: 2.0, units: :nm}
  test "dist - to nautical miles - sm" do
    smToNm = 230.15589 |> Distance.new(:sm) |> Distance.to_nm
    assert smToNm.units == :nm
    true = assert_in_delta(smToNm.value, 200, @conv_delta)
  end
  test "dist - to nautical miles - ft" do
    ftToNm = 3038.057745 |> Distance.new(:ft) |> Distance.to_nautical_miles
    assert ftToNm.units == :nm
    true = assert_in_delta(ftToNm.value, 0.5, @conv_delta)
  end
end
