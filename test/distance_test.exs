defmodule DistanceTest do
  use ExUnit.Case, async: true
  alias GeoPotion.Distance
  doctest Distance
  
  @conv_delta 0.0001

  test "dist - new" do
    assert Distance.new(50) == %Distance{value: 50, units: :m}
    assert Distance.new(50, :m) == %Distance{value: 50, units: :m}
    assert Distance.new(100, :km) == %Distance{value: 100, units: :km}
    assert Distance.new(345, :ft) == %Distance{value: 345, units: :ft}
    assert Distance.new(50, :sm) == %Distance{value: 50, units: :sm}
    assert Distance.new(5, :nm) == %Distance{value: 5, units: :nm}
  end  

  test "dist - to meters" do
    assert Distance.to_meters(%Distance{value: 100, units: :m}) == %Distance{value: 100, units: :m}
    assert Distance.to_meters(%Distance{value: 1, units: :km}) == %Distance{value: 1000, units: :m}
    
    # decimal conversion
    assert Distance.to_meters(%Distance{value: 100, units: :ft}) == %Distance{value: 30.48, units: :m}   
    assert Distance.to_meters(%Distance{value: 1, units: :sm}) == %Distance{value: 1609.344, units: :m}   
    assert Distance.to_meters(%Distance{value: 1, units: :nm}) == %Distance{value: 1852, units: :m}   
  end

  test "dist - to kilometers" do
    assert Distance.to_km(%Distance{value: 1.0, units: :km}) == %Distance{value: 1.0, units: :km}
    assert Distance.to_km(%Distance{value: 1000, units: :m}) == %Distance{value: 1.0, units: :km}
    assert Distance.to_km(%Distance{value: 1000, units: :nm}) == %Distance{value: 1852.0, units: :km}
    
    #decimal conversion
    #feet to km
    ftToKm = Distance.to_km(%Distance{value: 2500, units: :ft})
    assert ftToKm.units == :km
    true = assert_in_delta(ftToKm.value, 0.762, @conv_delta)
    
    #sm to km
    smToKm = Distance.to_km(%Distance{value: 100.0, units: :sm})
    assert smToKm.units == :km
    true = assert_in_delta(smToKm.value,160.9344, @conv_delta)
  end

  test "dist - to feet" do
    assert Distance.to_ft(%Distance{value: 500, units: :ft}) == %Distance{value: 500, units: :ft}
    assert Distance.to_ft(%Distance{value: 1, units: :sm}) == %Distance{value: 5280, units: :ft}
    
    #decimal conversions
    mToFt = 300 |> Distance.new |> Distance.to_ft
    assert mToFt.units == :ft
    true = assert_in_delta(mToFt.value, 984.25197, @conv_delta)

    kmToFt = %Distance{ value: 7.62, units: :km} |> Distance.to_ft
    assert kmToFt.units == :ft
    true = assert_in_delta(kmToFt.value, 25000, @conv_delta)

    nmToFt = Distance.new(25, :nm) |> Distance.to_ft
    assert nmToFt.units == :ft
    true = assert_in_delta(nmToFt.value, 151902.88725, @conv_delta)
  end

  test"dist - to miles" do
    assert Distance.to_sm(%Distance{value: 100.0, units: :sm}) == %Distance{value: 100.0, units: :sm}
    assert Distance.to_sm(%Distance{value: 5280, units: :ft}) == %Distance{value: 1.0, units: :sm}
    
    kmToSm = Distance.new(25.0, :km) |> Distance.to_sm 
    assert kmToSm.units == :sm
    true = assert_in_delta(kmToSm.value, 15.534279, @conv_delta)
   
    mToSm = 3400.0 |> Distance.new |> Distance.to_sm
    assert mToSm.units == :sm
    true = assert_in_delta(mToSm.value, 2.112662 , @conv_delta)

    nmToSm = Distance.new(200, :nm) |> Distance.to_sm
    assert nmToSm.units == :sm
    true = assert_in_delta(nmToSm.value, 230.15589, @conv_delta)
  end

  test "dist - to nautical miles" do
    assert Distance.to_nm(%Distance{value: 152.34, units: :nm}) == %Distance{value: 152.34, units: :nm}

    assert Distance.to_nm(%Distance{value: 1.852, units: :km}) == %Distance{value: 1.0, units: :nm}
    assert Distance.to_nm(%Distance{value: 3704, units: :m}) == %Distance{value: 2.0, units: :nm}

    smToNm = 230.15589 |> Distance.new(:sm) |> Distance.to_nm
    assert smToNm.units == :nm
    true = assert_in_delta(smToNm.value, 200, @conv_delta)

    ftToNm = 3038.057745 |> Distance.new(:ft) |> Distance.to_nautical_miles
    assert ftToNm.units == :nm
    true = assert_in_delta(ftToNm.value, 0.5, @conv_delta)
  end
end
