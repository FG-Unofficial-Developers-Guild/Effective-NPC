--  	Author: Ryan Hagelstrom
--	  	Copyright © 2021
--	  	This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
--	  	https://creativecommons.org/licenses/by-sa/4.0/
local parseEffects = nil;

function onInit()
    parseEffects = PowerManager.parseEffects;
    PowerManager.parseEffects = customParseEffect;
end

function customParseEffect(sPowerName, aWords)
    local effects = parseEffects(sPowerName, aWords);
    local sPower = table.concat(aWords, ' '):lower();
    local bValid = false;
    -- Do we have the key phrase "has become"
    if (sPower:match('has become')) then
        -- Find the effect name in our custom effects list
        for _, v in pairs(DB.getChildrenGlobal('effects')) do
            local sEffect = DB.getValue(v, 'label', '');
            if sEffect ~= nil and sEffect ~= '' then
                local aEffectComps = EffectManager.parseEffect(sEffect);
                -- Is this the effeect we are looking for?
                -- Name is parsed to index 1 in the array
                local sMatchString = 'has become ' .. aEffectComps[1]:lower();
                if sPower:match(sMatchString) then
                    local aEffectWords = {};
                    for word in aEffectComps[1]:lower():gmatch('%w+') do
                        table.insert(aEffectWords, word);
                    end
                    for i = 1, #aWords do
                        bValid = true;
                        if StringManager.isWord(aWords[i], 'has') and StringManager.isWord(aWords[i + 1], 'become') then
                            local j = i + 2;
                            for k = 1, #aEffectWords do
                                if (aEffectWords[k] ~= aWords[j]) then
                                    bValid = false;
                                    break
                                end
                                j = j + 1;
                            end
                            if bValid == true then
                                local rCurrent = {};
                                rCurrent.sName = sEffect;
                                rCurrent.startindex = i;
                                j = j - 1;
                                rCurrent.endindex = j;
                                rCurrent.nGMOnly = tonumber(DB.getChild(v, 'isgmonly'));
                                rCurrent.nDuration = tonumber(DB.getChild(v, 'duration'));
                                rCurrent.sUnits = DB.getChild(v, 'unit');
                                PowerManager.parseEffectsAdd(aWords, i, rCurrent, effects);
                            end
                        end
                    end
                end
            end
        end
    end
    return effects;
end

-- Set things back the way they origiinally were
function onClose()
    PowerManager.parseEffects = parseEffects;
end
