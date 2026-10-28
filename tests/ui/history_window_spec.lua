local ui = require("tests.helpers.history_ui")
local function fixture(addon)
    addon.db.sessionHistory = {
        { id=1, name="Coiled Isle - 2026-10-25 22:00:00", savedBy="Janis - Magtheridon", startTime=100, stopTime=5000,
          recordingPeriods={{startTime=100,stopTime=200},{startTime=4900,stopTime=5000}},
          locationVisits={{locationKey="zone:2512",locationLabel="The Coiled Isle",startTime=100,stopTime=200},
              {locationKey="zone:2512",locationLabel="The Coiled Isle",startTime=4900,stopTime=5000}},
          itemLoots={
              {itemLink="item:1",quantity=2,totalValue=1000,vendorTotalValue=10,ahTracked=true,mapID=2512,mapName="The Coiled Isle",zoneName="Gate",timestamp=110},
              {itemLink="item:2",quantity=3,totalValue=0,vendorTotalValue=30,ahTracked=false,mapID=2512,mapName="The Coiled Isle",zoneName="The Coiled Isle",timestamp=4990},
          }, moneyLoots={{amount=50,timestamp=150,mapID=2512,mapName="The Coiled Isle"}},
        },
        { id=2,name="My custom session",savedBy="Other - Realm",startTime=1,stopTime=90000,
          itemLoots={{itemLink="item:3",quantity=1,totalValue=200,vendorTotalValue=5,ahTracked=true,mapID=1,mapName="Old place",timestamp=1}} },
    }
    addon:RefreshHistoryWindow()
end

describe("Session history window", function()
    it("keeps row deletion pending until the selected action is confirmed", function()
        ui.with_ui(function(addon)
            fixture(addon)
            addon:OpenHistoryRowMenu(1,addon.historyFrame.rows[1].menuButton)
            for _,entry in ipairs(ui.menu) do if entry.text=="Delete..." then entry.func() end end
            assert.equals(2,#addon.db.sessionHistory)
            assert.equals("delete",ui.popup.data.action)
            StaticPopupDialogs[ui.popup.key].OnAccept({data=ui.popup.data})
            assert.equals(1,#addon.db.sessionHistory)
            assert.equals(2,addon.db.sessionHistory[1].id)
        end)
    end)
    it("keeps filters, page, sort and selection when returning from details", function()
        ui.with_ui(function(addon)
            fixture(addon)
            local f=addon.historyFrame
            f.query="coiled"; f.selectedSessionIDs[1]=true; f.sortKey="duration"; f.sortAscending=true
            addon:RefreshHistoryWindow(); addon:ShowHistoryDetailsView(1); addon:ShowHistoryListView()
            assert.equals("coiled",f.query); assert.is_true(f.selectedSessionIDs[1])
            assert.equals("duration",f.sortKey); assert.equals(1,#f.visibleSessionIDs)
        end)
    end)

    it("shows all loot, groups subzones and navigates from locations to scoped loot", function()
        ui.with_ui(function(addon)
            fixture(addon); addon:ShowHistoryDetailsView(1)
            local f=addon.historyFrame
            assert.is_true(f.detailRows[2]:IsShown())
            assert.equals("00:03:20",f.cards[3].value:GetText())
            f.detailsTab="locations"; addon:RefreshHistoryDetailsWindow()
            assert.equals("The Coiled Isle",f.detailRows[1].cells[1]:GetText())
            assert.equals("2",f.detailRows[1].cells[4]:GetText())
            assert.is_false(f.detailRows[2]:IsShown())
            f.detailRows[1].activate()
            assert.equals("loot",f.detailsTab); assert.equals("loc:zone:2512",f.detailsLocationFilterKey)
            assert.equals("Scope: The Coiled Isle",f.scopeText:GetText())
        end)
    end)

    it("labels legacy timing and honors custom names in both views", function()
        ui.with_ui(function(addon)
            fixture(addon); addon:ShowHistoryDetailsView(2)
            local f=addon.historyFrame
            assert.equals("My custom session",f.sessionNameText:GetText())
            assert.equals("Elapsed span (legacy)",f.cards[3].note:GetText())
            f.detailsTab="locations"; addon:RefreshHistoryDetailsWindow()
            assert.equals("Unknown",f.detailRows[1].cells[5]:GetText())
        end)
    end)

    it("applies location and style to the breakdown and export", function()
        ui.with_ui(function(addon)
            fixture(addon); addon:ShowHistoryDetailsView(1)
            local f=addon.historyFrame
            f.detailsItemFilter="vendor"; addon:RefreshHistoryDetailsWindow()
            assert.equals("item:2",f.detailRows[1].itemLink)
            local csv=addon:BuildHistorySessionCSV(1)
            assert.is_truthy(csv:find("item:2",1,true)); assert.is_nil(csv:find("item:1",1,true))
            addon:ShowHistoryListView()
            csv=addon:BuildHistorySessionCSV(1)
            assert.is_truthy(csv:find("item:1",1,true)); assert.is_truthy(csv:find("item_view,all",1,true))
            addon:OpenHistoryLootBreakdownWindow(1)
            assert.equals("breakdown",f.detailsTab)
            assert.equals("5",f.detailRows[6].cells[2]:GetText())
        end)
    end)
end)
