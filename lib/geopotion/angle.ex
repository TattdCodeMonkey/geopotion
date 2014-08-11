defmodule Angle do
    defstruct value: 0.0, units: :degrees
    @moduledoc """
      Implements structure for holding a decimal angle value in degrees or radians
    """

    @one_radian 6.283185307179586     # 2 pi
    @degToRad 0.017453292519943295    #  pi / 180.0
    @radToDegree 57.29577951308232    # 180 /  pi
    
    @doc """
      Return an Angle with the given value and units

      iex>Angle.new(180.0, :degrees)
      %Angle{value: 180.0, units: :degrees}
    """
    def new(val, units) when is_number(val) and is_atom(units) and (units == :degrees or units == :radians) do
      %Angle{value: val, units: units}    
    end 

    @doc "Returns an Angle with 0.0 value in degrees"
    def new() do
      new(0.0, :degrees)
    end
    
    @doc """
      Returns an Angle with the given val in degrees
      iex>Angle.new(270.0)
      %Angle{value: 270.0, units: :degrees}
    """
    def new(val) when is_number(val) do
      new(val, :degrees) 
    end

    @doc """
      Takes an Angle and returns an angle with the value normalized to between 0 and 1 whole circle value. 360.0 for degrees of 2 pi for radians

      iex>Angle.normalize(%Angle{value: -90.0, units: :degrees})
      %Angle{value: 270.0, units: :degrees}
    """
    def normalize(%Angle{} = angle) do
      wholeUnit = get_wholeunit(angle.units)
      cond do
        angle.value >= 0 and angle.value < wholeUnit -> angle
        angle.value >= wholeUnit -> new(angle.value - wholeUnit, angle.units) |> normalize
        angle.value < 0 -> new(angle.value + wholeUnit, angle.units) |> normalize
      end
    end

    @doc "returns if the given Angle is normalized between 0 and one whole cirlce value. "
    def is_normalized(%Angle{} = angle) do
      angle.units 
        |> get_wholeunit 
        |> _is_normalized angle.value
    end
    
    @doc "Returns the given Angle converted to Degrees"
    def to_degrees(%Angle{value: val, units: :degrees}) do val |> new end
    def to_degrees(%Angle{value: val, units: :radians}) do val |> radians_to_degrees |> new end

    @doc "Returns the giver Angle converted to Radians"
    def to_radians(%Angle{value: val, units: :radians}) do val |> new :radians end
    def to_radians(%Angle{value: val, units: :degrees}) do val |> degrees_to_radians |> new :radians end

    @doc "Takes an Angle value in decimal degrees and converts it to decimal radians"
    def degrees_to_radians(value) when is_number(value) do
      value * @degToRad
    end

    @doc "Takes and Angle value in decimal radians and convert it to decimal degrees"
    def radians_to_degrees(value) when is_number(value) do
      value * @radToDegree
    end

    defp _is_normalized(wholeUnit, val) do
      if val >= 0 and val < wholeUnit do
        true
      else
        false
      end
    end

    defp get_wholeunit(units) do
      case units do
        :degrees -> 360
        :radians -> @one_radian
        _ -> 360
      end
    end

end 


