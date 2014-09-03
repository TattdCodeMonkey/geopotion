defmodule GeoPotion.Angle do
    defstruct value: 0.0, units: :degrees
    alias __MODULE__
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
    @spec new(number, atom) :: %Angle{}
    def new(val, units) when is_number(val) and is_atom(units) and (units == :degrees or units == :radians) do
      %Angle{value: val, units: units}    
    end 

    @doc "Returns an Angle with 0.0 value in degrees"
    @spec new() :: %Angle{}
    def new() do 0.0 |> new :degrees end
    
    @doc """
      Returns an Angle with the given val in degrees
      iex>Angle.new(270.0)
      %Angle{value: 270.0, units: :degrees}
    """
    @spec new(number) :: %Angle{}
    def new(val) when is_number(val) do val |> new :degrees end

    @doc """
      Takes an Angle and returns an angle with the value normalized to between 0 and 1 whole circle value. 360.0 for degrees of 2 pi for radians

      iex>Angle.normalize(%Angle{value: -90.0, units: :degrees})
      %Angle{value: 270.0, units: :degrees}
    """
    @spec normalize(%Angle{}) :: %Angle{}
    def normalize(%Angle{value: val, units: :degrees}) do val |> _normDegrees |> new end
    @spec normalize(%Angle{}) :: %Angle{}
    def normalize(%Angle{value: val, units: :radians}) do val |> _normRadians |> new :radians end 
    
    defp _normDegrees(value) when value >= 360 do value - 360 |> _normDegrees end
    defp _normDegrees(value) when value < 0 do value + 360 |> _normDegrees end
    defp _normDegrees(value) when value in 0..360 do value end
    defp _normRadians(value) when value >= @one_radian do value - @one_radian |> _normRadians end
    defp _normRadians(value) when value < 0 do value + @one_radian |> _normRadians end
    defp _normRadians(value) when value in 0..@one_radian do value end
    
    @doc "returns if the given Angle is normalized between 0 and one whole cirlce value. "
    @spec is_normalized(%Angle{}) :: atom
    def is_normalized(%Angle{value: val, units: :degrees}) when val >= 0 and val < 360 do true end
    @spec is_normalized(%Angle{}) :: atom
    def is_normalized(%Angle{value: _val, units: :degrees}) do false end
    @spec is_normalized(%Angle{}) :: atom
    def is_normalized(%Angle{value: val, units: :radians}) when val >= 0 and val < @one_radian do true end
    @spec is_normalized(%Angle{}) :: atom
    def is_normalized(%Angle{value: _val, units: :radians}) do false end 

    @doc "Returns the given Angle converted to Degrees"
    @spec to_degrees(%Angle{}) :: %Angle{}
    def to_degrees(%Angle{value: val, units: :degrees}) do val |> new end
    @spec to_degrees(%Angle{}) :: %Angle{}
    def to_degrees(%Angle{value: val, units: :radians}) do val |> radians_to_degrees |> new end

    @doc "Returns the giver Angle converted to Radians"
    @spec to_radians(%Angle{}) :: %Angle{}
    def to_radians(%Angle{value: val, units: :radians}) do val |> new :radians end
    @spec to_radians(%Angle{}) :: %Angle{}  
    def to_radians(%Angle{value: val, units: :degrees}) do val |> degrees_to_radians |> new :radians end

    @doc "Takes an Angle value in decimal degrees and converts it to decimal radians"
    @spec degrees_to_radians(number) :: number
    def degrees_to_radians(value) when is_number(value) do value * @degToRad end

    @doc "Takes and Angle value in decimal radians and convert it to decimal degrees"
    @spec radians_to_degrees(number) :: number
    def radians_to_degrees(value) when is_number(value) do value * @radToDegree end

 end 


