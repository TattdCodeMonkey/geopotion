defmodule Distance do
  alias Distance
  defstruct value: 0.0, units: :m
  @moduledoc """
    Structure for handling distance. Will hold the value and unit of measure for a distance. 
    Supported units are meters :m, kilometers :km, feet :ft, statute miles :sm and nautical miles :nm
  """  
  #new's

  def new(val, units) when is_number(val) and is_atom(units) and (units == :m or units == :km or units == :ft or units == :sm or units == :nm) do
    %Distance{value: val, units: units}
  end  

  def new(val) when is_number(val) do
    new(val, :m)
  end

  def to_m(%Distance{} = dist) do dist |> to_meters end
  def to_meters(%Distance{ value: val, units: :m})  do val |> new end
  def to_meters(%Distance{ value: val, units: :km}) do val * 1000 |> new end
  def to_meters(%Distance{ value: val, units: :ft}) do val * 0.3048 |> new end
  def to_meters(%Distance{ value: val, units: :sm}) do val * 1609.347 |> new end
  def to_meters(%Distance{ value: val, units: :nm}) do val * 1852 |> new end

  def to_kilometers(%Distance{} = dist) do dist |> to_km end
  def to_km(%Distance{ value: val, units: :km}) do val |> new :km end
  def to_km(%Distance{ value: val, units: :m}) do val / 1000.0 |> new :km end
  def to_km(%Distance{ value: val, units: :ft}) do val * 0.0003048 |> new :km end
  def to_km(%Distance{ value: val, units: :sm}) do val * 1.609347 |> new :km end
  def to_km(%Distance{ value: val, units: :nm}) do val * 1.852 |> new :km end

  def to_feet(%Distance{} = dist) do dist |> to_ft end
  def to_ft(%Distance{ value: val, units: :ft}) do val |> new :ft end
  def to_ft(%Distance{ value: val, units: :m})  do val * 3.2808 |> new :ft end
  def to_ft(%Distance{ value: val, units: :km}) do val * 3280.8399 |> new :ft end
  def to_ft(%Distance{ value: val, units: :sm}) do val * 5280 |> new :ft end
  def to_ft(%Distance{ value: val, units: :nm}) do val * 6076.1155 |> new :ft end

  def to_miles(%Distance{} = dist) do dist |> to_sm end
  def to_statutemiless(%Distance{} = dist) do dist |> to_sm end
  def to_sm(%Distance{value: val, units: :sm}) do val |> new :sm end
  def to_sm(%Distance{value: val, units: :m}) do val * 0.0006214 |> new :sm end
  def to_sm(%Distance{value: val, units: :km}) do val * 0.6214 |> new :sm end
  def to_sm(%Distance{value: val, units: :ft}) do val / 5280 |> new :sm end
  def to_sm(%Distance{value: val, units: :nm}) do val * 1.15078 |> new :sm end

  def to_nauticalmiles(%Distance{} = dist) do dist |> to_nm end
  def to_nm(%Distance{value: val, units: :nm}) do val |> new :nm end
  def to_nm(%Distance{value: val, units: :m}) do val / 1852 |> new :nm end
  def to_nm(%Distance{value: val, units: :km}) do val / 1.852 |> new :nm end
  def to_nm(%Distance{value: val, units: :ft}) do val * 0.0001645 |> new :nm end
  def to_nm(%Distance{value: val, units: :sm}) do val * 0.8684 |> new :nm end

  #operations

  def add(%Distance{} = dist1, %Distance{} = dist2) do

  end

  def sub(%Distance{} = dist1, %Distance{} = dist2) do

  end
end
