--
-- PewX (HorrorClown)
-- Using: IntelliJ IDEA 14 Ultimate
-- Date: 10.10.2015 - Time: 02:27
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--

CDownloadManager = {}

function CDownloadManager:constructor()
    self.Files = {}
    self.FilesToID = {}
    self.ableToLoad = false

    --local sT = getTickCount()
    self:getFiles()
    self:loadFiles()
    --debugOutput(("[CDownloadManager] Open '%s' files in %sms"):format(#self.Files, getTickCount()-sT))

    Event:addRemote(self, "DownloadManager:validateClientFiles", "validateClientFiles")
end

function CDownloadManager:destructor()

end

function CDownloadManager:getFiles()
  local xml = XML.load("shared/files.xml")

  if not xml then
    debugOutput("[CDownloadManager] Can't load 'shared/files.mxl'!")
    return
  end

  for _, file in ipairs(xml:getChildren()) do
    local str_FilePath = file:getAttribute("src")
    if str_FilePath and File.exists(str_FilePath) then
      table.insert(self.Files, {path = str_FilePath})
      self.FilesToID[str_FilePath] = #self.Files
    else
      debugOutput(("[CDownloadManager] Can't find file '%s'"):format(str_FilePath))
    end
  end

  self.ableToLoad = true
  xml:unload()
end

function CDownloadManager:loadFiles()
    if not self.ableToLoad then return end

    for _, file in ipairs(self.Files) do
        local eFile = File(file.path)
        file.size = eFile:getSize()
        file.content = eFile:read(file.size)
        file.hash = md5(file.content)
        eFile:close()
    end
end

function CDownloadManager:validateClientFiles(client, tFiles)
    local filesToSend = {}

    for _, file in ipairs(tFiles) do
        local fileID = self.FilesToID[file.path]

        if fileID then
            if not file.available or file.hash ~= self.Files[fileID].hash then
                table.insert(filesToSend, self.Files[fileID])
            end
        else
            file.valid = false
            debugOutput(("[CDownloadManager] Client request a invalid file '%s'"):format(file.path))
        end
    end

    if #filesToSend ~= 0 then
        RPC:latentCall(client, "DownloadManager:sendFiles", filesToSend)
    end
end