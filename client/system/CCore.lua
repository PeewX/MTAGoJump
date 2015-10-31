--
-- HorrorClown (PewX)
-- Using: IntelliJ IDEA 14 Ultimate
-- Date: 19.12.2014 - Time: 18:41
-- pewx.de // iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
CCore = inherit(CSingleton)        --Client Core

function CCore:constructor()
    self.managers = {}
    fadeCamera(true)
    ---Manager Table: {"ManagerName", {arguments}}
end

function CCore:destructor()

end

function CCore:getManager(sName)
    return self[sName]
end

function CCore:startScript()
    for _, v in ipairs(self.managers) do
        if (type(_G[v[1]]) == "table") then
            self[tostring(v[1])] = new(_G[v[1]], unpack(v[2]))
            debugOutput(("[CCore] Loading manager '%s'"):format(tostring(v[1])))
        else
            debugOutput(("[CCore] Couldn't find manager '%s'"):format(tostring(v[1])))
        end
    end
end

--Create the Core Instance
addEventHandler("onClientResourceStart", resourceRoot,
    function()
        local s = getTickCount()
        debugOutput("[CCore] Start MTAGoJump")
        RPC = new(CRPC)
        Event = new(CEvent)
        Core = new(CCore)
        Core:startScript()
        debugOutput(("[CCore] Starting finished (%sms)"):format(getTickCount()-s))

        GoJump = new(GoJump)
       -- Login = new(CLogin)

        --triggerServerEvent("onClientResourceStarted", resourceRoot)
    end
)
