love = love
Physics = love.physics

table  = table
unpack = table.unpack

import random from love.math



-- Utils
Uid = ->
  f = (x) ->
    r = random(16) - 1
    r = (x == "x") and (r + 1) or (r % 4) + 9
    return ("0123456789abcdef")\sub r, r
  return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx")\gsub("[xy]", f))

_include = (to, frm, slf) ->
  for k, v in pairs frm.__index
    if k ~= '__gc' and k ~= '__eq' and k ~= '__index' and k ~= '__tostring' and k ~= 'destroy' and k ~= 'type' and k ~= 'typeOf'
      to[k] = (to, ...) ->
        return v(to[slf], ...)

-- Collider

class Collider
  new: (world, colliderType, ...) =>
    local args, shape, fixture
    @id = Uid!
    @world = world
    @type = colliderType
    @object = nil

    @shapes = {}
    @fixtures = {}
    @sensors = {}

    @collisionEvents = {}
    @collisionStay = {}
    @enterCollisionData = {}
    @exitCollisionData = {}
    @stayCollisionData = {}

    @collisionClass = nil
    @body = nil
    
    args = {...}

    local shape
    if @type == 'Circle'
      @collisionClass = (args[4] and args[4].collisionClass) or 'Default'
      @body = Physics.newBody @world.box2DWorld, args[1], args[2], (args[4] and args[4].bodyType) or 'dynamic'
      shape = Physics.newCircleShape args[3]
    elseif @type == 'Rectangle'
      @collisionClass = (args[5] and args[5].collisionClass) or 'Default'
      @body = Physics.newBody @world.box2DWorld, args[1] + args[3]/2, args[2] + args[4]/2, (args[5] and args[5].bodyType) or 'dynamic'
      shape = Physics.newRectangleShape args[3], args[4]
    elseif @type == 'BSGRectangle'
      @collisionClass = (args[6] and args[6].collisionClass) or 'Default'
      @body = Physics.newBody @world.box2DWorld, args[1] + args[3]/2, args[2] + args[4]/2, (args[6] and args[6].bodyType) or 'dynamic'
      w, h, s = args[3], args[4], args[5]
      shape  = Physics.newPolygonShape {
        -w/2, -h/2 + s, -w/2 + s, -h/2,
         w/2 - s, -h/2, w/2, -h/2 + s,
         w/2, h/2 - s, w/2 - s, h/2,
        -w/2 + s, h/2, -w/2, h/2 - s
      }
    elseif @type == 'Polygon'
      @collisionClass = (args[2] and args[2].collisionClass) or 'Default'
      @body = Physics.newBody @world.box2DWorld, 0, 0, (args[2] and args[2].bodyType) or 'dynamic'
      shape = Physics.newPolygonShape unpack(args[1])
    elseif @type == 'Line'
      @collisionClass = (args[5] and args[5].collisionClass) or 'Default'
      @body = Physics.newBody @world.box2DWorld, 0, 0, (args[5] and args[5].bodyType) or 'dynamic'
      shape = Physics.newEdgeShape args[1], args[2], args[3], args[4]
    elseif @type == 'Chain'
      @collisionClass = (args[3] and args[3].collisionClass) or 'Default'
      @body = Physics.newBody @world.box2DWorld, 0, 0, (args[3] and args[3].bodyType) or 'dynamic'
      shape = Physics.newEdgeShape args[1], unpack args[2]

    fixture = Physics.newFixture @body, shape

    if @world.masks[@collisionClass]
      with fixture
        \setCategory unpack @world.masks[@collisionClass].categories
        \setMask unpack @world.masks[@collisionClass].masks
    
    local sensor
    fixture\setUserData @

    with sensor = Physics.newFixture @body, shape
      \setSensor true
      \setUserData @

    @shapes['main'] = shape
    @fixtures['main'] = fixture
    @sensors['main'] = sensor
    @shape = shape
    @fixture = fixture

    @preSolve = ->
    @postSolve = ->

    _include @, @body, "body"
    _include @, @fixture, "fixture"
    _include @, @shape, "shape"





    
    
