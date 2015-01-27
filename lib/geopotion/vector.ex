defmodule GeoPotion.Vector do
  alias :math, as: Math
  alias GeoPotion.Distance
  alias GeoPotion.Angle
  alias __MODULE__

  @type position_map :: %{
    latitude: number,
    longitude: number
  }

  @type t :: %__MODULE__{
    azimuth: Angle.t,
    distance: Distance.t
  }
  defstruct azimuth: Angle.new, distance: Distance.new

  @moduledoc """
  """

  @epsg_wgs1984 7030
  @equitorial_radius_wgs1984 6378137
  @polar_radius_wgs1984 6356752.3142
  @flattening_wgs1984 0.0033528106718309896
  @inverse_flattening_wgs1984 298.257223563
  @pi 3.141592653589793

  @calc_iterations 100

  @spec calculate(position_map, position_map) :: t
  def calculate(%{latitude: from_lat,longitude: from_lon}, %{latitude: to_lat, longitude: to_lon}) do
    _vincenty_calc(from_lat, from_lon, to_lat, to_lon)
  end

  @spec distance_over_ground(position_map, position_map) :: Distance.t
  def distance_over_ground(%{latitude: from_lat,longitude: from_lon}, %{latitude: to_lat, longitude: to_lon}) do
    %{distance: result} = _vincenty_calc(from_lat, from_lon, to_lat, to_lon)
    result
  end

  @spec bearing_to(position_map, position_map) :: Angle.t 
  def bearing_to(%{latitude: from_lat,longitude: from_lon}, %{latitude: to_lat, longitude: to_lon}) do
    %{azimuth: result} = _vincenty_calc(from_lat, from_lon, to_lat, to_lon)
    result
  end

  defp _distance_over_ground(lat1, lon1, lat2, lon2) do
    # From: http://www.mathworks.com/matlabcentral/files/8607/vdist.m
    # this implementation was ported from DotSpatial library
    # this is the aproximated fast calculation over the more accurate slow one.
    # Should come back later and implement the full accurate version as well.
    # -TCM 8-16-14

    {rLat1,rLon1, rLat2, rLon2} = _getRads({lat1, lon1, lat2, lon2})

    dLat = abs(rLat2 - rLat1)
    dLon = abs(rLon2 - rLon1)

    l = (rLat1 + rLat2) * 0.5
    a = @equitorial_radius_wgs1984
    b = @polar_radius_wgs1984
    e = Math.sqrt(1 - (b* b)  / (a * a))
    r1 = (a * (1 - (e * e))) / Math.pow((1 - (e * e) * (Math.sin(l) * Math.sin(l))), 3 * 0.5)
    r2 = a / Math.sqrt(1 - (e * e) * (Math.sin(l) * Math.sin(l)))
    ravg = (r1 * (dLat / (dLat + dLon))) + (r2 * (dLon / (dLat + dLon)))
    sinlat = Math.sin(dLat * 0.5)
    sinlon = Math.sin(dLon * 0.5)
    a2 = Math.pow(sinlat, 2) + Math.cos(rLat1) * Math.cos(rLat2) * Math.pow(sinlon, 2)
    c = 2 * Math.asin(min(1, Math.sqrt(a2)))

    ravg * c |> Distance.new
  end

  defp _vincenty_calc(lat1, lon1, lat2, lon2) when lat1 == lat2 and lon1 == lon2 do
    %__MODULE__{azimuth: Angle.new(0.0), distance: Distance.new(0.0) }
  end


  defp _vincenty_calc(lat1, lon1, lat2, lon2) do
    {_,rLon1, _, rLon2} = radians = _getRads({lat1, lon1, lat2, lon2})

    [l,u1, u2|rest] = prep = _itt_prep(radians)

    [lamda|_] = ittResults = _itt_calc(0,l, prep, [l])

    dist = _calc_distance(ittResults)

    fwdAz = _calc_azimuth([lamda,u1,u2])
    
    %__MODULE__{azimuth: fwdAz, distance: dist}
  end

  defp _getRads({lat1, lon1, lat2, lon2}) do
    rLat1 = Angle.degrees_to_radians(lat1)
    rLat2 = Angle.degrees_to_radians(lat2)
    rLon1 = Angle.degrees_to_radians(lon1)
    rLon2 = Angle.degrees_to_radians(lon2)

    {rLat1,rLon1,rLat2,rLon2}
  end

  defp _itt_prep(radians) do
    {lat1, lon1, lat2, lon2} = radians
    u1 = Math.atan((1-@flattening_wgs1984) * Math.tan(lat1))
    u2 = Math.atan((1-@flattening_wgs1984) * Math.tan(lat2))

#   rLon1 = rLon1/(2*Math.pi)
#   rLon2 = rLon2/(2*Math.pi)

    l = abs(lon2 - lon1)

    [l, u1, u2, lon1, lon2]
  end

  defp _itt_calc(0, _lDiff, [lamda|rest], _) when lamda > @pi do
    newlamda = 2 * Math.pi - lamda
    _itt_calc(0,newlamda,[newlamda,rest],[newlamda])
  end

  defp _itt_calc(count, lamdaDif,state, vals) when count == 0 or (lamdaDif > 0.1e-6 and count <= @calc_iterations) do
    [l, u1, u2|_] = state
    [lamda| _rest] = vals

    a = Math.pow((Math.cos(u2) * Math.sin(lamda)), 2)
    b = Math.pow((Math.cos(u1) * Math.sin(u2) - Math.sin(u1) * Math.cos(u2) * Math.cos(lamda)),2)
    sinsigma = Math.sqrt(a + b)

    cossigma = Math.sin(u1) * Math.sin(u2) + Math.cos(u1) * Math.cos(u2) * Math.cos(lamda)

    sigma = Math.atan2(sinsigma,cossigma)
    alpha = Math.cos(u1) * Math.cos(u2) * Math.sin(lamda) / Math.sin(sigma)
      |> Math.asin
    cos2SigmaM = Math.cos(sigma) - 2.0 * Math.sin(u1) * Math.sin(u2) / Math.pow(Math.cos(alpha), 2)

    c = @flattening_wgs1984 / 16 * Math.pow(Math.cos(alpha),2) * (4 + @flattening_wgs1984 * (4 - 3 * Math.pow(Math.cos(alpha),2)))

    newlamda = l + (1 - c) * @flattening_wgs1984 * Math.sin(alpha) *
            (sigma + c * Math.sin(sigma) *
            (cos2SigmaM + c * Math.cos(sigma) *
            (-1 + 2 * Math.pow(cos2SigmaM, 2))))
    if(newlamda > Math.pi) do
      newlamda = Math.pi
      lamda = Math.pi
    end

    lamdaDiff = abs(newlamda - lamda)

    _itt_calc(count+1,lamdaDiff,state,[newlamda, alpha, sigma, cos2SigmaM])
  end

  defp _itt_calc(_count, _lamdaDiff, state, vals) do
    [_,_,_,lon1,lon2] = state
    [lamda|rest] = vals
    newlamda = abs(lamda)
    if(Math.sin(lon2 - lon1) * Math.sin(lamda) < 0) do
      newlamda = -newlamda
    end
    [newlamda|rest]
  end

  defp _calc_distance([_, alpha, sigma, cos2SigmaM]) do
    a = @equitorial_radius_wgs1984
    b = @polar_radius_wgs1984
    distU2 = (alpha |> Math.cos |> Math.pow 2) * ((Math.pow(a,2) - Math.pow(b,2)) / Math.pow(b,2))
    aa = 1 + distU2 / 16384 * (4096 + distU2 * (-768 + distU2 *(320 - 175 * distU2)))
    bb = distU2 / 1024 * (256 + distU2 * (-128 + distU2 * (74 - 47 * distU2)))
    deltaSigma = bb * Math.sin(sigma) * (cos2SigmaM + bb / 4 * (Math.cos(sigma) * (-1 + 2 *
      Math.pow(cos2SigmaM, 2)) - bb / 6 * cos2SigmaM * (-3 + 4 * (sigma |> Math.sin |> Math.pow 2)) *
      (-3 + 4 * Math.pow(cos2SigmaM,2))))

    s = b * aa * (sigma - deltaSigma)
    s |> Distance.new
  end

  defp _calc_azimuth([lamda, u1, u2]) do
    numer = Math.cos(u2) * Math.sin(lamda)
    denom = Math.cos(u1) * Math.sin(u2) - Math.sin(u1) * Math.cos(u2) * Math.cos(lamda)

    a12 = Math.atan2(numer, denom)

    if(a12 < 0) do
      a12 = a12 + (2* Math.pi)
    end

    a12 |> Angle.radians_to_degrees |> Angle.new
  end
end
