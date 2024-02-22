love = love
Physics = love.physics
table = table
tInsert = table.insert
tRemove = table.remove
tSort = table.sort


_WORLD_METER = 32

utils = {
  math: assert require MBOX2D_ROOT .. 'libs.MoonMath' 
}


class Singleton
  __inherited: (By) =>
    By.getInstance = (...) ->
      if I = By.Instance then return I
      with I = By ...
        By.Instance = I

class World extends Singleton
  -- Class vars
  @DEBUG: false
  @DEBUG_DRAW: false
  @DEBUG_DRAW_FOR_N_FRAMES: 10

  initW: (xg, yg, sleep) =>
    settings = settings or {}

    @explicitCollisionEvents = false

    @collisionClasses = {}
    @masks = {}

    Physics.setMeter _WORLD_METER
    @box2DWorld = Physics.newWorld xg, yg, sleep
  
  new: (xg, yg, sleep) =>
    @world = @initW xg, yg, sleep

    -- https://www.love2d.org/wiki/World:setCallbacks
    @box2DWorld\setCallbacks @collisionOnEnter, 
      @collisionOnExit, 
      @collisionPre, 
      @collisionPost
    @clearColli!
    @addCollisionClass 'Default'
    

  clearColli: =>
    with @collisions = {}
      .onEnter = {}
      .onEnter.sensor = {}
      .onEnter.nonSensor = {}
      .onExit = {}
      .onExit.sensor = {}
      .onExit.nonSensor = {}
      .pre = {}
      .pre.sensor = {}
      .pre.nonSensor = {}
      .post = {}
      .post.sensor = {}
      .post.nonSensor = {}

  clearColliEvents: =>
    bodies = @box2DWorld\getBodies!
    for _, body in ipairs(bodies)
      collider = body\getFixtures()[1]\getUserData!
      collider\collisionEventsClear! -- Will depend on collider class.

  generateCategoriesMasks: =>
    collisionIgnores = {}

    for colliClassName, colliClass in pairs @collisionClasses
      collisionIgnores[colliClassName] = colliClass.ignores or {}

    -- see: https://love2d.org/forums/viewtopic.php?p=155547&sid=efbf28114d92567c4c22aa380498aa90#p155547
    incoming = {} -- incoming coli event from another colliClass
    expanded = {} -- expanded coli event the current colliClass
    all      = {}

    for objType, _ in pairs collisionIgnores
      incoming[objType] = {}
      expanded[objType] = {}
      tInsert all, objType

    -- 
    for objType, ignoreList in pairs collisionIgnores
      for k, ignoredType in pairs ignoreList
        -- TODO ignore first char case
        if ignoredType == 'All' or ignoredType == 'all'
          for _, allObjType in ipairs all
            tInsert incoming[allObjType], objType
            tInsert expanded[objType], allObjType
        elseif type(ignoredType) == 'string'
          if ignoredType == 'All' or ignoredType == 'all'
            tInsert incoming[ignoredType], objType
            tInsert incoming[objType], ignoredType

        if k == 'except'
          for _, exceptIgnoredType in ipairs ignoredType
            for i, v in ipairs incoming[exceptIgnoredType]
              if v == objType
               tRemove incoming[exceptIgnoredType], i
               break
          for _, exceptIgnoredType in ipairs ignoredType
            for i, v in ipairs expanded[objType]
              if v == exceptIgnoredType
                tRemove expanded[objType], i
                break

    edgeGroups = {}

    for k, v in pairs incoming
      tSort v, (a, b) -> string.lower(a) < string.lower(b)
    
    local i
    i = 0

    for k, v in pairs incoming
      str = ""
      for _, c in ipairs v
        str ..= c
      
      if edgeGroups[str] == nil
        i += 1
        edgeGroups[str] = {n: i}

      tInsert edgeGroups[str], k

    categories = {}

    for k, _ in pairs collisionIgnores
      categories[k] = {}
    
    for k, v in pairs edgeGroups
      for _, c in ipairs v
        categories[c] = v.n

    for k, v in pairs expanded
      category = {categories[k]}
      currentMsks = {}
      for _, c in ipairs v
        tInsert currentMsks, categories[c]
      @masks[k] = {categories: category, masks: currentMsks}

  addCollisionClass: (colliClassName, colliClass) =>
    if @collisionClasses[colliClassName] then error 'Collision class ' .. colliClassName .. ' already exists.'
    
    if @explicitCollisionEvents
      @collisionClasses[colliClassName] = colliClass or {}
    else
      @collisionClasses[colliClassName] = colliClass or {}
      @collisionClasses[colliClassName].enter = {}
      @collisionClasses[colliClassName].exit  = {}
      @collisionClasses[colliClassName].pre   = {}
      @collisionClasses[colliClassName].post  = {}

      for cClassName, _ in pairs @collisionClasses
        tInsert @collisionClasses[colliClassName].enter, cClassName
        tInsert @collisionClasses[colliClassName].exit, cClassName
        tInsert @collisionClasses[colliClassName].pre, cClassName
        tInsert @collisionClasses[colliClassName].post, cClassName
      -- go through the existing CCs and add the new CCname to their events
      for cClassName, _ in pairs @collisionClasses
        tInsert @collisionClasses[cClassName].enter, colliClassName
        tInsert @collisionClasses[cClassName].exit, colliClassName
        tInsert @collisionClasses[cClassName].pre, colliClassName
        tInsert @collisionClasses[cClassName].post, colliClassName


    