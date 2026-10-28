local _, NS = ...
local GoldTracker, Theme = NS.GoldTracker, NS.JanisTheme
local Constants, Model = NS.HistoryConstants, NS.HistorySessionModel
local formatter = NS.HistoryFormatter:New(GoldTracker)
local service = NS.HistoryDataService:New(GoldTracker)
local dates = NS.HistoryDateFilter:New()
local ALL = Constants.DETAILS_LOCATION_FILTER_ALL
local DETAILS_LOCATION_FILTER_ALL = ALL
local SORT_KEYS = { duration=true, sessionTotal=true, sessionTotalRaw=true, highlights=true, rate=true, date=true }
local ITEM_FILTERS = { {key="all",label="All loot"}, {key="auction",label="Auction-valued"}, {key="vendor",label="Vendor-only"}, {key="bound",label="Bound"} }
local STYLE_FILTERS = { {key="all",label="All styles"}, {key="crafting",label="Crafting reagents"}, {key="armorWeapons",label="Armor & weapons"}, {key="other",label="Other items"} }
local function CreateFrame(...) return (NS.CreateThemedFrame or _G.CreateFrame)(...) end
local function Color(key) return (Theme.colors and Theme.colors[key]) or {0.85,0.85,0.85,1} end
local function Text(parent, value, size, color, justify)
    local t=parent:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    t:SetText(value or ""); t:SetJustifyH(justify or "LEFT"); t:SetWordWrap(false)
    t:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",size or 12,"")
    t:SetTextColor(unpack(Color(color or "text")))
    return t
end
local function FitText(text, value, preferred, minimum)
    local size=preferred
    text:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",size,"")
    text:SetText(value)
    while size>minimum and text:GetStringWidth()>text:GetWidth() do
        size=size-1; text:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",size,"")
    end
end
local function Button(parent,width,label,fn,palette)
    local b=Theme:CreateButton(parent,width,24,label,palette or "neutral")
    b:SetScript("OnClick",fn); return b
end
local function CreateHistoryPanel(parent,bg,border) return Theme:CreatePanel(parent,bg or "panel",border or "goldBorder") end
local function Tip(target,title,body)
    target:SetScript("OnEnter",function(self)
        GameTooltip:SetOwner(self,"ANCHOR_RIGHT"); GameTooltip:SetText(type(title)=="function" and title() or title)
        local detail=type(body)=="function" and body() or body
        if detail and detail~="" then
            local color=Color("textSoft")
            GameTooltip:AddLine(detail,color[1],color[2],color[3],true)
        end
        GameTooltip:Show()
    end)
    target:SetScript("OnLeave",function() GameTooltip:Hide() end)
end
local function Anchor(widget,parent,x,y,width,height)
    widget:ClearAllPoints(); widget:SetPoint("TOPLEFT",parent,"TOPLEFT",x,-y)
    if width then widget:SetWidth(math.max(1,width)) end
    if height then widget:SetHeight(math.max(1,height)) end
end
local function Scroll(parent)
    local scroll=CreateFrame("ScrollFrame",nil,parent,"UIPanelScrollFrameTemplate")
    local content=CreateFrame("Frame",nil,scroll); content:SetSize(1,1); scroll:SetScrollChild(content)
    content:SetPoint("TOPLEFT",scroll,"TOPLEFT",0,0)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel",function(self,delta)
        self:SetVerticalScroll(math.max(0,math.min(self:GetVerticalScrollRange(),self:GetVerticalScroll()-delta*42)))
    end)
    return scroll,content
end
local function Dropdown(parent,width,choices,get,set)
    local d=CreateFrame("Frame",nil,parent,"UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(d,width)
    UIDropDownMenu_Initialize(d,function(_,level)
        for _, choice in ipairs(type(choices)=="function" and choices() or choices) do
            local option=choice; local info=UIDropDownMenu_CreateInfo()
            info.text,info.value,info.checked=option.label,option.key,get()==option.key
            info.func=function() set(option.key); CloseDropDownMenus() end
            UIDropDownMenu_AddButton(info,level)
        end
    end)
    d.refresh=function()
        local value=get(); local label
        for _, option in ipairs(type(choices)=="function" and choices() or choices) do if option.key==value then label=option.label end end
        UIDropDownMenu_SetSelectedValue(d,value); UIDropDownMenu_SetText(d,label or "All")
    end
    return d
end
local function ModelFor(session) return Model:New(GoldTracker,session) end
local function Money(value) return GoldTracker:FormatMoney(math.max(0,tonumber(value) or 0)) end
local function Rate(value,duration)
    if not duration or duration<=0 then return "--" end
    return GoldTracker:FormatMoneyPerHour(value,duration)
end
local function Date(ts) return tonumber(ts) and ts>0 and date("%Y-%m-%d %H:%M",ts) or "Unknown" end
local function Header(parent,label,key)
    local b=CreateFrame("Button",nil,parent); b:SetHeight(20)
    b.text=Text(b,label,12,"titleText"); b.text:SetPoint("LEFT",b,"LEFT",0,0); b.text:SetPoint("RIGHT",b,"RIGHT",-14,0)
    b.sortIcon=b:CreateTexture(nil,"ARTWORK"); b.sortIcon:SetSize(10,10); b.sortIcon:SetPoint("RIGHT"); b.sortIcon:Hide()
    b.sortLabel=label
    if key then GoldTracker:BindTableSortHeaderClick(b,GoldTracker.ToggleHistorySort,key) end
    return b
end
local function Row(parent)
    local r=CreateFrame("Button",nil,parent)
    r.bg=r:CreateTexture(nil,"BACKGROUND"); r.bg:SetAllPoints(r)
    r.hover=r:CreateTexture(nil,"HIGHLIGHT"); r.hover:SetAllPoints(r)
    local c=Color("rowSelected"); r.hover:SetColorTexture(c[1],c[2],c[3],0.12)
    return r
end
local function RegisterHistoryPopupFrame(name) Theme:RegisterSpecialFrame(name) end
local function BringHistoryPopupToFront(frame) Theme:BringToFront(frame,GoldTracker.historyFrame) end
local function CreateHistoryPopupChrome(frame,title) return Theme:ApplyWindowChrome(frame,title,{closeButtonKey="popupCloseButton"}) end
local function EscapeCSVValue(value)
    local text=tostring(value or ""):gsub("\r"," "):gsub("\n"," ")
    return text:find('[",]') and ('"'..text:gsub('"','""')..'"') or text
end
local function BuildHistoryDetailsSummary(session,location,style) return service:BuildHistoryDetailsSummary(session,location,style) end
local function BuildVisibleHistoryItems(session,location,style)
    local f=GoldTracker.historyFrame
    local itemView=f and f.view=="details" and f.selectedSessionID==session.id and f.detailsItemFilter or "all"
    return service:BuildVisibleHistoryItems(session,location,style,itemView)
end

function GoldTracker:PromptRenameHistorySession(id)
    local key="GOLDTRACKER_RENAME_HISTORY_SESSION"
    StaticPopupDialogs[key]={text="Rename session",button1=ACCEPT,button2=CANCEL,hasEditBox=true,maxLetters=120,timeout=0,whileDead=true,hideOnEscape=true,
        OnShow=function(dialog)
            local edit=dialog.GetEditBox and dialog:GetEditBox() or dialog.editBox or dialog.EditBox
            local session=GoldTracker:GetHistorySessionByID(dialog.data)
            if edit then edit:SetText(session and ModelFor(session):BuildRowTitleAndSubtitle() or ""); edit:HighlightText() end
        end,
        OnAccept=function(dialog)
            local edit=dialog.GetEditBox and dialog:GetEditBox() or dialog.editBox or dialog.EditBox
            if edit then GoldTracker:RenameHistorySession(dialog.data,edit:GetText()) end
        end,
    }
    StaticPopup_Show(key,nil,nil,id)
end
function GoldTracker:PromptSplitHistorySession(id)
    local key="GOLDTRACKER_SPLIT_HISTORY_SESSION"
    StaticPopupDialogs[key]={text="Split this recording into sessions for each main location? The original row will be replaced.",button1=ACCEPT,button2=CANCEL,timeout=0,whileDead=true,hideOnEscape=true,
        OnAccept=function(dialog) GoldTracker:SplitHistorySessionByLocation(dialog.data) end}
    StaticPopup_Show(key,nil,nil,id)
end
local function ConfirmHistoryAction(action,ids)
    local key="GOLDTRACKER_HISTORY_ACTION"
    StaticPopupDialogs[key]={text=action=="merge" and "Merge the selected sessions? Their source rows will be replaced." or "Delete the selected sessions? This cannot be undone.",
        button1=ACCEPT,button2=CANCEL,timeout=0,whileDead=true,hideOnEscape=true,
        OnAccept=function(dialog)
            local data=dialog.data
            if not data then return end
            if data.action=="merge" then GoldTracker:MergeHistorySessions(data.ids) else GoldTracker:DeleteHistorySessions(data.ids) end
            GoldTracker:ClearHistorySelection(); GoldTracker:RefreshHistoryWindow()
        end}
    StaticPopup_Show(key,nil,nil,{action=action,ids=ids})
end
function GoldTracker:OpenHistoryRowMenu(id,anchor)
    local f=self.historyFrame; f.menuSessionID=id
    UIDropDownMenu_Initialize(f.actionMenu,function(_,level)
        local session=self:GetHistorySessionByID(f.menuSessionID)
        if not session then return end
        local function add(label,fn,disabled)
            local info=UIDropDownMenu_CreateInfo(); info.text=label; info.notCheckable=true; info.disabled=disabled
            info.func=function() CloseDropDownMenus(); fn() end; UIDropDownMenu_AddButton(info,level)
        end
        add(session.pinned and "Unpin" or "Pin",function() self:ToggleHistorySessionPinned(id) end)
        add("Rename",function() self:PromptRenameHistorySession(id) end)
        add("Export current view",function() self:OpenHistorySessionExport(id) end)
        if not session.isFarm and session.recordType~="farm" then
            add("Split by main location",function() self:PromptSplitHistorySession(id) end,#ModelFor(session):BuildHistoryLocationOptions()<3)
            add("Diagnosis",function() self:OpenHistoryDiagnosisWindow(id) end,not self:IsDiagnosticsPanelEnabled())
        end
        add("Delete...",function() ConfirmHistoryAction("delete",{id}) end)
    end)
    ToggleDropDownMenu(1,nil,f.actionMenu,anchor,0,0)
end

function GoldTracker:CreateHistoryWindow()
    if self.historyFrame then return end
    local f=CreateFrame("Frame","GoldTrackerHistoryFrame",UIParent)
    f:SetSize(1080,720); f:SetPoint("CENTER"); f:SetFrameStrata("DIALOG"); f:SetClampedToScreen(true)
    f:SetMovable(true); f:SetResizable(true); f:SetResizeBounds(920,610,1600,1000)
    f:EnableMouse(true); f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart",function(self) self:StartMoving() end); f:SetScript("OnDragStop",f.StopMovingOrSizing)
    f:Hide(); f.view="list"; f.currentPage=1; f.sortCriteria={}; f.selectedSessionIDs={}; f.rows={}; f.detailRows={}
    f.historyDateFilterKey=Constants.DATE_FILTER_ALL; f.characterFilter=ALL; f.historyLocationFilter=ALL; f.query=""
    f.detailsTab="loot"; f.detailsLocationFilterKey=ALL; f.detailsStyleFilterID="all"; f.detailsItemFilter="all"
    f.expandedItems={}; f.expandedLocations={}; f.listInfo={}
    self.historyFrame=f
    local chrome,bar=Theme:ApplyWindowChrome(f,"Session History",{titleRightOffset=-180,closeButtonKey="historyCloseButton"})
    Theme:RegisterSpecialFrame("GoldTrackerHistoryFrame")
    f.backButton=Button(bar,70,"Back",function() self:ShowHistoryListView() end)
    f.backButton:SetPoint("RIGHT",f.historyCloseButton,"LEFT",-8,0); f.backButton:Hide()
    f.actionMenu=CreateFrame("Frame",nil,f,"UIDropDownMenuTemplate")
    local list=CreateHistoryPanel(f); list:SetPoint("TOPLEFT",chrome,"TOPLEFT",12,-54); list:SetPoint("BOTTOMRIGHT",chrome,"BOTTOMRIGHT",-12,12); f.listContainer=list
    local function refilter() f.currentPage=1; f.selectedSessionIDs={}; self:RefreshHistoryWindow() end
    f.search=CreateFrame("EditBox",nil,list,"InputBoxTemplate"); f.search:SetAutoFocus(false); f.search:SetMaxLetters(120)
    f.search:SetFontObject(GameFontHighlightSmall)
    f.search:SetScript("OnEscapePressed",function(edit) edit:SetText(""); edit:ClearFocus() end)
    f.search:SetScript("OnTextChanged",function(edit) f.query=string.lower(edit:GetText() or ""); refilter() end)
    f.searchHint=Text(list,"Search sessions or locations",12,"textMuted")
    f.searchHint:SetPoint("LEFT",f.search,"LEFT",5,0)
    f.historyDateFilterDropdown=Dropdown(list,128,function() return Constants.DATE_FILTER_OPTIONS end,function() return f.historyDateFilterKey end,function(key) f.historyDateFilterKey=key; refilter() end)
    f.characterDropdown=Dropdown(list,144,function() return f.characterOptions or {} end,function() return f.characterFilter end,function(key) f.characterFilter=key; refilter() end)
    f.historyLocationDropdown=Dropdown(list,170,function() return f.locationOptions or {} end,function() return f.historyLocationFilter end,function(key) f.historyLocationFilter=key; refilter() end)
    Tip(f.search,"Search history","Matches the session name, character, and recorded locations. Escape clears search.")
    f.selectionText=Text(list,"",12,"textMuted")
    f.mergeButton=Button(list,110,"Merge",function() ConfirmHistoryAction("merge",self:GetSelectedHistorySessionIDsInOrder()) end)
    f.bulkDeleteButton=Button(list,120,"Delete selected",function() ConfirmHistoryAction("delete",self:GetSelectedHistorySessionIDsInOrder()) end,"danger")
    f.clearSelectionButton=Button(list,72,"Clear",function() self:ClearHistorySelection(); self:RefreshHistoryWindow() end)
    f.listHeaderButton=Header(list,"Session",nil)
    f.durationHeaderButton=Header(list,"Duration","duration"); f.totalHeaderButton=Header(list,"Estimated value","sessionTotal"); f.rateHeaderButton=Header(list,"Value / hour","rate")
    f.sortHeaders={duration=f.durationHeaderButton,sessionTotal=f.totalHeaderButton,rate=f.rateHeaderButton}
    f.selectPageCheckbox=CreateFrame("CheckButton",nil,list,"UICheckButtonTemplate"); f.selectPageCheckbox:SetSize(22,22)
    f.selectPageCheckbox:SetScript("OnClick",function(b) self:SetHistoryCurrentPageSelection(b:GetChecked()==true) end)
    Tip(f.selectPageCheckbox,"Select this page","Selects visible rows. The selection count includes other pages until you clear it or change a filter.")
    f.scrollFrame,f.content=Scroll(list); f.scrollFrame:SetPoint("TOPLEFT",list,"TOPLEFT",8,-116); f.scrollFrame:SetPoint("BOTTOMRIGHT",list,"BOTTOMRIGHT",-28,50)
    f.scrollFrame:SetScript("OnMouseWheel",function(_,delta) self:HandleHistoryPageMouseWheel(delta) end)
    f.emptyText=Text(f.content,"No sessions match these filters.",14,"textMuted"); f.emptyText:SetPoint("TOPLEFT",f.content,"TOPLEFT",12,-16)
    f.prevPageButton=Button(list,32,"<",function() self:SetHistoryPage(f.currentPage-1) end); f.prevPageButton:SetPoint("BOTTOMLEFT",list,"BOTTOMLEFT",14,14)
    f.nextPageButton=Button(list,32,">",function() self:SetHistoryPage(f.currentPage+1) end); f.nextPageButton:SetPoint("LEFT",f.prevPageButton,"RIGHT",6,0)
    f.pageText=Text(list,"",12,"textMuted"); f.pageText:SetPoint("LEFT",f.nextPageButton,"RIGHT",12,0)
    f.listRateHint=Text(list,"",11,"textMuted","RIGHT"); f.listRateHint:SetPoint("BOTTOMRIGHT",list,"BOTTOMRIGHT",-16,20)
    local details=CreateHistoryPanel(f); details:SetPoint("TOPLEFT",chrome,"TOPLEFT",12,-54); details:SetPoint("BOTTOMRIGHT",chrome,"BOTTOMRIGHT",-12,12); details:Hide(); f.detailsContainer=details
    f.sessionNameText=Text(details,"",20,"text")
    f.nameTooltip=CreateFrame("Frame",nil,details); f.nameTooltip:SetAllPoints(f.sessionNameText); f.nameTooltip:EnableMouse(true)
    Tip(f.nameTooltip,function()
        local session=self:GetHistorySessionByID(f.selectedSessionID)
        return session and ModelFor(session):BuildRowTitleAndSubtitle() or "Session"
    end,function()
        local session=self:GetHistorySessionByID(f.selectedSessionID)
        return session and (session.valueSourceLabel or "") or ""
    end)
    f.metadataText=Text(details,"",12,"textMuted"); f.metadataText:SetWordWrap(true)
    f.resumeSessionButton=Button(details,96,"Resume",function() self:ResumeHistorySession(f.selectedSessionID); self:RefreshHistoryDetailsWindow() end,"primary")
    Tip(f.resumeSessionButton,"Resume recording","Continues this history row in a new recording period. Any active session is saved first. The gap between recordings is excluded.")
    f.detailsMenu=Button(details,30,"...",function(b) self:OpenHistoryRowMenu(f.selectedSessionID,b) end)
    f.cards={}
    for i=1,4 do
        local card=CreateHistoryPanel(details); card.label=Text(card,"",11,"textMuted"); card.value=Text(card,"",16,"text"); card.note=Text(card,"",11,"textMuted")
        Anchor(card.label,card,12,10); Anchor(card.value,card,12,29); Anchor(card.note,card,12,55)
        card:EnableMouse(true); f.cards[i]=card
    end
    f.locationFilterDropdown=Dropdown(details,230,function() return f.detailsLocationOptions or {} end,function() return f.detailsLocationFilterKey end,function(key) f.detailsLocationFilterKey=key; f.expandedItems={}; self:ResetHistoryDetailsScroll(); self:RefreshHistoryDetailsWindow() end)
    f.styleFilterDropdown=Dropdown(details,152,STYLE_FILTERS,function() return f.detailsStyleFilterID end,function(key) f.detailsStyleFilterID=key; self:ResetHistoryDetailsScroll(); self:RefreshHistoryDetailsWindow() end)
    f.itemFilterDropdown=Dropdown(details,146,ITEM_FILTERS,function() return f.detailsItemFilter end,function(key) f.detailsItemFilter=key; self:ResetHistoryDetailsScroll(); self:RefreshHistoryDetailsWindow() end)
    Tip(f.itemFilterDropdown,"Loot view","Filters the item table. The summary cards and Breakdown follow the selected location and style.")
    f.tabButtons={}
    for i,tab in ipairs({{id="loot",label="Loot"},{id="locations",label="Locations"},{id="breakdown",label="Breakdown"}}) do
        local id=tab.id; local b=Button(details,108,tab.label,function() f.detailsTab=id; self:ResetHistoryDetailsScroll(); self:RefreshHistoryDetailsWindow() end)
        f.tabButtons[id]=b; Anchor(b,details,16+(i-1)*116,224,108,26)
    end
    f.scopeText=Text(details,"",11,"textMuted","RIGHT")
    f.body=CreateFrame("Frame",nil,details); f.body:SetPoint("TOPLEFT",details,"TOPLEFT",16,-262); f.body:SetPoint("BOTTOMRIGHT",details,"BOTTOMRIGHT",-16,16)
    f.bodyHeaders={}
    for i=1,5 do f.bodyHeaders[i]=Text(f.body,"",12,"titleText") end
    f.detailsScroll,f.detailsContent=Scroll(f.body); f.detailsScroll:SetPoint("TOPLEFT",f.body,"TOPLEFT",0,-28); f.detailsScroll:SetPoint("BOTTOMRIGHT",f.body,"BOTTOMRIGHT",-16,0)
    f.detailsEmpty=Text(f.detailsContent,"No loot matches this view.",14,"textMuted"); f.detailsEmpty:SetPoint("TOPLEFT",f.detailsContent,"TOPLEFT",8,-12)
    Theme:CreateResizeButton(f,{maximize=true,minWidth=920,minHeight=610,maxWidth=1600,maxHeight=1000,onResizeStop=function() self:RefreshHistoryActiveView() end})
    if f.maximizeButton then f.maximizeButton:ClearAllPoints(); f.maximizeButton:SetPoint("RIGHT",f.backButton,"LEFT",-8,0) end
    f:SetScript("OnSizeChanged",function() if not f.isManualResizing then self:RefreshHistoryActiveView() end end)
    f:SetScript("OnShow",function() self:RefreshHistoryActiveView() end)
    self:ShowHistoryListView()
end

function GoldTracker:RefreshHistoryActiveView()
    local f=self.historyFrame; if not f or f.refreshing then return end
    if f.view=="details" then self:RefreshHistoryDetailsWindow() else self:RefreshHistoryWindow() end
end
function GoldTracker:ResetHistoryDetailsScroll()
    local f=self.historyFrame; if f and f.detailsScroll then f.detailsScroll:SetVerticalScroll(0) end
end
function GoldTracker:GetSelectedHistorySessionIDsInOrder()
    local ids={}; local f=self.historyFrame
    for _,s in ipairs(self:GetDisplaySortedSessionHistory()) do if f.selectedSessionIDs[s.id] then ids[#ids+1]=s.id end end
    return ids
end
function GoldTracker:ClearHistorySelection()
    if self.historyFrame then self.historyFrame.selectedSessionIDs={} end
    self:UpdateHistoryActionButtons()
end
function GoldTracker:SetHistoryCurrentPageSelection(selected)
    local f=self.historyFrame
    for _,id in ipairs(f.visibleSessionIDs or {}) do f.selectedSessionIDs[id]=selected and true or nil end
    self:RefreshHistoryWindow()
end
function GoldTracker:UpdateHistoryPageSelectAllState()
    local f=self.historyFrame; if not f or not f.selectPageCheckbox then return end
    local all=#(f.visibleSessionIDs or {})>0
    for _,id in ipairs(f.visibleSessionIDs or {}) do if not f.selectedSessionIDs[id] then all=false end end
    f.selectPageCheckbox:SetChecked(all)
end
function GoldTracker:UpdateHistoryActionButtons()
    local f=self.historyFrame; if not f then return end
    local count=0; local hasFarm=false
    for id in pairs(f.selectedSessionIDs or {}) do
        count=count+1; local s=self:GetHistorySessionByID(id); hasFarm=hasFarm or (s and (s.isFarm or s.recordType=="farm"))
    end
    if f.mergeButton then f.mergeButton:SetShown(count>1 and f.view=="list"); f.mergeButton:SetEnabled(not hasFarm) end
    if f.bulkDeleteButton then f.bulkDeleteButton:SetShown(count>0 and f.view=="list") end
    if f.clearSelectionButton then f.clearSelectionButton:SetShown(count>0 and f.view=="list") end
    if f.selectionText then f.selectionText:SetText(count>0 and string.format("%d selected across pages",count) or "Click a session to inspect its loot and locations.") end
    self:UpdateHistoryPageSelectAllState()
end
function GoldTracker:GetDisplaySortedSessionHistory()
    local f=self.historyFrame; local result={}
    local chars,locs={},{}; f.listInfo={}
    for _,s in ipairs(self:GetSessionHistory()) do
        local m=ModelFor(s); local title,subtitle=m:BuildRowTitleAndSubtitle(); local locations=m:BuildHistoryLocationOptions()
        local info={title=title,subtitle=subtitle,duration=m:GetDurationSeconds(),rateDuration=m:GetRateDuration(),locations=locations}
        info.search=string.lower(title.." "..subtitle)
        for _,option in ipairs(locations) do if option.key~=ALL then locs[option.key]=option.label; info.search=info.search.." "..string.lower(option.label) end end
        local character=s.savedBy or "Unknown character"; chars[character]=true
        f.listInfo[s.id]=info
        local locationMatch=f.historyLocationFilter==ALL
        for _,option in ipairs(locations) do if option.key==f.historyLocationFilter then locationMatch=true end end
        if dates:MatchesTimestamp(m:GetReferenceTimestamp(),f.historyDateFilterKey)
            and (f.characterFilter==ALL or f.characterFilter==character) and locationMatch
            and (f.query=="" or info.search:find(f.query,1,true)) then result[#result+1]=s end
    end
    f.characterOptions={{key=ALL,label="All characters"}}; f.locationOptions={{key=ALL,label="All locations"}}
    local names={}; for name in pairs(chars) do names[#names+1]=name end; table.sort(names)
    for _,name in ipairs(names) do f.characterOptions[#f.characterOptions+1]={key=name,label=name} end
    local options={}; for key,label in pairs(locs) do options[#options+1]={key=key,label=label} end
    table.sort(options,function(a,b) return a.label<b.label end); for _,option in ipairs(options) do f.locationOptions[#f.locationOptions+1]=option end
    local criteria=self:GetTableSortCriteria(f,"sortKey","sortAscending",SORT_KEYS)
    local function value(s,key)
        local info=f.listInfo[s.id]
        if key=="rate" then return info.rateDuration>0 and (s.totalValue or 0)*3600/info.rateDuration or 0 end
        if key=="duration" then return info.duration end
        if key=="date" then return s.startTime or s.savedAt or 0 end
        return service:GetHistorySortValue(s,key)
    end
    table.sort(result,function(a,b)
        if (a.pinned==true)~=(b.pinned==true) then return a.pinned==true end
        for _,c in ipairs(criteria) do
            local av,bv=value(a,c.key),value(b,c.key)
            if av~=bv then if c.ascending then return av<bv else return av>bv end end
        end
        return service:CompareHistorySessionsByRecency(a,b)
    end)
    return result
end
function GoldTracker:UpdateHistorySortHeaderState()
    local f=self.historyFrame; if not f then return end
    local criteria=self:GetTableSortCriteria(f,"sortKey","sortAscending",SORT_KEYS)
    local headers={duration={button=f.durationHeaderButton,label="Duration"},sessionTotal={button=f.totalHeaderButton,label="Estimated value"},
        sessionTotalRaw={button=f.totalRawHeaderButton,label="Cash + vendor"},highlights={button=f.summaryHeaderButton,label="Highlights"},rate={button=f.rateHeaderButton,label="Value / hour"}}
    for key,entry in pairs(headers) do
        local b=entry.button
        if b then
            local c,priority=self:GetTableSortCriterion(criteria,key); b.text:SetText(entry.label..(#criteria>1 and c and (" "..priority) or ""))
            self:AttachTableSortHeaderTooltip(b,entry.label)
            if c then Theme:SetTexture(b.sortIcon,c.ascending and "sortAscending" or "sortDescending"); b.sortIcon:Show() else b.sortIcon:Hide() end
        end
    end
end
function GoldTracker:ToggleHistorySort(key,mouseButton)
    local f=self.historyFrame; if not f or not SORT_KEYS[key] then return end
    self:ToggleTableSortCriterion(f,key,false,{validKeys=SORT_KEYS,mouseButton=mouseButton,allowClear=true})
    f.currentPage=1; self:RefreshHistoryWindow()
end
function GoldTracker:GetHistoryVisibleRowsPerPage()
    local scroll=self.historyFrame and self.historyFrame.scrollFrame
    local available=scroll and scroll:GetHeight() or 0
    return math.max(1,math.min(self:GetHistoryRowsPerPage(),math.floor(math.max(Constants.ROW_SPACING,available)/Constants.ROW_SPACING)))
end
function GoldTracker:GetHistoryPageCount(count) return math.max(1,math.ceil(count/self:GetHistoryVisibleRowsPerPage())) end
function GoldTracker:SetHistoryPage(page)
    local f=self.historyFrame; f.currentPage=math.max(1,math.min(page,f.totalPages or 1)); f.scrollFrame:SetVerticalScroll(0); self:RefreshHistoryWindow()
end
function GoldTracker:HandleHistoryPageMouseWheel(delta) self:SetHistoryPage(self.historyFrame.currentPage-(delta>0 and 1 or -1)) end
function GoldTracker:GetHistoryRow(index)
    local f=self.historyFrame; if f.rows[index] then return f.rows[index] end
    local r=Row(f.content); r.selectCheckbox=CreateFrame("CheckButton",nil,r,"UICheckButtonTemplate"); r.selectCheckbox:SetSize(22,22)
    r:EnableMouseWheel(true); r:SetScript("OnMouseWheel",function(_,delta) self:HandleHistoryPageMouseWheel(delta) end)
    r.pinButton=Button(r,28,"*",function() self:ToggleHistorySessionPinned(r.sessionID) end)
    Tip(r.pinButton,"Pin session","Pinned sessions stay above the rest of history.")
    r.menuButton=Button(r,28,"...",function(b) self:OpenHistoryRowMenu(r.sessionID,b) end)
    r.nameText=Text(r,"",14,"text"); r.subtitleText=Text(r,"",11,"textMuted")
    r.durationText=Text(r,"",13,"text"); r.totalText=Text(r,"",13,"text","RIGHT"); r.rateText=Text(r,"",13,"text","RIGHT")
    r.selectCheckbox:SetScript("OnClick",function(b) f.selectedSessionIDs[r.sessionID]=b:GetChecked() and true or nil; self:RefreshHistoryWindow() end)
    r:SetScript("OnClick",function() self:ShowHistoryDetailsView(r.sessionID) end)
    Tip(r,function() local info=f.listInfo[r.sessionID]; return info and info.title or "Session" end,function()
        local s=self:GetHistorySessionByID(r.sessionID); local m=ModelFor(s)
        return (f.listInfo[r.sessionID] and f.listInfo[r.sessionID].subtitle or "").."\n"..m:GetTimingLabel().."\nCash + vendor alternative: "..formatter:FormatSessionTotalRaw(s)
    end)
    f.rows[index]=r; return r
end
function GoldTracker:RefreshHistoryWindow()
    local f=self.historyFrame; if not f or f.view~="list" or f.refreshing then return end
    f.refreshing=true
    local history=self:GetDisplaySortedSessionHistory(); local size=self:GetHistoryVisibleRowsPerPage(); f.totalPages=self:GetHistoryPageCount(#history)
    f.currentPage=math.max(1,math.min(f.currentPage,f.totalPages)); local first=(f.currentPage-1)*size+1; local last=math.min(#history,first+size-1)
    local w=math.max(800,f.scrollFrame:GetWidth()-6); f.content:SetWidth(w)
    local rateX=w-178; local valueX=rateX-172; local durationX=valueX-126; local nameWidth=durationX-76
    Anchor(f.search,f.listContainer,22,18,math.max(180,f.listContainer:GetWidth()-596),24)
    f.searchHint:SetWidth(f.search:GetWidth()-10); f.searchHint:SetHeight(18)
    Anchor(f.historyDateFilterDropdown,f.listContainer,f.listContainer:GetWidth()-568,14)
    Anchor(f.characterDropdown,f.listContainer,f.listContainer:GetWidth()-406,14)
    Anchor(f.historyLocationDropdown,f.listContainer,f.listContainer:GetWidth()-228,14)
    f.searchHint:SetShown(f.query=="")
    Anchor(f.selectionText,f.listContainer,20,62,math.max(1,f.listContainer:GetWidth()-390),18)
    Anchor(f.clearSelectionButton,f.listContainer,f.listContainer:GetWidth()-332,56)
    Anchor(f.mergeButton,f.listContainer,f.listContainer:GetWidth()-252,56)
    Anchor(f.bulkDeleteButton,f.listContainer,f.listContainer:GetWidth()-134,56)
    Anchor(f.selectPageCheckbox,f.listContainer,12,90)
    Anchor(f.listHeaderButton,f.listContainer,72,92,nameWidth,20)
    Anchor(f.durationHeaderButton,f.listContainer,8+durationX,92,112,20)
    Anchor(f.totalHeaderButton,f.listContainer,8+valueX,92,156,20)
    Anchor(f.rateHeaderButton,f.listContainer,8+rateX,92,140,20)
    for _,d in ipairs({f.historyDateFilterDropdown,f.characterDropdown,f.historyLocationDropdown}) do d.refresh() end
    f.visibleSessionIDs={}; local count=0
    local valid={}; for _,s in ipairs(history) do valid[s.id]=true end
    for id in pairs(f.selectedSessionIDs) do if not valid[id] then f.selectedSessionIDs[id]=nil end end
    for i=first,last do
        local s=history[i]; count=count+1; local r=self:GetHistoryRow(count); r.sessionID=s.id; local info=f.listInfo[s.id]
        Anchor(r,f.content,0,(count-1)*Constants.ROW_SPACING,w,Constants.ROW_HEIGHT)
        r.bg:SetColorTexture(unpack(Color(f.selectedSessionIDs[s.id] and "rowSelected" or (count%2==0 and "rowEven" or "rowOdd"))))
        for _,t in ipairs({r.nameText,r.durationText,r.totalText,r.rateText}) do
            t:SetTextColor(unpack(Color(f.selectedSessionIDs[s.id] and "selectionTextSoft" or "text")))
        end
        r.subtitleText:SetTextColor(unpack(Color(f.selectedSessionIDs[s.id] and "selectionTextSoft" or "textMuted")))
        Anchor(r.selectCheckbox,r,4,15); r.selectCheckbox:SetChecked(f.selectedSessionIDs[s.id]==true)
        Anchor(r.pinButton,r,30,13,28,24); r.pinButton:SetAlpha(s.pinned and 1 or 0.45)
        Anchor(r.nameText,r,64,8,nameWidth,18); r.nameText:SetText(info.title)
        Anchor(r.subtitleText,r,64,30,w-106,14); r.subtitleText:SetText(info.subtitle)
        Anchor(r.durationText,r,durationX,10,112,18); r.durationText:SetText(ModelFor(s):FormatDurationMinutesLabel(info.duration))
        Anchor(r.totalText,r,valueX,10,156,18); r.totalText:SetText(Money(s.totalValue))
        Anchor(r.rateText,r,rateX,10,140,18); r.rateText:SetText(Rate(s.totalValue,info.rateDuration))
        Anchor(r.menuButton,r,w-32,13,28,24); r:Show(); f.visibleSessionIDs[#f.visibleSessionIDs+1]=s.id
    end
    for i=count+1,#f.rows do f.rows[i]:Hide() end
    f.content:SetHeight(math.max(1,count*Constants.ROW_SPACING)); f.emptyText:SetShown(count==0)
    f.prevPageButton:SetEnabled(f.currentPage>1); f.nextPageButton:SetEnabled(f.currentPage<f.totalPages)
    f.pageText:SetText(string.format("Page %d / %d   |   %d-%d of %d sessions",f.currentPage,f.totalPages,#history>0 and first or 0,last,#history))
    f.pageText:SetWidth(380); f.pageText:SetHeight(18)
    f.listRateHint:SetText(self:IsActiveTimeForGoldPerHourEnabled() and "Rates: estimated active loot time" or "Rates: recorded time / legacy elapsed span")
    f.listRateHint:SetWidth(320); f.listRateHint:SetHeight(18)
    self:UpdateHistoryActionButtons(); self:UpdateHistorySortHeaderState(); f.refreshing=false
end
function GoldTracker:ShowHistoryListView()
    local f=self.historyFrame; if not f then return end
    f.view="list"; f.selectedSessionID=nil; f.listContainer:Show(); f.detailsContainer:Hide(); f.backButton:Hide()
    if f.headerTitleText then f.headerTitleText:SetText("Session History") end
    self:RefreshHistoryWindow()
end
function GoldTracker:ShowHistoryDetailsView(id)
    local f=self.historyFrame; if not f then return end
    f.view="details"; f.selectedSessionID=id; f.detailsTab="loot"; f.detailsLocationFilterKey=ALL; f.detailsStyleFilterID="all"; f.detailsItemFilter="all"
    f.expandedItems={}; f.expandedLocations={}; self:ResetHistoryDetailsScroll()
    f.listContainer:Hide(); f.detailsContainer:Show(); f.backButton:Show()
    if f.headerTitleText then f.headerTitleText:SetText("Session Details") end
    self:RefreshHistoryDetailsWindow()
end

function GoldTracker:GetHistoryDetailRow(index)
    local f=self.historyFrame; if f.detailRows[index] then return f.detailRows[index] end
    local r=Row(f.detailsContent); r.cells={}
    for i=1,5 do r.cells[i]=Text(r,"",12,"text") end
    r.icon=r:CreateTexture(nil,"ARTWORK"); r.icon:SetSize(22,22)
    r.note=Text(r,"",11,"textMuted"); r.note:SetWordWrap(true)
    r.expand=Button(r,22,"+",function() if r.toggle then r.toggle() end end)
    r:SetScript("OnClick",function(_,button)
        if r.itemLink and GoldTracker.HandleFarmActionClick and GoldTracker:HandleFarmActionClick(r,button) then return end
        if r.itemLink and HandleModifiedItemClick and HandleModifiedItemClick(r.itemLink) then return end
        if r.activate then r.activate(button) end
    end)
    r:SetScript("OnEnter",function(self)
        GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
        if self.itemLink then GameTooltip:SetHyperlink(self.itemLink) else GameTooltip:SetText(self.tooltipTitle or "Location") end
        if self.tooltipBody then
            local c=Color("textSoft"); GameTooltip:AddLine(self.tooltipBody,c[1],c[2],c[3],true)
        end
        if self.itemLink and GoldTracker.AddFarmActionTooltip then GoldTracker:AddFarmActionTooltip(GameTooltip,self) end
        GameTooltip:Show()
    end)
    r:SetScript("OnLeave",function() GameTooltip:Hide() end)
    f.detailRows[index]=r; return r
end
function GoldTracker:RefreshHistoryDetailsWindow()
    local f=self.historyFrame; if not f or f.view~="details" or f.refreshing then return end
    local s=self:GetHistorySessionByID(f.selectedSessionID); if not s then self:ShowHistoryListView(); return end
    f.refreshing=true
    local model=ModelFor(s); local title=model:BuildRowTitleAndSubtitle(); local details=f.detailsContainer
    local base=self:GetHistoryDetailsFontSize(); local w=details:GetWidth(); local bodyWidth=math.max(740,f.detailsScroll:GetWidth()-6)
    local options=model:BuildHistoryLocationOptions(); f.detailsLocationOptions=options
    local selectedLabel="All locations"; local found=f.detailsLocationFilterKey==ALL
    for _,o in ipairs(options) do if o.key==f.detailsLocationFilterKey then selectedLabel=o.label; found=true end end
    if not found then f.detailsLocationFilterKey=ALL end
    local summary=service:BuildHistoryDetailsSummary(s,f.detailsLocationFilterKey,f.detailsStyleFilterID)
    Anchor(f.sessionNameText,details,16,16,w-170,28); FitText(f.sessionNameText,title,base+4,14)
    local pricing=#(s.valueSourceLabels or {})>1 and ("Mixed ("..#s.valueSourceLabels.." price sources)") or (s.valueSourceLabel or "Unknown")
    f.metadataText:SetText(string.format("%s  |  %s - %s\nPricing: %s",s.savedBy or "Unknown character",Date(s.startTime),Date(s.stopTime or s.savedAt),pricing))
    Anchor(f.metadataText,details,16,48,w-32,40)
    f.metadataText:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",math.max(11,base-2),"")
    Anchor(f.resumeSessionButton,details,w-150,16,96,24); Anchor(f.detailsMenu,details,w-46,16,30,24)
    local canResume=self:IsResumeHistorySessionEnabled() and not s.isFarm and s.recordType~="farm"
    local alreadyActive=self.session and self.session.active and self.session.historySessionID==s.id
    f.resumeSessionButton:SetEnabled(canResume and not alreadyActive); f.resumeSessionButton:SetText(alreadyActive and "Recording" or "Resume")
    local cardData={
        {"Estimated value",Money(summary.totalValue),"Cash + auction estimates"},
        {"Cash + vendor value",Money(summary.rawGold+summary.itemsRawGold),"Alternative valuation"},
        {"Duration",self:FormatDuration(summary.duration),summary.timingLabel},
        {"Value / hour",Rate(summary.totalValue,summary.rateDuration),summary.rateBasis},
    }
    local cardWidth=(w-62)/4
    for i,card in ipairs(f.cards) do
        Anchor(card,details,16+(i-1)*(cardWidth+10),94,cardWidth,80)
        for _,label in ipairs({card.label,card.value,card.note}) do label:SetWidth(cardWidth-24) end
        FitText(card.label,cardData[i][1],math.max(11,base-3),11)
        FitText(card.value,cardData[i][2],base+2,12)
        FitText(card.note,cardData[i][3],math.max(11,base-3),11)
        Tip(card,cardData[i][1],cardData[i][2].."\n"..cardData[i][3])
    end
    Anchor(f.locationFilterDropdown,details,0,184); Anchor(f.styleFilterDropdown,details,266,184); Anchor(f.itemFilterDropdown,details,454,184)
    for _,d in ipairs({f.locationFilterDropdown,f.styleFilterDropdown,f.itemFilterDropdown}) do d.refresh() end
    f.itemFilterDropdown:SetShown(f.detailsTab=="loot")
    Anchor(f.scopeText,details,378,232,w-394,16); f.scopeText:SetText("Scope: "..selectedLabel)
    for id,b in pairs(f.tabButtons) do if b.SetSelected then b:SetSelected(id==f.detailsTab) end end
    local columns
    if f.detailsTab=="loot" then columns={{"Item",0,bodyWidth-410},{"Qty",bodyWidth-402,54},{"Value",bodyWidth-340,154},{"Source",bodyWidth-174,170}}
    elseif f.detailsTab=="locations" then columns={{"Location",0,bodyWidth-428},{"Value",bodyWidth-416,156},{"Items",bodyWidth-248,60},{"Visits",bodyWidth-176,60},{"Time",bodyWidth-104,100}}
    else columns={{"Breakdown",0,bodyWidth-230},{"Value / quantity",bodyWidth-218,210}} end
    for i,h in ipairs(f.bodyHeaders) do
        local c=columns[i]; h:SetShown(c~=nil); if c then Anchor(h,f.body,c[2],3,c[3],20); h:SetText(c[1]) end
    end
    f.detailsContent:SetWidth(bodyWidth)
    local rendered,y=0,0
    local function draw(cells,note,expanded)
        rendered=rendered+1; local r=self:GetHistoryDetailRow(rendered)
        r.itemLink=nil; r.activate=nil; r.toggle=nil; r.tooltipBody=nil; r.icon:Hide(); r.expand:Hide(); r.note:Hide()
        local rowHeight=math.max(34,base+18)
        if note then
            r.note:SetText(note); Anchor(r.note,r,34,rowHeight,bodyWidth-46)
            if expanded then rowHeight=rowHeight+math.max(18,r.note:GetStringHeight())+8; r.note:Show() end
        end
        Anchor(r,f.detailsContent,0,y,bodyWidth,rowHeight)
        r.bg:SetColorTexture(unpack(Color(rendered%2==0 and "rowEven" or "rowOdd")))
        for i,t in ipairs(r.cells) do
            t:SetShown(cells[i]~=nil)
            if cells[i]~=nil and columns[i] then
                Anchor(t,r,columns[i][2]+(i==1 and 32 or 0),8,columns[i][3]-(i==1 and 34 or 4),base+8)
                t:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF",base,""); t:SetText(cells[i]); t:SetJustifyH((i==3 and f.detailsTab=="loot") and "RIGHT" or "LEFT")
                if (f.detailsTab=="loot" and (i==2 or i==3)) or (f.detailsTab=="locations" and i>1) or (f.detailsTab=="breakdown" and i==2) then
                    FitText(t,cells[i],base,10)
                end
            end
        end
        r:Show(); y=y+rowHeight+3; return r
    end
    if f.detailsTab=="loot" then
        local items=service:BuildVisibleHistoryItems(s,f.detailsLocationFilterKey,f.detailsStyleFilterID,f.detailsItemFilter)
        for _,item in ipairs(items) do
            local key=(item.itemLink or "unknown")..":"..(item.valueSourceLabel or "")
            local note=table.concat(item.sources or {},"\n")
            local kind=item.isSoulbound and "Bound" or (item.ahTracked and (item.valueSourceLabel or "Auction estimate") or "Vendor value")
            note=kind..(note~="" and ("\n"..note) or "")
            local value=item.ahTracked and item.totalValue or (item.vendorTotalValue or item.totalValue)
            local r=draw({item.itemLink or "Unknown item",tostring(item.quantity or 0),Money(value),item.lootSourceText or kind},note,f.expandedItems[key])
            r.itemLink=item.itemLink; r.tooltipBody=note.."\nClick to expand sources. Shift-click links the item."
            local icon=C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(item.itemLink)
            r.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark"); Anchor(r.icon,r,4,6,22,22); r.icon:Show()
            r.activate=function() f.expandedItems[key]=not f.expandedItems[key]; self:RefreshHistoryDetailsWindow() end
        end
    elseif f.detailsTab=="locations" then
        for _,location in ipairs(model:BuildLocationDetailsRowsForSelection(f.detailsLocationFilterKey,s,f.detailsStyleFilterID)) do
            local lines={location.path or location.location}
            if location.visits then
                for _,visit in ipairs(location.intervals) do lines[#lines+1]=Date(visit.startTime).." - "..Date(visit.stopTime) end
            else lines[#lines+1]="Visits were not recorded. Loot activity: "..location.timeFrame end
            local note=table.concat(lines,"\n"); local key=location.key
            local r=draw({location.location,Money(location.totalValue),tostring(location.quantity),location.visits and tostring(location.visits) or "--",location.duration},note,f.expandedLocations[key])
            r.tooltipTitle=location.location; r.tooltipBody=note.."\nClick the row to view loot from this location."
            r.expand:Show(); Anchor(r.expand,r,4,5,22,24); r.expand:SetText(f.expandedLocations[key] and "-" or "+")
            r.toggle=function() f.expandedLocations[key]=not f.expandedLocations[key]; self:RefreshHistoryDetailsWindow() end
            r.activate=function() f.detailsLocationFilterKey=key; f.detailsTab="loot"; self:ResetHistoryDetailsScroll(); self:RefreshHistoryDetailsWindow() end
        end
    else
        local counts={all=0,auction=0,vendor=0,bound=0,reagent=0}
        for _,item in ipairs(s.itemLoots or {}) do
            if model:EntryMatchesLocation(item,f.detailsLocationFilterKey,s) and (f.detailsStyleFilterID=="all" or self:LootItemMatchesSessionStyle(item,f.detailsStyleFilterID)) then
                local qty=tonumber(item.quantity) or 0; counts.all=counts.all+qty
                local kind=item.isSoulbound and "bound" or (item.ahTracked and "auction" or "vendor"); counts[kind]=counts[kind]+qty
                if item.isCraftingReagent then counts.reagent=counts.reagent+qty end
            end
        end
        local rows={{"Estimated value",Money(summary.totalValue)},{"Looted cash",Money(summary.rawGold)},{"Auction estimate",Money(summary.itemsValue)},
            {"Vendor value of all loot",Money(summary.itemsRawGold)},{"Cash + vendor alternative",Money(summary.rawGold+summary.itemsRawGold)},
            {"Total item quantity",counts.all},{"Auction-valued items",counts.auction},{"Vendor-only items",counts.vendor},{"Bound items",counts.bound},{"Crafting reagents (overlaps categories)",counts.reagent}}
        for _,entry in ipairs(rows) do local r=draw({entry[1],tostring(entry[2])}); Anchor(r.cells[1],r,8,8,columns[1][3]-12,base+8) end
        local r=draw({"Valuation notes",""},"Estimated value = looted cash + auction-valued loot. Vendor value is an alternative estimate, not an additional amount. Bound items are counted separately. Crafting reagents overlap the other item categories.",true)
        Anchor(r.cells[1],r,8,8,columns[1][3]-12,base+8)
    end
    for i=rendered+1,#f.detailRows do f.detailRows[i]:Hide() end
    f.detailsContent:SetHeight(math.max(1,y)); f.detailsEmpty:SetShown(rendered==0)
    if f.detailsScroll.UpdateScrollChildRect then f.detailsScroll:UpdateScrollChildRect() end
    f.detailsScroll:SetVerticalScroll(math.min(f.detailsScroll:GetVerticalScroll(),f.detailsScroll:GetVerticalScrollRange()))
    f.refreshing=false
end
function GoldTracker:ApplyHistoryDetailsFontSize() self:RefreshHistoryActiveView() end
function GoldTracker:OpenHistoryWindow()
    self:CreateHistoryWindow(); self:ShowHistoryListView(); self.historyFrame:Show(); Theme:BringToFront(self.historyFrame)
end
function GoldTracker:OpenHistorySessionDetails(id) self:CreateHistoryWindow(); self:ShowHistoryDetailsView(id); self.historyFrame:Show(); Theme:BringToFront(self.historyFrame) end
function GoldTracker:OpenHistoryLootBreakdownWindow(id)
    self:CreateHistoryWindow(); local f=self.historyFrame
    if f.selectedSessionID~=id or f.view~="details" then self:ShowHistoryDetailsView(id) end
    f.detailsTab="breakdown"; self:ResetHistoryDetailsScroll(); f:Show(); self:RefreshHistoryDetailsWindow()
end




function GoldTracker:BuildHistorySessionCSV(sessionID)
    local frame = self.historyFrame
    local session = self:GetHistorySessionByID(sessionID)
    if not session then
        return nil
    end

    local selectedLocationKey = DETAILS_LOCATION_FILTER_ALL
    local selectedStyleID = self.SESSION_STYLE_ALL_ID or "all"
    if frame and frame.view == "details" and frame.selectedSessionID == sessionID then
        selectedLocationKey = frame.detailsLocationFilterKey or DETAILS_LOCATION_FILTER_ALL
        selectedStyleID = self:NormalizeSessionStyleFilter(frame.detailsStyleFilterID)
    end

    local summary = BuildHistoryDetailsSummary(session, selectedLocationKey, selectedStyleID)
    local items = BuildVisibleHistoryItems(session, selectedLocationKey, selectedStyleID)
    local rows = {
        "section,key,value",
        string.format("session,id,%s", EscapeCSVValue(session.id)),
        string.format("session,name,%s", EscapeCSVValue(ModelFor(session):BuildRowTitleAndSubtitle())),
        string.format("session,location_scope,%s", EscapeCSVValue(selectedLocationKey)),
        string.format("session,style_scope,%s", EscapeCSVValue(selectedStyleID)),
        string.format("session,item_view,%s", EscapeCSVValue(frame and frame.view == "details" and frame.detailsItemFilter or "all")),
        string.format("session,timing_basis,%s", EscapeCSVValue(summary.timingLabel)),
        string.format("session,rate_basis,%s", EscapeCSVValue(summary.rateBasis)),
        string.format("session,rate_duration_seconds,%s", EscapeCSVValue(summary.rateDuration)),
        string.format("session,saved_by,%s", EscapeCSVValue(session.savedBy or "Unknown")),
        string.format("session,start_time,%s", EscapeCSVValue(date("%Y-%m-%d %H:%M:%S", tonumber(summary.startTime) or time()))),
        string.format("session,stop_time,%s", EscapeCSVValue(date("%Y-%m-%d %H:%M:%S", tonumber(summary.stopTime) or time()))),
        string.format("session,duration_seconds,%s", EscapeCSVValue(math.floor(tonumber(summary.duration) or 0))),
        string.format("session,raw_gold_copper,%s", EscapeCSVValue(math.floor(tonumber(summary.rawGold) or 0))),
        string.format("session,vendor_items_copper,%s", EscapeCSVValue(math.floor(tonumber(summary.itemsRawGold) or 0))),
        string.format("session,ah_value_copper,%s", EscapeCSVValue(math.floor(tonumber(summary.itemsValue) or 0))),
        string.format("session,total_value_copper,%s", EscapeCSVValue(math.floor(tonumber(summary.totalValue) or 0))),
        "",
        "items,item_link,quantity,total_value_copper,value_source,loot_source,vendor_value_copper,valuation_kind",
    }

    for _, item in ipairs(items or {}) do
        rows[#rows + 1] = string.format(
            "items,%s,%s,%s,%s,%s,%s,%s",
            EscapeCSVValue(item.itemLink or ""),
            EscapeCSVValue(math.floor(tonumber(item.quantity) or 0)),
            EscapeCSVValue(math.floor(tonumber(item.totalValue) or 0)),
            EscapeCSVValue(item.valueSourceLabel or ""),
            EscapeCSVValue(table.concat(item.sources or { item.lootSourceText or "" }, "; ")),
            EscapeCSVValue(item.vendorTotalValue or 0),
            EscapeCSVValue(item.isSoulbound and "bound" or (item.ahTracked and "auction" or "vendor"))
        )
    end

    return table.concat(rows, "\n")
end

function GoldTracker:CreateHistoryExportWindow()
    if self.historyExportFrame then
        return
    end

    local frame = CreateFrame("Frame", "GoldTrackerHistoryExportFrame", UIParent)
    frame:SetSize(780, 520)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnMouseDown", function(self)
        BringHistoryPopupToFront(self)
    end)
    frame:SetScript("OnDragStart", function(self)
        BringHistoryPopupToFront(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    local chrome = CreateHistoryPopupChrome(frame, "History CSV Export")

    local hintPanel = CreateHistoryPanel(frame)
    hintPanel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
    hintPanel:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -12, -54)
    hintPanel:SetHeight(42)
    frame.exportHintPanel = hintPanel

    local hint = hintPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hint:SetPoint("LEFT", hintPanel, "LEFT", 14, 0)
    hint:SetPoint("RIGHT", hintPanel, "RIGHT", -14, 0)
    hint:SetJustifyH("LEFT")
    hint:SetText("Select all (Ctrl+A) and copy (Ctrl+C).")
    hint:SetTextColor(unpack(Color("textSoft")))
    frame.exportHintText = hint

    local bodyPanel = CreateHistoryPanel(frame)
    bodyPanel:SetPoint("TOPLEFT", hintPanel, "BOTTOMLEFT", 0, -10)
    bodyPanel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 12)
    frame.exportBodyPanel = bodyPanel

    local scroll = CreateFrame("ScrollFrame", nil, bodyPanel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", bodyPanel, "TOPLEFT", 14, -12)
    scroll:SetPoint("BOTTOMRIGHT", bodyPanel, "BOTTOMRIGHT", -26, 12)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local step = 40
        local nextScroll = self:GetVerticalScroll() - (delta * step)
        local maxScroll = self:GetVerticalScrollRange()
        if nextScroll < 0 then
            nextScroll = 0
        elseif nextScroll > maxScroll then
            nextScroll = maxScroll
        end
        self:SetVerticalScroll(nextScroll)
    end)
    frame.exportScrollFrame = scroll

    local scrollContent = CreateFrame("Frame", nil, scroll)
    scrollContent:SetSize(1, 1)
    scroll:SetScrollChild(scrollContent)
    frame.exportScrollContent = scrollContent

    local editBox = CreateFrame("EditBox", nil, scrollContent)
    editBox:SetPoint("TOPLEFT", scrollContent, "TOPLEFT", 0, 0)
    editBox:SetPoint("TOPRIGHT", scrollContent, "TOPRIGHT", 0, 0)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(GameFontHighlightSmall)
    if editBox.SetTextColor then
        editBox:SetTextColor(unpack(Color("text")))
    end
    editBox:SetScript("OnEscapePressed", function()
        frame:Hide()
    end)

    local function RefreshExportEditBoxSize()
        local width = math.max(1, math.floor((scroll:GetWidth() or 1) - 4))
        scrollContent:SetWidth(width)
        editBox:SetWidth(width)
        local textHeight = math.floor((editBox:GetStringHeight() or 0) + 24)
        local height = math.max(math.floor(scroll:GetHeight() or 1), textHeight)
        scrollContent:SetHeight(height)
        editBox:SetHeight(height)
    end

    scroll:SetScript("OnSizeChanged", RefreshExportEditBoxSize)
    editBox:SetScript("OnTextChanged", RefreshExportEditBoxSize)

    frame.exportEditBox = editBox
    frame.RefreshExportEditBoxSize = RefreshExportEditBoxSize
    RegisterHistoryPopupFrame("GoldTrackerHistoryExportFrame")
    self.historyExportFrame = frame
end

function GoldTracker:OpenHistorySessionExport(sessionID)
    local csvText = self:BuildHistorySessionCSV(sessionID)
    if not csvText then
        return
    end

    self:CreateHistoryExportWindow()
    local frame = self.historyExportFrame
    frame.exportEditBox:SetText(csvText)
    frame:Show()
    BringHistoryPopupToFront(frame)
    if frame.RefreshExportEditBoxSize then
        frame:RefreshExportEditBoxSize()
    end
    frame.exportEditBox:SetFocus()
    frame.exportEditBox:HighlightText()
end
