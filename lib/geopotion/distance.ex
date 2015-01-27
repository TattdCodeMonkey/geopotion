defmodule GeoPotion.Distance do
  alias __MODULE__
  defstruct value: 0.0, units: :m
  @type t :: %__MODULE__{value: number, units: atom}
  @moduledoc """
    Structure for handling distance. Will hold the value and unit of measure for a distance. 
    Supported units are meters :m, kilometers :km, feet :ft, statute miles :sm and nautical miles :nm
  """  
  
  #constants
  @feet_per_meter 3.2808399
  @feet_per_centimeter 0.032808399
  @feet_per_statute_mile 5280
  @feet_per_kilometer 3280.8399
  @feet_per_inch 0.0833333333333333
  @feet_per_nautical_mile 6076.11549
  @inches_per_meter 39.3700787
  @inches_per_centimeter 0.393700787
  @inches_per_statute_mile 63360
  @inches_per_kilometer 39370.0787
  @inches_per_foot 12.0
  @inches_per_nautical_mile 72913.3858
  @statute_miles_per_meter 0.000621371192
  @statute_miles_per_centimeter 0.00000621371192
  @statute_miles_per_kilometer 0.621371192
  @statute_miles_per_inch 0.0000157828283
  @statute_miles_per_foot 0.000189393939
  @statute_miles_per_nautical_mile 1.15077945
  @nautical_miles_per_meter 0.000539956803
  @nautical_miles_per_centimeter 0.00000539956803
  @nautical_miles_per_kilometer 0.539956803
  @nautical_miles_per_inch 0.0000137149028
  @nautical_miles_per_foot 0.000164578834
  @nautical_miles_per_statute_mile 0.868976242
  @centimeters_per_statute_mile 160934.4
  @centimeters_per_kilometer 100000
  @centimeters_per_foot 30.48
  @centimeters_per_inch 2.54
  @centimeters_per_meter 100
  @centimeters_per_nautical_mile 185200
  @meters_per_statute_mile 1609.344
  @meters_per_centimeter 0.01
  @meters_per_kilometer 1000
  @meters_per_foot 0.3048
  @meters_per_inch 0.0254
  @meters_per_nautical_mile 1852
  @kilometers_per_meter 0.001
  @kilometers_per_centimeter 0.00001
  @kilometers_per_statute_mile 1.609344
  @kilometers_per_foot 0.0003048
  @kilometers_per_inch 0.0000254
  @kilometers_per_nautical_mile 1.852
  
  #new's
  @doc """
  Returns a %Distance with the given value and units. 

  iex>Distance.new(12.5, :nm)
  %Distance{value: 12.5, units: :nm}
  """
  @spec new(number,atom) :: t 
  def new(val, units) when is_number(val) do
    _new(val,units) 
  end  
  defp _new(val, :m), do: %Distance{value: val, units: :m}
  defp _new(val, :km), do: %Distance{value: val, units: :km}
  defp _new(val, :ft), do: %Distance{value: val, units: :ft}
  defp _new(val, :sm), do: %Distance{value: val, units: :sm}
  defp _new(val, :nm), do: %Distance{value: val, units: :nm}


  @doc """
  Returns a %Distance with the given value in meters
  
  iex>Distance.new(155.65)
  %Distance{value: 155.65, units: :m}
  """
  @spec new(number) :: t
  def new(val) when is_number(val) do
    new(val, :m)
  end

  @spec new() :: t
  def new(), do: new(0.0, :m)

  @doc """
  Returns a %Distance converted to the given unit

  iex>Distance.convert_to(%Distance{units: :m, value: 1500}, :km)
  %Distance{units: :km, value: 1.5}
  """
  @spec convert_to(t, atom) :: t
  def convert_to(%Distance{} = dist, unit) when is_atom(unit) do
    case unit do
      :m -> to_meters(dist)
      :km -> to_kilometers(dist)
      :ft -> to_feet(dist)
      :sm -> to_miles(dist)
      :nm -> to_nm(dist)
      _ -> nil # is this the best option here? should there be gueards instead like the new?
    end 
  end
  @doc """
  Takes a %Distance and converts the given value in any supported units and returns the value converted to meters

  iex>Distance.to_m(%Distance{value: 1, units: :km})
  %Distance{value: 1000, units: :m}
  """
  @spec to_m(t) :: t
  def to_m(%Distance{} = dist) do dist |> _toMeters end
  @doc """
  Takes a %Distance and converts the given value in any supported units and returns the value converted to meters

  iex>Distance.to_meters(%Distance{value: 50, units: :ft})
  %Distance{value: 15.24, units: :m}
  """
  @spec to_meters(t) :: t
  def to_meters(%Distance{} = dist) do dist |> _toMeters end
  defp _toMeters(%Distance{ value: val, units: :m})  do val |> new end
  defp _toMeters(%Distance{ value: val, units: :km}) do val * @meters_per_kilometer |> new end
  defp _toMeters(%Distance{ value: val, units: :ft}) do val * @meters_per_foot |> new end
  defp _toMeters(%Distance{ value: val, units: :sm}) do val * @meters_per_statute_mile |> new end
  defp _toMeters(%Distance{ value: val, units: :nm}) do val * @meters_per_nautical_mile |> new end

  @doc """
  Takes a %Distance and converts the given value in any supported units and returns the value converted to kilometers

  iex>Distance.to_kilometers(%Distance{value: 2500, units: :m})
  %Distance{value: 2.5, units: :km} 
  """
  @spec to_kilometers(t) :: t
  def to_kilometers(%Distance{} = dist) do dist |> _to_km end
  @doc """
  Takes a %Distance and converts the given value in any supported units and returns the value converted to kilometers

  iex>Distance.to_km(%Distance{value: 155, units: :nm})
  %Distance{value: 287.06, units: :km} 
  """
  @spec to_km(t) :: t
  def to_km(%Distance{} = dist) do dist |> _to_km end
  defp _to_km(%Distance{ value: val, units: :km}) do val |> new :km end
  defp _to_km(%Distance{ value: val, units: :m}) do val * @kilometers_per_meter |> new :km end
  defp _to_km(%Distance{ value: val, units: :ft}) do val * @kilometers_per_foot |> new :km end
  defp _to_km(%Distance{ value: val, units: :sm}) do val * @kilometers_per_statute_mile |> new :km end
  defp _to_km(%Distance{ value: val, units: :nm}) do val * @kilometers_per_nautical_mile |> new :km end

  @doc """
  Takes a %Distance and converts the given value in any supported units and returns the value converted to feet 

  iex>Distance.to_feet(%Distance{value: 1, units: :sm})
  %Distance{value: 5280, units: :ft} 
  """
  @spec to_feet(t) :: t
  def to_feet(%Distance{} = dist) do dist |> _toFeet end
  @doc """
  Takes a %Distance and converts the given value in any supported units and returns the value converted to feet 

  iex>Distance.to_ft(%Distance{value: 1, units: :sm})
  %Distance{value: 5280, units: :ft} 
  """
  @spec to_ft(t) :: t
  def to_ft(%Distance{} = dist) do dist |> _toFeet end
  defp _toFeet(%Distance{ value: val, units: :ft}) do val |> new :ft end
  defp _toFeet(%Distance{ value: val, units: :m})  do val * @feet_per_meter |> new :ft end
  defp _toFeet(%Distance{ value: val, units: :km}) do val * @feet_per_kilometer |> new :ft end
  defp _toFeet(%Distance{ value: val, units: :sm}) do val * @feet_per_statute_mile |> new :ft end
  defp _toFeet(%Distance{ value: val, units: :nm}) do val * @feet_per_nautical_mile |> new :ft end

  @doc """
  Takes a %Distance and converts the given value in any supported units and returns the value converted to statute miles 

  iex>Distance.to_miles(%Distance{value: 5280, units: :ft})
  %Distance{value: 1.0, units: :sm} 
  """
  @spec to_miles(t) :: t
  def to_miles(%Distance{} = dist) do dist |> _to_sm end
  @doc """
  Takes a %Distance and converts the given value in any supported units and returns the value converted to statute miles 

  iex>Distance.to_statute_miles(%Distance{value: 5280, units: :ft})
  %Distance{value: 1.0, units: :sm} 
  """
  @spec to_statute_miles(t) :: t
  def to_statute_miles(%Distance{} = dist) do dist |> _to_sm end
  @doc """
  Takes a %Distance and converts the given value in any supported units and returns the value converted to statute miles 

  iex>Distance.to_sm(%Distance{value: 5280, units: :ft})
  %Distance{value: 1.0, units: :sm} 
  """
  @spec to_sm(t) :: t
  def to_sm(%Distance{} = dist) do dist |> _to_sm end
  defp _to_sm(%Distance{value: val, units: :sm}) do val |> new :sm end
  defp _to_sm(%Distance{value: val, units: :m}) do val / @meters_per_statute_mile |> new :sm end
  defp _to_sm(%Distance{value: val, units: :km}) do val / @kilometers_per_statute_mile |> new :sm end
  defp _to_sm(%Distance{value: val, units: :ft}) do val / @feet_per_statute_mile |> new :sm end
  defp _to_sm(%Distance{value: val, units: :nm}) do val * @statute_miles_per_nautical_mile |> new :sm end

  @doc """
  Takes a %Distance and converts the given value in any supported units and returns the value converted to statute miles 

  iex>Distance.to_nautical_miles(%Distance{value: 1852, units: :m})
  %Distance{value: 1.0, units: :nm} 
  """
  @spec to_nautical_miles(t) :: t
  def to_nautical_miles(%Distance{} = dist) do dist |> _to_nm end
  @doc """
  Takes a %Distance and converts the given value in any supported units and returns the value converted to statute miles 

  iex>Distance.to_nm(%Distance{value: 1852, units: :m})
  %Distance{value: 1.0, units: :nm} 
  """
  @spec to_nm(t) :: t
  def to_nm(%Distance{} = dist) do dist |> _to_nm end
  defp _to_nm(%Distance{value: val, units: :nm}) do val |> new :nm end
  defp _to_nm(%Distance{value: val, units: :m}) do val / @meters_per_nautical_mile |> new :nm end
  defp _to_nm(%Distance{value: val, units: :km}) do val / @kilometers_per_nautical_mile |> new :nm end
  defp _to_nm(%Distance{value: val, units: :ft}) do val * @nautical_miles_per_foot |> new :nm end
  defp _to_nm(%Distance{value: val, units: :sm}) do val * @nautical_miles_per_statute_mile |> new :nm end

  #operations

# def add(%Distance{} = dist1, %Distance{} = dist2) do

# end

# def sub(%Distance{} = dist1, %Distance{} = dist2) do

# end
end
