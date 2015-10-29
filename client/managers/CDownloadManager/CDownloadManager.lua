--
-- PewX (HorrorClown)
-- Using: IntelliJ IDEA 14 Ultimate
-- Date: 10.10.2015 - Time: 16:11
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--

CDownloadManager = {}

function CDownloadManager:constructor()
    Event:addRemote(self, "DownloadManager:sendFiles", "receiveFiles")
end

function CDownloadManager:destructor()

end

function CDownloadManager:requireFiles(tFiles)
    local Files = {}

    for _, file in ipairs(tFiles) do
        table.insert(Files, {path = file, available = File.exists(file)})
    end

    self:validateFiles(Files)
end

function CDownloadManager:validateFiles(tFiles)
    for _, file in ipairs(tFiles) do
       if file.available then
           local eFile = File(file.path)
           file.hash = md5(eFile:read(eFile:getSize()))
           eFile:close()
       end
    end

    RPC:call("DownloadManager:validateClientFiles", tFiles)
end

function CDownloadManager:receiveFiles(tFiles)
    for _, file in ipairs(tFiles) do
        local eFile = File.new(file.path)
        eFile:write(file.content)
        eFile:close()
    end
end

--[[Example usage
-
    Core:getManager("CDownloadManager"):requireFiles(
        {
            "res/images/iGaming.png",
            "res/images/moreFiles.png"
        }
    )
-
 ]]