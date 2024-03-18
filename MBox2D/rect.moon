aux = assert require MBOX2DPATH .. '.aux'


rectGetNearestCorner = (x, y, w, h, px, py) ->
  return nearest(px, x, x+w), nearest(py, y, y+w)

-- For further understanding of liang-barsky algorithm see : https://www.skytopia.com/project/articles/compsci/clipping.html#edges
rectGetSegmentIntersectionIndices = (x, y, w, h, x1, y1, x2, y2, t0, t1) ->
  t0, t1 = t0 or 0, t1 or 1
  dx, dy = x2 - x1, y2 - y1
  local nx, ny
  nx1, ny1, nx2, ny2 = 0, 0, 0, 0
  -- p = X/YDelta
  -- q = edge
  -- r = q/p
  local p, q, r

  for side = 1, 4
    if     side == 1 then nx,ny,p,q = -1, 0, -dx, x1 - x -- left
    elseif side == 2 then nx,ny,p,q =  1, 0,  dx, x + w - x1 --
    elseif side == 3 then nx,ny,p,q =  0,-1, -dy, y1 - y
    else                  nx,ny,p,q =  0, 1,  dy, y + h - y1

    if p == 0
      if q <= 0 then return nil
    else
      r = q / p
      if p < 0
        if     r > t1 then return nil
        elseif r > t0 then t0, nx1, xy1 = r, nx, ny
      elseif p > 0
        if     r < t0 then return nil
        elseif r < t1 then t1, nx2, xy2 = r, nx, ny


  return t0, t1, nx1,ny1, nx2,ny2


rectGetDiff = (x1,y1,w1,h1, x2,y2,w2,h2) ->
  return x2 - x1 - w1, y2 - y1 - h1, w1 + w2, h1 + h2

rectContainsPoint = (x, y, w, h, px, py) ->
  return px - x > aux.DELTA      and py - y > aux.DELTA and x + w - px > aux.DELTA  and y + h - py > aux.DELTA


recIsIntersecting = (x1,y1,w1,h1, x2,y2,w2,h2) ->
  return x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1

rectGetSquarDist = (x1,y1,w1,h1, x2,y2,w2,h2) ->
  dx = x1 - x2 + (w1 - w2)/2
  dy = y1 - y2 + (h1 - h2)/2
  return dx*dx + dy*dy

{
  :rectGetSegmentIntersectionIndices
}