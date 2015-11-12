--
-- PewX (HorrorClown)
-- Using: IntelliJ IDEA 14 Ultimate
-- Date: 10.11.2015 - Time: 19:12
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
CGoJump = {}

function CGoJump:constructor()
    Event:addRemote(self, "sendHighscore", "receiveHighscore")
    Event:addRemote(self, "requestStats", "sendStats")
    self:loadScores()
end

function CGoJump:destructor()

end

function CGoJump:loadScores()
    local file = File("res/highscore.pew")

    if file then
        local content = file:read(file:getSize())
        self.Scores = fromJSON(content)
        self:sortScores()
        self.Highscore = tonumber(self.Scores[1].score)
        file:close()
    else
        self.Scores = {}
        self.Highscore = 0
    end

    --[[for i, node in ipairs(xml:getChildren()) do
        table.insert(self.Scores, node:getAttributes())
    end

    for i, score in ipairs(self.Scores) do
        self.Scores[i].score = tonumber(score.score)
    end]]
end

function CGoJump:save()
    File.delete("res/highscore.pew")
    local file = File.new("res/highscore.pew")
    local content = toJSON(self.Scores)
    file:write(content)
    file:close()
end

function CGoJump:sortScores()
    table.sort(self.Scores, function(a, b) return a.score > b.score end)
end

function CGoJump:receiveHighscore(ePlayer, nHighscore)
    local plAccount = getAccountName(getPlayerAccount(ePlayer))
    local plSerial = getPlayerSerial(ePlayer)
    local plName = getPlayerName(ePlayer)
    local plIP = getPlayerIP(ePlayer)
    local score = tonumber(nHighscore)
    local date = getRealTime().timestamp

    if score > self.Highscore then
        outputChatBox(("|GoJump| %s#ff8000 got a new highscore (%s)!"):format(plName, score), root, 255, 255, 255, true)
    end

    local foundSerialID, foundAccountID = false, false
    for i, score in ipairs(self.Scores) do
       if score.serial ==  plSerial then
           foundSerialID = i
       elseif score.accountName == plAccount then
           foundAccountID = i
       end
    end

    if foundAccountID and score < self.Scores[foundAccountID].score then return end
    if foundSerialID and score < self.Scores[foundSerialID].score then return end

    if foundAccountID then table.remove(self.Scores, foundAccountID) end
    if foundSerialID then table.remove(self.Scores, foundSerialID) end

    table.insert(self.Scores, {name = plName, score = score, accountName = plAccount, serial = plSerial, ip = plIP, date = date})
    self:sortScores()
    self:save()
end

function CGoJump:sendStats(ePlayer)
    self.clientStats = self.Scores --Todo: Just send name + score
    RPC:call(ePlayer, "sendStats", self.Scores)
end