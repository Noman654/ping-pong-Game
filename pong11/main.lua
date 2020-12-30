WINDOW_WIDTH = 1020
WINDOW_HEIGHT = 620
VIRTUAL_HEIGHT = 250
VIRTUAL_WIDTH = 415

Class = require'class'
push = require'push'

require 'Paddle'
require 'Ball'

-- paddle spped  
PADDLE_SPEED = 200

function love.load()
    
    love.window.setTitle("pong")
    love.graphics.setDefaultFilter('nearest','nearest')
    fontX = love.graphics.newFont('font.TTF', 12)
    
    small_font = love.graphics.newFont('font.TTF', 6)

    score_font = love.graphics.newFont('font.TTF', 20)
    
    victory_font = love.graphics.newFont('victory.ttf', 8)
    
    -- create a dictionary of sounds
    sounds = {
        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav',static),
        ['wall_hit'] = love.audio.newSource('wall_hit.wav',static),
        ['out_boundry'] = love.audio.newSource('outofboundry.wav',static)
    }
    -- create paddle obj
    paddle1 = Paddle(5, 30, 5,20)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    
    -- telling score 
    player2score = 0
    player1score = 0

    -- tell me who win 
    player_win = 0

    -- telling game state 
    state = 'start'
    
    -- creating ball obj
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5)

    -- set console screen 
    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,{
        fullscreen = false,
        vsync = true,
        resizable = true
    })
    
end 

-- for resizable
function love.resize(w,h)
    push:resize(w,h)
end

function love.update(dt)

    -- update paddle  
    paddle1:update(dt)
    paddle2:update(dt)
    
    -- check ball is colliding or not 
    if ball:collides(paddle1) then 
        ball.dx = - ball.dx * 1.03
        player1score = player1score + 1

        -- randomize movement in ball 
        if ball.dy > 0 then 
            ball.dy = math.random(10, 150)
        else
            ball.dy = -math.random(10, 150)
        end 
        sounds['paddle_hit']:play()
    end
    
    -- checking paddle is colliding or not 
    if ball:collides(paddle2) then 
        ball.dx = -ball.dx * 1.03
        
        -- randomize movement in ball 
        if ball.dy > 0 then 
            ball.dy = math.random(10, 150)
        else
            ball.dy = -math.random(10, 150)
        end 
        player2score = player2score + 1 
        sounds['paddle_hit']:play()
    end

    if ball.y <= 0 then
        ball.dy = - ball.dy 
        ball.y = 0
        sounds['wall_hit']:play()
    end 
    
    if ball.y >= VIRTUAL_HEIGHT - ball.height then
        ball.dy = - ball.dy 
        ball.y = VIRTUAL_HEIGHT - ball.height
        sounds['wall_hit']:play()
    end 

    if love.keyboard.isDown('w') then

        -- update bar
        paddle1.dy = - PADDLE_SPEED
    elseif love.keyboard.isDown('s') then

        paddle1.dy = PADDLE_SPEED
    else 
        paddle1.dy = 0
    end 

    -- player 2 movement
    if love.keyboard.isDown('up') then
           
        -- player2 update 
        paddle2.dy = - PADDLE_SPEED

    elseif love.keyboard.isDown('down') then 
         
        -- player 2 update down
        paddle2.dy = PADDLE_SPEED
    else 
        paddle2.dy = 0 
    end

    -- update ball status 
    if state == 'playing' then 

        -- update ball x & y
        ball:update(dt)
        
        -- check ball is out of boundry 
        if ball.x <= 0 then 
            ball:reset()
            player2score = player2score + 1
            sounds['out_boundry']:play()
        end 
        
         -- check score 
        if player2score >= 10 then 
            state = 'victory'
            player_win = 2
        end

        if ball.x >= VIRTUAL_WIDTH then 
            ball:reset()
            player1score = player1score + 1
            sounds['out_boundry']:play()
        end 

         -- checking and deciding a score
        if player1score >= 10 then 
            state = 'victory'
            player_win = 1
        end
    end
    
end
function love.keypressed(key)
    
    if key == 'escape' then
        
        love.event.quit()
    
    elseif key == 'enter' or key == 'return' then 

        if state == 'start' then 

            -- start game 
            state = 'playing'
        elseif state == 'victory' then 
            state = 'start'
            -- reset scores and lifes of player1 
            player2score = 0
            player2lifes = 3
            player1score = 0
            player1lifes = 3
        else

            state ='start'
            
            -- reset ball psition 
            ball:reset()
        end

    end
end

function love.draw()
     
    -- open 
    push:apply('start')
    
    --clear all pixel and set according to input 
    love.graphics.clear(40 , 45, 52, 255)
    
    -- create a ball
    ball:render()
    
    -- create a paddle 
    paddle1:render()
    paddle2:render()
    -- print state  of game 
    love.graphics.setFont(fontX)
    display_fps()
    if state == 'start' then 

        love.graphics.printf("start pong!",0,2,VIRTUAL_WIDTH,'center')
    elseif state == 'victory' then 
        love.graphics.setFont(victory_font)
        love.graphics.printf("Player " .. tostring(player_win) .. ' is win ',0,8,VIRTUAL_WIDTH,'center')
        love.graphics.printf("press enter for restart",0,30,VIRTUAL_WIDTH,'center')
    else

        love.graphics.printf("playing pong!",0,2,VIRTUAL_WIDTH,'center')
    end

    -- print score 
    love.graphics.setFont(score_font)
    love.graphics.print(player1score, VIRTUAL_WIDTH/2 - 50, VIRTUAL_HEIGHT/3)
    love.graphics.print(player2score, VIRTUAL_WIDTH/2 + 30 , VIRTUAL_HEIGHT/3)

    --close  
    push:apply('end')
end

function display_fps()
    love.graphics.setColor(0,255,0,255)
    love.graphics.setFont(small_font)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()),40,5)
    love.graphics.setColor(255,255,255,255)
end