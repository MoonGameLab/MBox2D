aux = assert require MBOX2DPATH .. '.aux'
-- aux = assert require 'aux' -- Just for now to run some tests and so Busted does not complain.

abs, floor, ceil, min, max = math.abs, math.floor, math.ceil, math.min, math.max


rectGetNearestCorner = (x, y, w, h, px, py) ->
  return aux.nearest(px, x, x+w), aux.nearest(py, y, y+w)

-- For further understanding of liang-barsky algorithm see : https://www.skytopia.com/project/articles/compsci/clipping.html#edges
rectGetSegmentIntersectionIndices = (x, y, w, h, x1, y1, x2, y2, t0, t1) ->
  t0, t1 = t0 or 0, t1 or 1
  dx, dy = x2 - x1, y2 - y1
  local nx, ny, _sides
  nx1, ny1, nx2, ny2, _sides = 0, 0, 0, 0, 4
  -- p = X/YDelta
  -- q = edge
  -- r = q/p
  local p, q, r

  for side = 1, _sides
    if     side == 1 then nx,ny,p,q = -1, 0, -dx, x1 - x -- left
    elseif side == 2 then nx,ny,p,q =  1, 0,  dx, x + w - x1 -- right
    elseif side == 3 then nx,ny,p,q =  0,-1, -dy, y1 - y -- top
    else                  nx,ny,p,q =  0, 1,  dy, y + h - y1 -- bottom

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
  return x2-x1-w1, y2-y1-h1, w1+w2, h1+h2

rectContainsPoint = (x, y, w, h, px, py) ->
  return px - x > aux.DELTA and py - y > aux.DELTA and x + w - px > aux.DELTA  and y + h - py > aux.DELTA


recIsIntersecting = (x1,y1,w1,h1, x2,y2,w2,h2) ->
  return x1 < x2+w2 and x2 < x1+w1 and y1 < y2+h2 and y2 < y1+h1

rectGetSquareDist = (x1,y1,w1,h1, x2,y2,w2,h2) ->
  dx = x1 - x2 + (w1 - w2)/2
  dy = y1 - y2 + (h1 - h2)/2
  return dx*dx + dy*dy

sign = (x) ->
  if x > 0 then return 1
  if x == 0 then return 0
  return -1

rectDetectCollision = (x1,y1,w1,h1, x2,y2,w2,h2, goalX, goalY) ->
  goalX = goalX or x1
  goalY = goalY or y1

  dx, dy = goalX - x1, goalY - y1
  x, y, w, h = rectGetDiff x1,y1,w1,h1, x2,y2,w2,h2

  local overlaps, ti, nx, ny

  print rectContainsPoint x, y, w, h, 0, 0
  
  if rectContainsPoint x, y, w, h, 0, 0
    px, py = rectGetNearestCorner x, y, w, h, 0, 0
    wi, hi = min(w1, abs(px)), min(h1, abs(py))
    ti = -wi * hi
    overlaps = true
  else
    ti1,ti2,nx1,ny1 = rectGetSegmentIntersectionIndices x,y,w,h, 0,0,dx,dy, -math.huge, math.huge

    if ti1 and ti1 < 1 and (abs(ti1 - ti2) >= DELTA) and (0 < ti1 + DELTA or 0 == ti1 and ti2 > 0)
      ti, nx, ny = ti1, nx1, ny1
      overlaps   = false

  if ti == nil
    return

  local tx, ty
  
  if overlaps
    if dx == 0 and dy == 0
      px, py = rectGetNearestCorner x,y,w,h, 0,0
      if abs(px) < abs(py) then py = 0 else px = 0
      nx, ny = sign(px), sign(py)
      tx, ty = x1 + px, y1 + py
    else
      local t0, _
      t0, _, nx, ny = rectGetSegmentIntersectionIndices x,y,w,h, 0,0,dx,dy, -math.huge, 1
      if not t0 then return
      tx, ty = x1 + dx * t0, y1 + dy * t0
  else
    tx, ty = x1 + dx * ti, y1 + dy * ti

  return {
    overlaps: overlaps,
    ti: ti,
    move: {x: dx, y: dy},
    normal: {x: nx, y: ny},
    touch: {x: tx, y: ty},
    itemRect: {x: x1, y: y1, w: w1, h: h1},
    otherRect: {x: x2, y: y2, w: w2, h: h2}
  }


{
  :rectGetSegmentIntersectionIndices
  :rectGetNearestCorner
  :rectGetDiff
  :rectContainsPoint
  :recIsIntersecting
  :rectGetSquareDist
  :rectDetectCollision
}