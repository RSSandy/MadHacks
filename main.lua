local jumpscareImage
local jumpscareSound
local jumpscareActive = false
local jumpscareTimer = 0
local jumpscareDuration = 1

function love.load()
    windowSetup()
    --Load the images
    dog = loadImage("images/borzoi.png")
    pac = loadImage("images/pacman.png")
    pog = love.graphics.newImage("images/peepoo.png")
    pogHeight = pog:getPixelHeight()
    pogWidth = pog:getPixelWidth()

    --Jumpscare
    jumpscareImage = love.graphics.newImage("images/chicajumpscare.jpeg")
    jumpscareSound = love.audio.newSource("audio/jumpscareaudio.mp3", "static")
    jumpscareActive = false

    --Mug
    images = {}
    imageIndex = 1
    timer = 0
    images[1] = love.graphics.newImage("chicano.jpg")
    images[2] = love.graphics.newImage("chicano1.jpg")
    images[3] = love.graphics.newImage("chicano2.jpg")
    images[4] = love.graphics.newImage("chicano3.jpg")
    switchInterval = 1
    scaleFactor = 0.2

    --jazz
    jazzSound = love.audio.newSource("audio/chill.mp3", "static")

    --font
    font = love.graphics.newFont("Neon.ttf", 36)
    
    --end game
    delay = 1
    delayTimer = 0
    showText = false
    gameOver = false
    resetLevel()
    



end

function love.update(dt)
    if tileMapEmpty() then gameOver = true
    end 
    manageJumpscare(dt)
    jazzSound:setVolume(0.9)
    jazzSound:play()
    if love.keyboard.isDown("r") then resetLevel()
    end
    
    if showText == false then 
        delayTimer = delayTimer + dt
        if delayTimer >= delay then 
            showText = true 
        end
    end

    timer = timer + dt
    if timer >= switchInterval then 
        timer = 0
        imageIndex = imageIndex % #images + 1
    end 


    for i=1, 6 do
        for j=1, 6 do
            if isMouseOver(i, j) and tilemap[i][j] == 1 then 
                -- if numbers[i][j] > previousNumber then successPoint(i, j)
                -- else jumpscareActive = true
                -- end   
                minVal = findMinValue(numbersChosen)
                --love.window.showMessageBox("PLEASEEE", minVal)
                minIndex = findIndex(numbersChosen, minVal)
                --love.window.showMessageBox("at index", numbersChosen[minIndex])
                if  numbers[i][j] == minVal then 
                    successPoint(i, j)
                    table.remove(numbersChosen, minIndex)
                else jumpscareActive = true
                end
            end
        end
    end
end


function love.draw()
    love.graphics.setFont(font)
    if gameOver then 
        endGame()  
    else
    if jumpscareActive then 
        drawJumpscare()
    end
    love.graphics.setBackgroundColor(108/255, 178/255, 209/255, 80/100)
    love.graphics.line(750, 0, 750, windowHeight)
    love.graphics.rectangle("fill", 750, 0 , windowWidth-750, windowHeight)

    --score
    displayScore()

    --changing font
    love.graphics.setFont(love.graphics.newFont(30))
    drawTilemap()
    end 
end


function displayScore()
    love.graphics.setColor(255/255,110/255,225/255, 0.8)
    love.graphics.print("Score: ", 910, 200)
    love.graphics.print(score, 1010, 201)
    love.graphics.print("click on the numbers ", 800, 450)
    love.graphics.print("in ascending order", 820, 520)
    love.graphics.setColor(255,255,255)
end

function loadImage (path)
    local info = love.filesystem.getInfo( path )
    if info then
      return love.graphics.newImage( path )
    end
end

function windowSetup()
    love.window.setMode(1200,800)
    love.window.setTitle( "calming memory game" )
    windowHeight = love.graphics.getPixelHeight()
    windowWidth = love.graphics.getPixelWidth()
end


function isMouseOver(i, j)
    mouseX = love.mouse.getX()
    mouseY = love.mouse.getY()
    if mouseY >= i * 100 and mouseY <= i * 100 + pogHeight then
        withinYRange = true
        else withinYRange = false
    end 
    --[print(withinYRange)
    if mouseX >= j * 100 - 50 and mouseX <=  j*100 - 50 + pogWidth then
        withinXRange = true
        else withinXRange = false
    end 
    return withinYRange and withinXRange and love.mouse.isDown(1);
end 

function resetLevel()
     --Make the tilemap
     rectCount = 12
     tilemap = generateRandom2DArray(6, 6, rectCount)
 
     --Make associated numbers
     numbers = shuffle()
     numbersChosen  = {}
     fillNumbersChosen()
     previousNumber = 0
     score = 0
     gameOver = false
end

function clearTables()
    for i=1,rectCount do
        table.remove(xCoords, i)
        table.insert(yCoords, i)
    end
end

-- Function to generate a random 2D array with a specified number of 1s
function generateRandom2DArray(rows, cols, numOnes)
    -- Initialize the 2D array with all zeros
    local array = {}
    for i = 1, rows do
        array[i] = {}
        for j = 1, cols do
            array[i][j] = 0
        end
    end

    -- Set a specified number of 1s at random positions
    for i = 1, numOnes do
        local randomRow = math.random(1, rows)
        local randomCol = math.random(1, cols)
        array[randomRow][randomCol] = 1
    end

    -- Shuffle the array to randomize the positions of the 1s
    for i = rows * cols, 2, -1 do
        local j = math.random(i)
        local row1, col1 = getIndexFromFlatIndex(i, cols)
        local row2, col2 = getIndexFromFlatIndex(j, cols)
        array[row1][col1], array[row2][col2] = array[row2][col2], array[row1][col1]
    end

    return array
end



-- Function to convert a flat index to row and column indices
function getIndexFromFlatIndex(flatIndex, numCols)
    local row = math.ceil(flatIndex / numCols)
    local col = flatIndex % numCols
    if col == 0 then col = numCols end
    return row, col
end


function drawTilemap()
    --For i=1 till the number of values in tilemap
    for i=1,#tilemap do
        --For j till the number of values in this row
        for j=1,#tilemap[i] do
            --If the value on row i, column j equals 1
            if tilemap[i][j] ~= 0 then
                --Draw the rectangle.
                --Use i and j to position the rectangle.
                love.graphics.draw(pog, j*100-50, i*100)
                love.graphics.setColor(255/255,110/255,225/255, 0.8)
                love.graphics.print(numbers[i][j], j*100+10, i*100 +47)
                love.graphics.setColor(255, 255, 255)
            end 
        end
    end
end

function generateShuffledArray()
    -- Generate an array of numbers from 1 to max
    local array = {}
    for i = 1, max do
        array[i] = i
    end

    -- Perform Fisher-Yates shuffle
    for i = max, 2, -1 do
        local j = math.random(i)
        array[i], array[j] = array[j], array[i]
    end

    return array
end

function shuffle() 
    z = 1
    local array = {}
    for i = 1, 6 do
        array[i] = {}
        for j = 1, 6 do
            array[i][j] = z + 1
            z = z + 1
        end
    end

    for  i = 1, 5 do
        for j = 1, 5 do
            m = math.random(i + 1)
            n = math.random(j + 1)

            temp = array[i][j];
            array[i][j] = array[m][n];
            array[m][n] = temp;
        end
    end
    return array
end

function successPoint(i, j)
    tilemap[i][j] = 0
    score = score + 1
    previousNumber = numbers[i][j]
end

function gameOver()
    love.graphics.clear()
    love.graphics.rectangle("fill", windowWidth/2, windowHeight/2, windowWidth, windowHeight)
    love.graphics.setFont(love.graphics.newFont(100))
    love.graphics.print("GAME OVER!!!!" , windowWidth/2, windowHeight/2)
    love.graphics.setFont(love.graphics.newFont(20))
end

function manageJumpscare(dt)
    if jumpscareActive then
        jumpscareTimer = jumpscareTimer + dt
        if jumpscareTimer >= jumpscareDuration then
            jumpscareActive = false
            jumpscareTimer = 0
        end
    end
end

function drawJumpscare()
    love.graphics.draw(jumpscareImage, 0, 0)
    jumpscareSound:setVolume(0.6)
    jumpscareSound:play()
end

function fillNumbersChosen()
    for i = 1, 6 do
        for j = 1, 6 do
            if tilemap[i][j] == 1 then
                table.insert(numbersChosen, numbers[i][j])
            end
        end
    end
end

function findMinValue(tbl)
    local minValue = math.huge  -- Start with a very large number

    for _, value in ipairs(tbl) do
        if value < minValue then
            minValue = value
        end
    end

    return minValue
end

-- Function to find the index of a value in a table
function findIndex(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then
            return i
        end
    end
    return nil
end

function endGame()
    if youDied then
        drawJumpscare()
    end
     love.graphics.draw(images[imageIndex], 500, 400, 0, scaleFactor, scaleFactor)
     if showText then 
     love.graphics.print("press 'r' to play again", windowWidth/2, windowHeight/3)
     end
end

function tileMapEmpty()
    empty = true
    for i = 1, 6 do
        for j = 1, 6 do
            if tilemap[i][j] ~= 0 then empty = false 
            end 
        end
    end
    return empty
end 