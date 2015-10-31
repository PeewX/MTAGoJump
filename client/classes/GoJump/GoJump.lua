--
-- PewX (HorrorClown)
-- Using: IntelliJ IDEA 14 Ultimate
-- Date: 28.10.2015 - Time: 19:15
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--

GoJump = {}

function GoJump:constructor()
    self.state = "Home"
    self.width, self.height = 400, 600

    self.renderTarget = DxRenderTarget(self.width, self.height, true)
    self.white = tocolor(255, 255, 255)
    self.currentID = 0

    self:loadImages()
    self.background = self[("bg_%s"):format(math.random(1,6))]

    self.staticFloorHeight = 200
    self.staticOffset = 35
    self.staticDrawRange = 4
    self.staticJumpSpeed = 500

    self.Lines = {}
    self:createLines()

    self.Blocks = {}
    self:createBlocks()

    self.playerHeight = self.Lines[self.currentID] - 32
    self.moveState = "r"
    self.playerX = 0
    self.heightOffset = 0
    self.anim_player = new(CAnimation, self, bind(GoJump.jumpDone, self), "playerHeight")
    self.anim_player2 = new(CAnimation, self, bind(GoJump.movePlayer, self), "playerX")
    self.anim_offset = new(CAnimation, self, "heightOffset")

    self:updateRenderTarget()

    Event:add(self, "onClientRender", root, true)

    self._bindKeySpaceFunc = bind(GoJump.onJump, self)
    bindKey("space", "both", self._bindKeySpaceFunc)

    self.moveState = "r"
    -- movePlayer handled by animation class as callback function
    -- setTimer(bind(GoJump.movePlayer, self), 2000, 0)
end

function GoJump:destructor()

end

function GoJump:loadImages()
    self.images = {
        "titlescreen",
        "howto",
        "circle_play",
        "player_l",
        "player_r",
        "bg_1",
        "bg_2",
        "bg_3",
        "bg_4",
        "bg_5",
        "bg_6"
    }

    for _, img in ipairs(self.images) do
        self[img] = DxTexture(("res/img/%s.png"):format(img))
    end
end

function GoJump:createLines()
    for i = 0, 500 do
        local lineHeight = self.height - self.staticOffset - self.staticFloorHeight*i
        self.Lines[i] = lineHeight
    end
end

function GoJump:createBlocks()
    for i = 0, 500 do
        local blockHeight = (self.height - self.staticOffset - self.staticFloorHeight*i) - 32
        local blockAnim = new(CAnimation, self, ("blockX_%s"):format(i))
        local moveState = math.random(1,2) == 1 and "l" or "r"
        local moveSpeed = self:getRandomSpeed(i)
        self[("blockX_%s"):format(i)] =  moveState == "r" and 0 or self.width-32

        self.Blocks[i] = {height = blockHeight, anim = blockAnim, state = moveState, speed = moveSpeed}
    end

    --Clear Blocks:
    for _, c in ipairs({0, 5, 10, 15, 20, 50, 75, 100, 140, 180, 200 }) do
       self.Blocks[c].state = "none"
    end
end

function GoJump:getRandomSpeed(blockID)
    --Todo: Make speed dependent on blockID
    local def = {
        [1] = {min = 1800, max = 2100},
        [2] = {min = 2100, max = 2400},
        [3] = {min = 2400, max = 2700},
        [4] = {min = 2700, max = 3000},
        [5] = {min = 900, max = 1100},
    }

    local sep = math.random(1, ((math.random(1, 5) == 2) and (math.random(1,5) == 3)) and 5 or 4 )

    local randomSpeed = math.random(def[sep].min, def[sep].max)

    --Check speed of previous block
    if self.Blocks[blockID-1] then
        local previousBlockSpeed = self.Blocks[blockID-1].speed
        local diff = math.abs(previousBlockSpeed - randomSpeed)

        local runs = 0
        while diff <= 100 do
            runs = runs + 1
            randomSpeed = math.random(def[sep].min, def[sep].max)
            diff = math.abs(previousBlockSpeed - randomSpeed)
            outputChatBox(("Changing speed of block id %s"):format(blockID))

            if runs >= 5 then
                break
            end
        end

    end

    return randomSpeed
end

function GoJump:movePlayer()
    if self.moveState == "r" then
        self.anim_player2:startAnimation(1500, "Linear", self.width-32)
        self.moveState = "l"
    elseif self.moveState == "l" then
        self.anim_player2:startAnimation(1500, "Linear", 0)
        self.moveState = "r"
    end
end

function GoJump:onJump(_, str_State)
    if self.state ~= "Play" then
        if self.state == "Home" then
            self.state = "Play"
            self.ignoreUp = true
            self:movePlayer()
        end
        return
    end

    if str_State == "down" then
        if self.anim_player:isAnimationRendered() then
            self.ignoreUp = true
            return
        end

        playSound("res/sound/jump.wav")
        self.anim_player:startAnimation(self.staticJumpSpeed, "OutQuad",  self.Lines[self.currentID + 1] - 32)
    elseif str_State == "up" then
        if self.ignoreUp then
            self.ignoreUp = false
            return
        end

        if self.anim_player:isAnimationRendered() then
           --Calculate down speed based on playerheight
           local targetHeight = self.height - (self.Lines[self.currentID + 1] + self.heightOffset)
           local currentHeight = self.height - (self.playerHeight + self.heightOffset)

           local process = 1/targetHeight*currentHeight
           local duration = self.staticJumpSpeed*process
           --outputChatBox(("Process: %s | duration: %s"):format(process, duration))

            self.anim_player:startAnimation(duration, "InQuad", self.Lines[self.currentID] - 32)
        else
            playSound("res/sound/point.wav")
            self.currentID = self.currentID + 1
            self.anim_offset:startAnimation(2500, "OutQuad", self.currentID*self.staticFloorHeight)
        end
    end
end

function GoJump.jumpDone()
    --Todo: improve jump method with callback function
end

function GoJump:updateRenderTarget()
    if not self.renderTarget then return end
    self.renderTarget:setAsTarget(true)

    dxDrawImage(0, 0, 400, 600, self.background)

    if self.state == "Home" then
        dxDrawImage(0, 0, 400, 600, self.titlescreen)
    end

    if self.state == "Play" then
        for i = 0, #self.Lines do
            if i - self.staticDrawRange < self.currentID and i + self.staticDrawRange > self.currentID  then
                dxDrawLine(0, self.Lines[i] + self.heightOffset, self.width, self.Lines[i] + self.heightOffset, self.white, 3)
                dxDrawText(i, 0, self.Lines[i] + self.heightOffset + 5, self.width, y, self.white, 2, "arial", "right")
            end
        end

        for i = 0, #self.Blocks do
            if self.Blocks[i].state ~= "none" then
                if i - self.staticDrawRange < self.currentID and i + self.staticDrawRange > self.currentID  then
                    dxDrawRectangle(self[("blockX_%s"):format(i)], self.Blocks[i].height + self.heightOffset, 32, 32, self.white)

                    if not self.Blocks[i].anim:isAnimationRendered() then
                        if self.Blocks[i].state == "r" then
                            self.Blocks[i].state = "l"
                            self.Blocks[i].anim:startAnimation(self.Blocks[i].speed, "Linear", self.width-32)
                        else
                            self.Blocks[i].state = "r"
                            self.Blocks[i].anim:startAnimation(self.Blocks[i].speed, "Linear", 0)
                        end
                    end
                end
            end
        end

        dxDrawText(self.currentID, 0, 0, self.width, 100, self.white, 4, "default-bold", "center", "center")

        dxDrawImage(self.playerX, self.playerHeight + self.heightOffset, 32, 32, self[("player_%s"):format(self.moveState == "r" and "l" or "r")])
    end

    dxSetRenderTarget()
end

function GoJump:playerDied()
    if self.state == "dead" then return end

    playSound("res/sound/dead.wav")
    self.state = "dead"
    self.lastScore = self.currentID

    --Reset values
    self.currentID = 0
    self.playerHeight = self.Lines[self.currentID] - 32
    self.moveState = "r"
    self.playerX = 0
    self.heightOffset = 0

    self.anim_player:stopAnimation()
    self.anim_player2:stopAnimation()
    self.anim_offset:stopAnimation()

    for i = 0, #self.Blocks do
        self.Blocks[i].anim:stopAnimation()
    end

    setTimer(
        function()
            --Recreate blocks
            self:createBlocks()

            self.state = "Home"
            self:updateRenderTarget()
            self.currentID = 0
        end
    ,1500, 1)
end

function GoJump:onClientRender()
    --Collide detection
    if self.state == "Play" then
        for i = 0, #self.Blocks do
            if self.Blocks[i].state ~= "none" then
                if i - self.staticDrawRange < self.currentID and i + self.staticDrawRange > self.currentID  then
                    local playerX = self.playerX
                    local playerY = self.playerHeight + self.heightOffset
                    local blockX = self[("blockX_%s"):format(i)]
                    local blockY = self.Blocks[i].height + self.heightOffset

                    local dis = math.floor(getDistanceBetweenPoints2D(playerX, playerY, blockX, blockY))
                    dxDrawText(("Distance to '%s': %s"):format(i, dis), 20, (y/2-100) + (i - self.currentID)*25, x, y, tocolor(0, 0, 0), 2)

                    if dis <= 32 then
                        self:playerDied()
                    end
                end
            end
        end
    end

    --dxDrawImage(x/2-200 / 1920*x, y/2-300 / 1080*y, 400 / 1920 * x, 600 / 1080 * y, self.renderTarget)
    dxDrawImage(x/2-200, y/2-300, 400, 600, self.renderTarget)
end