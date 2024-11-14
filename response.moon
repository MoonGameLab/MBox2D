
touch = (world, col, x, y, w, h, goalX, goalY, filter) ->
  col.touch.x, col.touch.y, {}, 0

cross = (world, col, x, y, w, h, goalX, goalY, filter) ->
  cols, len = world\project col.item, x, y, w, h, goalX, goalY, filter
  goalX, goalY, cols, len

slide = (world, col, x, y, w, h, goalX, goalY, filter) ->
  goalX = goalX or x
  goalY = goalY or y

  _touch, move = col.touch, col.move

  if move.x ~= 0 or move.y ~= 0
    if col.normal ~= 0
      goalX = _touch.x
    else
      goalY = _touch.y

  col.slide = {x: goalX, y: goalY}

  x, y = _touch.x, _touch.y
  cols, len = world\project col.item, x, y, w, h, goalX, goalY, filter
  goalX, goalY, cols, len

bounce = (world, col, x, y, w, h, goalX, goalY, filter) ->
  goalX = goalX or x
  goalY = goalY or y

  _touch, move = col.touch, col.move
  tx, ty = _touch.x, _touch.y

  bx, by = tx, ty

  if move.x ~= 0 or move.y ~= 0
    bnx, bny = goalX - tx, goalY - ty
    if col.normal.x == 0 then bny = -bny else bnx = -bnx
    bx, by = tx + bnx, ty + bny

  col.bounce = {x: bx, y: by}
  x, y = _touch.x, _touch.y
  goalX, goalY = bx, by

  cols, len = world\project col.item, x, y, w, h, goalX, goalY, filter
  goalX, goalY, cols, len


{ --TODO: add logs
  :touch
  :cross
  :slide
  :bounce
}
