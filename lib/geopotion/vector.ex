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
  @inverse_flattening_wgs1984 298.257223563
  
  @calc_iterations 20

  def distanceOverGround(%Position{} = from, %Position{} = to) do
    _distanceOverGround(from.latitude, from.longitude, to.latitude, to.longitude)
    |> Distance.new :km
  end

  def bearingTo(%Position{} = from, %Position{} = to) do
    _bearingTo(from.latitude, from.longitude, to.latitude, to.longitude)
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
    aKm = @equitorial_radius_wgs1984 |> Distance.new |> Distance.to_km
    bKm = @polar_radius_wgs1984 |> Distance.new |> Distance.to_km
    a = aKm.value
    b = bKm.value
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

  defp _bearingTo(lat1, lon1, lat2, lon2) when lat1 == lat2 and lon1 == lon2 do
    Angle.new(0.0)
  end

  
  defp _bearingTo(lat1, lon1, lat2, lon2) do
    rLat1 = Angle.degrees_to_radians(lat1)
    rLat2 = Angle.degrees_to_radians(lat2)
    rLon1 = Angle.degrees_to_radians(lon1)
    rLon2 = Angle.degrees_to_radians(lon2)

    #rLonDiff = abs(rLon2 - rLon1)
    f = (@equitorial_radius_wgs1984 - @polar_radius_wgs1984) / @equitorial_radius_wgs1984
    u1 = Math.atan((1-f) * Math.tan(rLat1))
    u2 = Math.atan((1-f) * Math.tan(rLat2))

#   rLon1 = rLon1/(2*Math.pi)
#   rLon2 = rLon2/(2*Math.pi)

    l = abs(rLon2 - rLon1)

    if(l > Math.pi) do
      l = 2 * Math.pi - l
    end

    {_,_,_,_,lamda,_alpha} = _calc(0,l, {u1, u2, f, l, l, 0})
    
    goodLamda = abs(lamda)

    if(Math.sin(rLon2 - rLon1) * Math.sin(goodLamda) < 0) do
      goodLamda = -goodLamda
    end

    numer = Math.cos(u2) * Math.sin(goodLamda)
    denom = Math.cos(u1) * Math.sin(u2) - Math.sin(u1) * Math.cos(u2) * Math.cos(goodLamda)

    a12 = Math.atan2(numer, denom)

    if(a12 < 0) do
      a12 = a12 + (2* Math.pi)
    end

    a12 |> Angle.radians_to_degrees |> Angle.new
  end

  defp _calc(count, lamdaDif, vals) when count == 0 or (lamdaDif > 0.1e-6 and count <= @calc_iterations) do
    {u1, u2, f, l, lamda, _} = vals
    oldlamda = lamda

    sinsigma = _sinSigma(vals)
    cossigma = _cosSigma(vals)
    sigma = Math.atan2(sinsigma,cossigma)
    alpha = Math.cos(u1) * Math.cos(u2) * Math.sin(lamda) / Math.sin(sigma)
      |> Math.asin
    cos2SigmaM = Math.cos(sigma) - 2.0 * Math.sin(u1) * Math.sin(u2) / Math.pow(Math.cos(alpha), 2)
    
    c = f / 16 * Math.pow(Math.cos(alpha),2) * (4 + f * (4 - 3 * Math.pow(Math.cos(alpha),2))) 
 
    lamda = l + (1 - c) * f * Math.sin(alpha) *
            (sigma + c * Math.sin(sigma) *
            (cos2SigmaM + c * Math.cos(sigma) *
            (-1 + 2 * Math.pow(cos2SigmaM, 2))))
    if(lamda > Math.pi) do
      oldlamda = Math.pi
      lamda = Math.pi
    end
    
    lamdaDiff = abs(lamda - oldlamda)

    _calc(count+1,lamdaDiff,{u1,u2,f,l,lamda, alpha})  

  end
  defp _calc(_count, _lamda, vals), do: vals
  defp _sinSigma(vals) do
    {u1, u2, _f, _l, lamda, _} = vals
    a = Math.pow((Math.cos(u2) * Math.sin(lamda)), 2)
    b = Math.pow((Math.cos(u1) * Math.sin(u2) - Math.sin(u1) * Math.cos(u2) * Math.cos(lamda)),2)
    Math.sqrt(a + b)
  end

  defp _cosSigma(vals) do
    {u1, u2,_f, _l, lamda, _} = vals
    Math.sin(u1) * Math.sin(u2) + Math.cos(u1) * Math.cos(u2) * Math.cos(lamda)
  end

end
