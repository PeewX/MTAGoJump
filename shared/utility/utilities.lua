--
-- HorrorClown (PewX)
-- Using: IntelliJ IDEA 13 Ultimate
-- Date: 24.12.2014 - Time: 04:34
-- iGaming-mta.de // iRace-mta.de // iSurvival.de // mtasa.de
--
if CLIENT then x, y = guiGetScreenSize() me = getLocalPlayer() end
iDEBUG = true

function isHover(startX, startY, width, height)
    if isCursorShowing() then
        local pos = {getCursorPosition()}
        return (x*pos[1] >= startX) and (x*pos[1] <= startX + width) and (y*pos[2] >= startY) and (y*pos[2] <= startY + height)
    end
    return false
end

function clearText(sText)
    return sText:gsub("#%x%x%x%x%x%x", ""):gsub("#%x%x%x%x%x%x", "")
end

function debugOutput(sText, nType, cr, cg, cb)
    if iDEBUG then
        outputDebugString(("[%s] %s"):format(SERVER and "Server" or "Client", sText), nType or 3, cr, cg, cb)
    end
end