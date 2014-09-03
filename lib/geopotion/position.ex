defmodule GeoPotion.Position do
  alias __MODULE__
  defstruct latitude: 0.0, longitude: 0.0, altitude: 0.0
  @moduledoc """
  """

  @doc """
  """
  @spec new(number,number,number) :: %Position{}
  def new(lat, lon, alt) when is_number(lat) and is_number(lon) and is_number(alt) do
    if validate(lat, lon) do
      %Position{latitude: lat, longitude: lon, altitude: alt }
    else
      nil
    end 
  end
  @doc """
  """
  @spec new(number,number) :: %Position{}
  def new(lat, lon) do
    new(lat, lon, 0.0)
  end
 
  def new(), do: new(0.0,0.0,0.0)

  defp validate(lat, lon) when (lat >= -90.0 and lat <= 90) and (lon >= -180.0 and lon <= 180) do true end
  defp validate(_lat, _lon) do false end

end
