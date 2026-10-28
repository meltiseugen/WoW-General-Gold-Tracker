local loader = require("tests.helpers.addon_loader")
local function clone(value)
    if type(value) ~= "table" then return value end
    local result = {}; for k,v in pairs(value) do result[k]=clone(v) end; return result
end
local function with_addon(callback)
    local now = 100
    loader.with_globals({
        time = function() return now end, date = os.date,
        GetMoneyString = tostring, UnitName = function() return "Tester" end,
        GetRealmName = function() return "Realm" end,
    }, function()
        local addon, ns = loader.load_module("Core/Namespace.lua", {})
        addon.db = clone(addon.DEFAULTS); addon.db.sessionHistory={}; addon.db.nextHistoryID=1
        addon.Print=function() end; addon.ClearLog=function() end; addon.UpdateMainWindow=function() end
        addon.AddLogMessage=function() end
        addon.GetCurrentValueSource=function() return {id="test",label="Test prices"} end
        addon.GetValueSourceLabel=function(_,_,label) return label or "Test prices" end
        addon.GetItemQualityFromLink=function() return 2 end
        addon.IsCraftingReagentItem=function() return false end
        for _,path in ipairs({"Core/SessionData.lua","Core/History.lua","Core/SessionFlow.lua","Core/Session.lua"}) do
            assert(loadfile(path))("General-Gold-Tracker",ns)
        end
        local location={locationKey="zone:1",mapID=1,mapName="Test zone",zoneName="Test zone",isInstanced=false}
        addon.GetCurrentLocationSnapshot=function() return clone(location) end
        callback(addon,function(value) now=value end,function(value) location=value end)
    end)
end

describe("Session recording periods and locations",function()
    it("deduplicates repeated descriptions and restores direct event field access after serialization",function()
        with_addon(function(addon)
            local session={itemLoots={
                {itemLink="item:1",mapID=1,mapPath="World > Zone",zoneName="Zone",mapX=0.1},
                {itemLink="item:2",mapID=1,mapPath="World > Zone",zoneName="Zone",mapX=0.2},
            },moneyLoots={{amount=25,mapID=1,mapPath="World > Zone",zoneName="Zone"}}}
            addon:CompactSessionLocations(session)
            assert.equals(1,#session.locations)
            assert.is_nil(rawget(session.itemLoots[1],"mapPath"))
            assert.equals("World > Zone",session.itemLoots[1].mapPath)
            local restored=clone(session)
            assert.is_nil(restored.itemLoots[1].mapPath)
            addon:HydrateSessionLocations(restored)
            assert.equals("World > Zone",restored.itemLoots[2].mapPath)
            assert.equals(0.2,restored.itemLoots[2].mapX)
            assert.equals("Zone",restored.moneyLoots[1].zoneName)
            addon:CompactSessionLocations(restored)
            assert.equals(1,#restored.locations)
        end)
    end)

    it("excludes reload downtime and preserves a single recording",function()
        with_addon(function(addon,set_time)
            addon.db.resumeSessionAfterReload=true
            addon:StartSession(); set_time(200)
            addon.session.goldLooted=25; addon.session.moneyLoots={{amount=25,timestamp=150,mapID=1,zoneName="Test zone"}}
            addon:StorePendingReloadSession()
            addon.session={active=false}; set_time(1000)
            assert.is_true(addon:TryRestorePendingReloadSession())
            set_time(1100); addon:StopSession()
            local history=addon:GetSessionHistory()
            assert.equals(1,#history); assert.equals(200,history[1].duration)
            assert.equals(2,#history[1].recordingPeriods); assert.equals(2,#history[1].locationVisits)
            assert.equals(25,history[1].rawGold)
        end)
    end)

    it("resumes into the same history row and excludes the gap",function()
        with_addon(function(addon,set_time)
            addon:StartSession(); addon.session.goldLooted=10; set_time(200); addon:StopSession()
            local id=addon.db.sessionHistory[1].id
            set_time(10000); assert.is_true(addon:ResumeHistorySession(id))
            assert.is_false(addon:ResumeHistorySession(id))
            addon.session.goldLooted=30; set_time(10100); addon:StopSession()
            local history=addon:GetSessionHistory()
            assert.equals(1,#history); assert.equals(id,history[1].id)
            assert.equals(200,history[1].duration); assert.equals(30,history[1].rawGold)
        end)
    end)

    it("records repeated visits without starting sessions in continuous mode",function()
        with_addon(function(addon,set_time,set_location)
            addon:StartSession(); set_time(150)
            set_location({locationKey="instance:50",instanceMapID=50,instanceName="Dungeon",isInstanced=true})
            assert.is_false(addon:HandleSessionLocationTransition())
            set_time(200); set_location({locationKey="zone:1",mapID=1,mapName="Test zone",isInstanced=false})
            assert.is_false(addon:HandleSessionLocationTransition())
            addon.session.goldLooted=10; set_time(250); addon:StopSession()
            assert.equals(1,#addon.db.sessionHistory)
            assert.equals(3,#addon.db.sessionHistory[1].locationVisits)
            assert.equals(150,addon.db.sessionHistory[1].duration)
        end)
    end)

    it("uses stable map identity for subzones and instance floors",function()
        with_addon(function(addon)
            assert.equals(addon:GetLocationGroupKey({mapID=1,zoneName="Gate"}),addon:GetLocationGroupKey({mapID=1,zoneName="Island"}))
            assert.equals(addon:GetLocationGroupKey({isInstanced=true,instanceMapID=50,mapID=100}),addon:GetLocationGroupKey({isInstanced=true,instanceMapID=50,mapID=101}))
        end)
    end)

    it("keeps instance identity separate from the UI map used for location descriptions",function()
        with_addon(function(addon)
            loader.load_module("Core/History.lua",addon)
            loader.with_globals({
                GetRealZoneText=function() return "Dungeon floor" end,
                IsInInstance=function() return true,"party" end,
                GetInstanceInfo=function() return "Dungeon","party",1,"Normal",5,false,false,50 end,
                C_Map={GetBestMapForUnit=function() return 100 end,GetMapInfo=function(id) return {name="UI floor",mapID=id,parentMapID=0,mapType=4} end},
            },function()
                local snapshot=addon:GetCurrentLocationSnapshot()
                assert.equals(50,snapshot.instanceMapID)
                assert.equals(100,snapshot.mapID)
                assert.equals("instance:50",snapshot.locationKey)
            end)
        end)
    end)

    it("merges disjoint recordings without adding the time between runs",function()
        with_addon(function(addon)
            addon.db.sessionHistory={
                {id=1,startTime=100,stopTime=200,recordingPeriods={{startTime=100,stopTime=200}},rawGold=10},
                {id=2,startTime=10000,stopTime=10100,recordingPeriods={{startTime=10000,stopTime=10100}},rawGold=20},
            }
            addon.db.nextHistoryID=3
            local merged=addon:MergeHistorySessions({1,2})
            assert.equals(200,merged.duration); assert.equals(30,merged.rawGold)
            assert.equals(1,#addon.db.sessionHistory)
            assert.equals(150,addon:GetSessionIntervalDuration({{startTime=100,stopTime=200},{startTime=150,stopTime=250}}))
        end)
    end)

    it("does not expand compact locations while normalizing saved history",function()
        with_addon(function(addon)
            local entry={id=1,startTime=100,stopTime=200,itemLoots={{itemLink="item:1",quantity=1,totalValue=10,mapID=1,mapName="Zone"}}}
            addon:CompactSessionLocations(entry); addon.db.sessionHistory={clone(entry)}
            local history=addon:GetSessionHistory()
            assert.equals("Zone",history[1].itemLoots[1].mapName)
            assert.is_nil(rawget(history[1].itemLoots[1],"mapName"))
            addon:GetSessionHistory()
            assert.is_nil(rawget(history[1].itemLoots[1],"mapID"))
        end)
    end)

    it("saves the active run before resuming another recording",function()
        with_addon(function(addon,set_time)
            addon:StartSession(); addon.session.goldLooted=10; set_time(200); addon:StopSession()
            local originalID=addon.db.sessionHistory[1].id
            set_time(500); addon:StartSession(); addon.session.goldLooted=20
            set_time(600); addon:ResumeHistorySession(originalID)
            assert.equals(10,addon.session.goldLooted)
            assert.equals(2,#addon.db.sessionHistory)
            set_time(700); addon:StopSession()
            assert.equals(2,#addon.db.sessionHistory)
            assert.equals(200,addon:GetHistorySessionByID(originalID).duration)
        end)
    end)

    it("saves the previous recording before a manual New Session",function()
        with_addon(function(addon,set_time)
            addon:StartSession(); addon.session.goldLooted=10; set_time(200)
            addon:StartSession(true)
            assert.equals(1,#addon.db.sessionHistory)
            assert.equals(10,addon.db.sessionHistory[1].rawGold)
            assert.equals(0,addon.session.goldLooted)
            assert.equals(200,addon.session.startTime)
        end)
    end)

    it("splits by the main map and sums separate visits rather than their span",function()
        with_addon(function(addon)
            addon.db.nextHistoryID=2
            addon.db.sessionHistory={{id=1,startTime=100,stopTime=1050,
                itemLoots={
                    {itemLink="item:1",quantity=1,totalValue=10,mapID=1,mapName="Island",zoneName="Gate",timestamp=110},
                    {itemLink="item:2",quantity=1,totalValue=20,mapID=1,mapName="Island",zoneName="Beach",timestamp=1020},
                    {itemLink="item:3",quantity=1,totalValue=30,mapID=2,mapName="Other zone",timestamp=500},
                },locationVisits={
                    {locationKey="zone:1",locationLabel="Island",startTime=100,stopTime=150},
                    {locationKey="zone:2",locationLabel="Other zone",startTime=150,stopTime=1000},
                    {locationKey="zone:1",locationLabel="Island",startTime=1000,stopTime=1050},
                }}}
            local split=addon:SplitHistorySessionByLocation(1)
            assert.equals(2,#split)
            local total=0
            for _,s in ipairs(split) do
                total=total+s.totalValue
                if s.locationKey=="zone:1" then assert.equals(100,s.duration); assert.equals(2,#s.itemLoots) end
            end
            assert.equals(60,total)
        end)
    end)
end)
