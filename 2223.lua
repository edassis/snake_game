-- Snake game
-- Author: edassis

Direction={
  [0] = {x = 0, y = -1},    -- up
  [1] = {x = 0, y = 1},     -- down
  [2] = {x = -1, y = 0},    -- left
  [3] = {x = 1, y = 0}      -- right
}

System={
  loop = false;
  screen_w = 240,
  screen_h = 136,
  sprite_size = 8,     -- px
}

Plr={
  tail_len = 0,
  tail_max_len = 3,
  tail_history={
    x={},
    y={}
  },
  facing = Direction[3],
  life = 3,
  points = 0,
  speed = 1,
  x = nil,
  y = nil,
  vx = nil,
  vy = nil
}

Game={
  current_time = 0,
  initial_time = 0,
  time_step = 200,       -- fps, time in ms
  fruitx = 0,
  fruity = 0,
  map_lv = 1,
  startposx = 120,
  startposy = 64,
  run = false
}


-- GENERAL FUNCTIONS
-- loop faz de conta, usa um "jump"   OVERFLOW :D
function break_loop()
  return btn(5)
end


-- Writes cell on the map memory
function write_cell(target_x, target_y, cell_id)
  mset(target_x, target_y, cell_id)   -- Clearing old position
  sync(0,0,true)
end


function wait_input(in_valor)
  if btn(in_valor) then
    return
  else
    wait_input(in_valor)
  end
end


-- Clears only the specified lines on screen
function __CLS(color, y_start, y_end)
  -- screen: 240x136
  for i=0,System.screen_w,1 do
    for j=y_start,y_end,1 do
      rect(i,j,1,1,color)
    end
  end
end


-- Print text into the center of the screen
function printc(msg, y)
  local msg_len = print(msg, 0, -6)
  print(msg, System.screen_w//2 - msg_len//2, y)
end

-- #####################################
-- Game functions

function init()
  math.randomseed(time())

  Plr.x = Game.startposx
  Plr.y = Game.startposy
  Game.initial_time = 0
  Game.current_time = Game.initial_time
  genFruit()
end


function greetings()
  cls(0)
  drawMap()
  score()
  drawPlayer(false)

  local msg = "Press Z to start."
  printc(msg, 88)
end


function continue()
  local msg = "Press Z to restart"
  printc(msg, 96)
  msg = "or X to exit"
  printc(msg, 104)
end


function drawMap()
  -- Drawn fruit, fruit it's drawing over the map, on the running state
  if Game.fruitx ~= 0 then
    drawFruit()
  end
  -- The function map() clears the screen
  map(0,0,30,17,0,0)
end


function drawPlayer(moved)
  -- handling with tail
  if Plr.tail_len == 0 then      -- generating tail
    for i=1,Plr.tail_max_len,1 do
      if Plr.facing == Direction[0] then    -- player going up, means that the tail have to go down
        Plr.tail_history.x[i] = Plr.x
        Plr.tail_history.y[i] = Plr.y + System.sprite_size * i
      elseif Plr.facing == Direction[1] then    -- player down
        Plr.tail_history.x[i] = Plr.x
        Plr.tail_history.y[i] = Plr.y - System.sprite_size * i
      elseif Plr.facing == Direction[2] then    -- player left
        Plr.tail_history.x[i] = Plr.x + System.sprite_size * i
        Plr.tail_history.y[i] = Plr.y
      elseif Plr.facing == Direction[3] then    -- player right
        Plr.tail_history.x[i] = Plr.x - System.sprite_size * i
        Plr.tail_history.y[i] = Plr.y
      end
      Plr.tail_len = Plr.tail_len + 1
    end
  elseif moved then    -- snake haves tail, update only with the player moves
    if Plr.facing == Direction[0] then        -- player going up, means that the tail have to go down
      table.insert(Plr.tail_history.x, 1, Plr.x)
      table.insert(Plr.tail_history.y, 1, Plr.y + System.sprite_size)
    elseif Plr.facing == Direction[1] then    -- player down
      table.insert(Plr.tail_history.x, 1, Plr.x)
      table.insert(Plr.tail_history.y, 1, Plr.y - System.sprite_size)
    elseif Plr.facing == Direction[2] then    -- player left
      table.insert(Plr.tail_history.x, 1, Plr.x + System.sprite_size)
      table.insert(Plr.tail_history.y, 1, Plr.y)
    elseif Plr.facing == Direction[3] then    -- player right
      table.insert(Plr.tail_history.x, 1, Plr.x - System.sprite_size)
      table.insert(Plr.tail_history.y, 1, Plr.y)
    end
    Plr.tail_len = Plr.tail_len + 1
  end

  -- shrinking tail
  if Plr.tail_len > Plr.tail_max_len then
    table.remove(Plr.tail_history.x, #Plr.tail_history.x)
    table.remove(Plr.tail_history.y, #Plr.tail_history.y)
    Plr.tail_len = Plr.tail_len - 1
  end

  -- printing
  -- snake head
  rect(Plr.x,Plr.y, System.sprite_size, System.sprite_size, 6)
  -- snake tail
  for i=1,Plr.tail_len,1 do
    -- print(Plr.x.." "..Plr.y.." ".."\tLen: "..Plr.tail_len,16,16)
    -- print("Tail["..i.."]: "..Plr.tail_history.x[i].." "..Plr.tail_history.y[i], 16, 22+8*i)
    rect(Plr.tail_history.x[i], Plr.tail_history.y[i], System.sprite_size, System.sprite_size, 15)
  end
end


function score()
  local pixels = 0       -- Pixels used
  local msg = nil
  local msg_lenght = 0

  msg = string.format("Lifes: %d", Plr.life)
  pixels = print(msg,0,-6,15,true)
  print(msg,0,130,15,true)

  msg = string.format("Points: %d", Plr.points)
  msg_lenght = print(msg, 0, -6, 15, true)
  print(msg, System.screen_w//2 - msg_lenght//2, 130, 15, true)

  msg = string.format("Time: %.1fs",  (Game.current_time - Game.initial_time)/1000)
  msg_lenght = print(msg,0,-6,15,true)
  print(msg, System.screen_w - msg_lenght, 130, 15, true)

  -- print("Player: "..Plr.x.." "..Plr.y, 16, 16)
  -- print(Player.tail_history,0,8)
end


-- Detect px collision (taking from the screen), return color
function pxCollided(target_x, target_y)
  return pix(target_x, target_y)
end

-- Detect wich cell collision has occured (taking cell from the map), return cell's ID
-- Receives px coordinates
function cellCollided(target_x, target_y)
  local cell_posx = ( target_x > 0 and target_x < System.screen_w) and (target_x // System.sprite_size)
  or ( (target_x < 0) and 0 or (System.screen_w // System.screen_w) )
  local cell_posy = ( target_y > 0 and target_y < System.screen_h) and (target_y // System.sprite_size)
  or ( (target_y < 0) and 0 or (System.screen_h // System.screen_h) )
  -- trace(cell_posx.." "..cell_posy.." "..mget(cell_posx, cell_posy))

  return mget(cell_posx, cell_posy)
end


-- Shows game over message and return true if the player lost
function gameover()
  if Plr.life <= 0 then
    printc("Game Over!", 88)
    return true
  end

  return false
end


function genFruit()
  local pos = {x,y}
  pos.x = math.random(16, System.screen_w - System.sprite_size) // System.sprite_size * System.sprite_size
  pos.y = math.random(16, 130 - System.sprite_size) // System.sprite_size * System.sprite_size
  -- trace(pos.x.." "..pos.y)

  if pxCollided(pos.x, pos.y) == 15 or pxCollided(pos.x, pos.y) == 6 then   -- Wall color, snake's head color
    genFruit()
  else
    Game.fruitx = pos.x
    Game.fruity = pos.y
  end
end


function drawFruit()
  -- spr(0,Game.fruitx, Game.fruity)
  -- trace((Game.fruitx).." "..(Game.fruity))
  mset(Game.fruitx // 8, Game.fruity // 8, 0)
  sync(0,0,true)
  
end



plr_last_facing = Plr.facing
delay = 0
init()
function TIC()    -- doesn't accept loops
  if Game.run and System.loop == false then
    -- arrows input
    if btn(0) and plr_last_facing ~= Direction[1] then          -- up && avoid the snake's head to go in the opposite direction
      Plr.facing = Direction[0]
      plr_last_facing = Plr.facing
    elseif btn(1) and plr_last_facing ~= Direction[0] then      -- down
      Plr.facing = Direction[1]
      plr_last_facing = Plr.facing
    elseif btn(2) and plr_last_facing ~= Direction[3] then      -- left
      Plr.facing = Direction[2]
      plr_last_facing = Plr.facing
    elseif btn(3) and plr_last_facing ~= Direction[2] then      -- right
      Plr.facing = Direction[3]
      plr_last_facing = Plr.facing
    end

    if time() > (Game.current_time + Game.time_step + delay) then
      Plr.x = Plr.x + Plr.facing.x * Plr.speed * System.sprite_size
      Plr.y = Plr.y + Plr.facing.y * Plr.speed * System.sprite_size

      -- wall collision (white)
      if pxCollided(Plr.x,Plr.y) == 15 then
        delay = 200

        Plr.life = Plr.life - 1
        Plr.points = 0
        Plr.facing = Direction[3]
        plr_last_facing = Plr.facing
        Plr.tail_len = 0
        Plr.x = Game.startposx
        Plr.y = Game.startposy
      end

      -- consumible collision
      -- trace(Plr.x.." "..Plr.y.." "..cellCollided(Plr.x, Plr.y))
      if cellCollided(Plr.x, Plr.y) == 0 then
        Plr.points = Plr.points + 10
        write_cell(Game.fruitx // 8, Game.fruity // 8, 255)   -- Clearing old position
        genFruit()
      end

      delay = 0
      __CLS(0, 0, 120)
      -- cls(0)
      drawMap()
      -- score()
      drawPlayer(true)


      -- Player without lifes
      if gameover() then Game.run = false end

      -- updating counter
      Game.current_time = time()
    end -- game running

    __CLS(0, 121, 136)
    score()

  -- The game didn't start already
  elseif Plr.life > 0 and System.loop == false then
    greetings()
    
    if btn(4) then    -- Z pressed, returns only when the key is pressed
      Game.run = true
      Game.initial_time = time()
      Game.current_time = Game.initial_time
    end

  -- Player is dead
  elseif System.loop == false then
    continue()

    if btn(4) then
      Plr.life = 3
      Game.run = true
      Game.initial_time = time()
      Game.current_time = Game.initial_time
    elseif btn(5) then
      exit()
    end
  end

  -- if Plr.facing ~= plr_last_direction then    -- Case the player changes the snake direction
  --   System.loop = true
  --   if break_loop() then
  --     plr_last_direction = Plr.facing
  --     System.loop = false
  --   end
  -- end
end

--[[
  TODO:
    - Collisions
    - Die
    - Maps :D
    - Adjust to pixel precision movements (a lot of effort)
]]