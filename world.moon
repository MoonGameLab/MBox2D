MBOX2DPATH = MBOX2DPATH

{
  :rectGetSquareDist
  :rectGetSegmentIntersectionIndices
} = assert require MBOX2DPATH .. ".rect"
{:assertIsPositiveNum} = assert require MBOX2DPATH .. ".aux"
{:gridTraverse} = assert require MBOX2DPATH .. ".grid"

{
  :touch
  :cross
  :slide
  :bounce
} =  assert require MBOX2DPATH .. ".response"

min = math.min

World = {}
WorlsMeta = { __index: World }

with World
  .new = (cellSize) ->
    local _world
    cellSize = cellSize or 64
    assertIsPositiveNum cellSize, 'cellSize'
    _world = setmetatable {
      cellSize: cellSize
      rects: {}
      rows: {}
      occupiedCells: {}
      responses: {}
    }, WorlsMeta

    _world\addResponse 'touch', touch
    _world\addResponse 'cross', cross
    _world\addResponse 'slide', slide
    _world\addResponse 'bounce', bounce

    _world

  .addResponse = (name, response) =>
    @responses[name] = response

---------------------------------------------
---            HELPERS                    ---
---------------------------------------------

sortByWeight = (a, b) ->
  return a.weight < b.weight

sortByTiAndDist = (a, b) ->
  if a.ti == b.ti
    ir, ar, br = a.itemRect, a.otherRect, b.otherRect
    ab = rectGetSquareDist ir.x,ir.y,ir.w,ir.h, ar.x,ar.y,ar.w,ar.h
    bd = rectGetSquareDist ir.x,ir.y,ir.w,ir.h, br.x,br.y,br.w,br.h
    return ab < bd
  a.ti < b.ti
addItemToCell = (self, item, cx, cy) ->
  self.rows[cy] = self.rows[cy] or setmetatable {}, {__mode: 'v'}
  row = self.rows[cy]
  row[cx] = row[cx] or { itemCount: 0, x: cx, y: cy, items: setmetatable {}, {__mode: 'k'} }
  cell = row[cx]
  self.occupiedCells[cell] = true
  unless cell.items[item]
    cell.items[item] = true
    cell.itemCount += 1

removeItemToCell = (self, item, cx, cy) ->
  row = self.rows[cy]
  if not row or not row[cx] or not row[cx].items[item] then return false

  cell = row[cx]
  cell.items[item] = nil
  cell.itemCount -= 1

  if cell.itemCount == 0
    self.nonEmptyCells[cell] = nil

  true

getDictItemsInCellRect = (self, cl,ct,cw,ch) ->
  itemsDict = {}
  for cy=ct, ct+ch-1
    row = self.rows[cy]
    if row
      for cx=cl, cl+cw-1
        cell = row[cx]
        if cell and cell.itemCount > 0
          for item, _ in pairs cell.items
            itemsDict[item] = true
  itemsDict

getCellsTouchedBySegment = (self, x1,y1,x2,y2) ->
  cells, cellsLen, visited = {}, 0, {}

  gridTraverse self.cellSize, x1, y1, x2, y2, (cx, cy) ->
    row = self.rows[cy]
    unless row then return
    cell = row[cx]
    if not cell or visited[cell] then return

    visited[cell] = true
    cellsLen += 1
    cells[cellsLen] = cell

  return cells, cellsLen

getInfoAboutItemsTouchedBySegment = (self, x1,y1, x2,y2, filter) ->
  cells, len = getCellsTouchedBySegment self, x1, y1, x2, y2
  local cell, rect, l, t, w, h, ti1, ti2, tii0, tii1
  visited, itemInfo, itemInfoLen = {}, {}, 0

  for i=1, len
    cell = cells[i]
    for item in pairs cell.items
      if not visited[item]
        visited[item] = true
        if not filter or filter(item)
          rect = self.rects[item]
          l, t, w, h = rect.x, rect.y, rect.w, rect.h

          ti1, ti2 = rectGetSegmentIntersectionIndices l,t,w,h, x1,y1, x2,y2, 0, 1
          if ti1 and ((0 < ti1 and ti1 < 1) or (0 < ti2 and ti2 < 1))
            tii0,tii1 = rectGetSegmentIntersectionIndices l,t,w,h, x1,y1, x2,y2, -math.huge, math.huge
            itemInfoLen += 1
            itemInfo[itemInfoLen] = {item: item, ti1: ti1, ti2: ti2, weight: min(tii0,tii1)}
  table.sort itemInfo, sortByWeight
  itemInfo, itemInfoLen


getResponseByName = (self, name) ->
  response = self.responses[name]
  unless response
    error(('Unknown collision type: %s (%s)')\format(name, type(name)))
  response


World
