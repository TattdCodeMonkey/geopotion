defmodule GeoPotion.Vector do
  alias :math, as: Math
  alias GeoPotion.Position
  alias GeoPotion.Distance
  alias GeoPotion.Angle

  @moduledoc """
  """

  @epsg_wgs1984 7030
  @equitorial_radius_wgs1984 6378137
  @polar_radius_wgs1984 6356752.3142
  @flattening_wgs1984 0.0033528106718309896
  @inverse_flattening_wgs1984 298.257223563

  @calc_iterations 100

  def calculate(%{latitude: _,longitude: _} = from, %{latitude: _, longitude: _} = to) do
    _vincentyCalc(from.latitude, from.longitude, to.latitude, to.longitude)
  end

  def distanceOverGround(%{latitude: _,longitude: _} = from, %{latitude: _, longitude: _} = to) do
    %{distance: result} = _vincentyCalc(from.latitude, from.longitude, to.latitude, to.longitude)
    result
  end

  def bearingTo(%{latitude: _, longitude: _} = from, %{latitude: _,longitude: _} = to) do
    %{azimuth: result} = _vincentyCalc(from.latitude, from.longitude, to.latitude, to.longitude)
    result
  end

  defp _distanceOverGround(lat1, lon1, lat2, lon2) do
    # From: http://www.mathworks.com/matlabcentral/files/8607/vdist.m
    # this implementation was ported from DotSpatial library
    # this is the aproximated fast calculation over the more accurate slow one.
    # Should come back later and implement the full accurate version as well.
    # -TCM 8-16-14

    rLat1 = Angle.degrees_to_radians(lat1)
    rLat2 = Angle.degrees_to_radians(lat2)
    rLon1 = Angle.degrees_to_radians(lon1)
    rLon2 = Angle.degrees_to_radians(lon2)

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

    ravg * c
  end

  defp _vincentyCalc(lat1, lon1, lat2, lon2) when lat1 == lat2 and lon1 == lon2 do
    %{azimuth: Angle.new(0.0), distance: Distance.new(0.0) }
  end


  defp _vincentyCalc(lat1, lon1, lat2, lon2) do
    rLat1 = Angle.degrees_to_radians(lat1)
    rLat2 = Angle.degrees_to_radians(lat2)
    rLon1 = Angle.degrees_to_radians(lon1)
    rLon2 = Angle.degrees_to_radians(lon2)

    a = @equitorial_radius_wgs1984
    b = @polar_radius_wgs1984
    f = @flattening_wgs1984
    u1 = Math.atan((1-f) * Math.tan(rLat1))
    u2 = Math.atan((1-f) * Math.tan(rLat2))

#   rLon1 = rLon1/(2*Math.pi)
#   rLon2 = rLon2/(2*Math.pi)

    l = abs(rLon2 - rLon1)

    if(l > Math.pi) do
      l = 2 * Math.pi - l
    end

    [lamda, alpha, sigma, cos2SigmaM] = _ittCalc(0,l, {u1, u2, f, l}, [l])

    lamda = abs(lamda)

    if(Math.sin(rLon2 - rLon1) * Math.sin(lamda) < 0) do
      lamda = -lamda
    end

    #calculations for the distance
    distU2 = (alpha |> Math.cos |> Math.pow 2) * ((Math.pow(a,2) - Math.pow(b,2)) / Math.pow(b,2))
    aa = 1 + distU2 / 16384 * (4096 + distU2 * (-768 + u2 *(320 - 175 * distU2)))
    bb = distU2 / 1024 * (256 + distU2 * (-128 + distU2 * (74 - 47 * distU2)))
    deltaSigma = bb * Math.sin(sigma) * (cos2SigmaM + bb / 4 * (Math.cos(sigma) * (-1 + 2 *
      Math.pow(cos2SigmaM, 2)) - bb / 6 * cos2SigmaM * (-3 + 4 * (sigma |> Math.sin |> Math.pow 2)) *
      (-3 + 4 * Math.pow(cos2SigmaM,2))))

    s = b * aa * (sigma - deltaSigma)
    dist = s |> Distance.new

    #calculations for forward azimuth
    numer = Math.cos(u2) * Math.sin(lamda)
    denom = Math.cos(u1) * Math.sin(u2) - Math.sin(u1) * Math.cos(u2) * Math.cos(lamda)

    a12 = Math.atan2(numer, denom)

    if(a12 < 0) do
      a12 = a12 + (2* Math.pi)
    end

    fwdAz = a12 |> Angle.radians_to_degrees |> Angle.new


    %{azimuth: fwdAz, distance: dist}
  end

  defp _ittCalc(count, lamdaDif,state, vals) when count == 0 or (lamdaDif > 0.1e-6 and count <= @calc_iterations) do
    {u1, u2, f, l} = state
    [lamda| _rest] = vals

    a = Math.pow((Math.cos(u2) * Math.sin(lamda)), 2)
    b = Math.pow((Math.cos(u1) * Math.sin(u2) - Math.sin(u1) * Math.cos(u2) * Math.cos(lamda)),2)
    sinsigma = Math.sqrt(a + b)

    cossigma = Math.sin(u1) * Math.sin(u2) + Math.cos(u1) * Math.cos(u2) * Math.cos(lamda)

    sigma = Math.atan2(sinsigma,cossigma)
    alpha = Math.cos(u1) * Math.cos(u2) * Math.sin(lamda) / Math.sin(sigma)
      |> Math.asin
    cos2SigmaM = Math.cos(sigma) - 2.0 * Math.sin(u1) * Math.sin(u2) / Math.pow(Math.cos(alpha), 2)

    c = f / 16 * Math.pow(Math.cos(alpha),2) * (4 + f * (4 - 3 * Math.pow(Math.cos(alpha),2)))

    newlamda = l + (1 - c) * f * Math.sin(alpha) *
            (sigma + c * Math.sin(sigma) *
            (cos2SigmaM + c * Math.cos(sigma) *
            (-1 + 2 * Math.pow(cos2SigmaM, 2))))
    if(newlamda > Math.pi) do
      newlamda = Math.pi
      lamda = Math.pi
    end

    lamdaDiff = abs(newlamda - lamda)

    _ittCalc(count+1,lamdaDiff,state,[newlamda, alpha, sigma, cos2SigmaM])
  end

  defp _ittCalc(_count, _lamda, state, vals), do: vals

end
