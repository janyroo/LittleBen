
local AddOnName, JAN = ...
local RLS= JAN.Demo_List
local L, B, C, DB= JAN.L, JAN.Base, JAN.Config, JAN.DataBase--L翻译，B基础，C配置，DB数据库,RLS一句话攻略

local EPC = JAN:NewModule("demo", "AceHook-3.0", "AceEvent-3.0")
local LOP = LibStub("LibObjectiveProgress-1.0")

DB.defaults.profile.modules.demo = {
	enable = false,
  enableid = false,
	    custom = {
		enable = true,
		spellMsg = "格式   名称：内容。",
		Demo_List =  {
			["阿塔达萨"] = {
				{name = "沃卡尔", raiders = "3个图腾必须一起死，图腾死了再打Boss。"},
				{name = "莱赞", raiders = "卡视角躲恐惧，被点名跑河道，别踩土堆。"},
				{name = "女祭司阿伦扎", raiders = "秒ADD，Boss吸血前，血水一人一滩。"},
				{name = "亚兹玛", raiders = "除坦克其他人出分身前集中。"},
			},
			["地渊孢林"] = {
				{name = "长者莉娅克萨", raiders = "打断、Boss冲锋位置远离。"},
				{name = "被感染的岩喉", raiders = "8秒内踩掉小虫子，躲喷吐和冲锋。"},
				{name = "孢子召唤者赞查", raiders = "利用顺劈和点名清蘑菇，躲球。"},
				{name = "不羁畸变怪", raiders = "集体移动，利用清理光圈消debuff，全力输出Boss，输出越高能量越快小怪出得越快Boss死得越快。"},
			},
			},
		
	},
}


C.ModulesOrder.demo = 21
C.ModulesOption.demo = {
    name = L["Notepad"],
	type = "group",
	childGroups = "tree",
    args = {
		general = {
			order = 1,
			name = L["General"],
			type = "group",
			inline = true,
			args = {
				enable = {
          order = 1,
          name = L["Enable"],
          desc = L["Enables / disables the module"],
          type = "toggle",
          width = "full",
          set = function(info,value)
            EPC.db.enable = value
            if EPC.db.enable then EPC:Enable() else EPC:Disable() end
          end,
          get = function(info) return EPC.db.enable end
        },
        enableid = {
          order = 2,
          name = "显示ID",
          desc = "是否显示ID",
          type = "toggle",
          width = "full",
          set = function(info,value)
            EPC.db.enableid = value
            if EPC.db.enableid then EPC:Enable() else EPC:Disable() end
          end,
          get = function(info) return EPC.db.enableid end
        },
				default = {
					order = 3,
					name = L["Defaults"],
					type = "execute",
					func = function()
						EPC.db.custom.spellMsg = "名称--内容"
					end
				},
				spell = {
					order = 4,
					type = "input",
					name = "添加笔记",
					desc = function() return "格式   名称：内容。" end,
					width = 'full',
					get = function(info) return EPC.db.custom.spellMsg end,
					set = function(info, value) 
		
					EPC.db.custom.Demo_List[split(value,"--")[1]]=split(value,"--")[2];
					print("成功保存"..EPC.db.custom.Demo_List[split(value,"--")[1]])
					EPC:SetNotificationText() 
					end,
				},
			}
		},

    }
}

----
function split( str,reps )
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end


local hooksecurefunc, select, UnitBuff, UnitDebuff, UnitAura, UnitGUID,
      GetGlyphSocketInfo, tonumber, strfind
    = hooksecurefunc, select, UnitBuff, UnitDebuff, UnitAura, UnitGUID,
      GetGlyphSocketInfo, tonumber, strfind

local kinds = {
  spell = L["SpellID"],
  item = L["ItemID"],
  unit = L["NPCID"],
  quest = L["QuestID"],
  talent = L["TalentID"],
  achievement = L["AchievementID"],
  criteria = L["CriteriaID"],
  ability = L["AbilityID"],
  currency = L["CurrencyID"],
  artifactpower = L["ArtifactPowerID"],
  enchant = L["EnchantID"],
  bonus = L["BonusID"],
  gem = L["GemID"],
  mount = L["MountID"],
  companion = L["CompanionID"],
  macro = L["MacroID"],
  equipmentset = L["EquipmentSetID"],
  visual = L["VisualID"],
  source = L["SourceID"],
}

local function contains(table, element)
  for _, value in pairs(table) do
    if value == element then return true end
  end
  return false
end

local function addLine(tooltip, id, kind,guin)
	if not EPC.db.enable then return end--锁
  if not id or id == "" then return end
  if type(id) == "table" and #id == 1 then id = id[1] end

  -- 检查我们是否已经添加到这个工具提示中。发生在天赋框架上
  local frame, text
  for i = 1,15 do
    frame = _G[tooltip:GetName() .. "TextLeft" .. i]
    if frame then text = frame:GetText() end
    if text and string.find(text, kind .. ":") then return end
  end

  local left, right
  if type(id) == "table" then
    left = NORMAL_FONT_COLOR_CODE .. kind .. "s:" .. FONT_COLOR_CODE_CLOSE
    right = HIGHLIGHT_FONT_COLOR_CODE .. table.concat(id, ", ") .. FONT_COLOR_CODE_CLOSE
  else
    left = NORMAL_FONT_COLOR_CODE .. kind .. ":" .. FONT_COLOR_CODE_CLOSE
    right = HIGHLIGHT_FONT_COLOR_CODE .. id .. FONT_COLOR_CODE_CLOSE
  end
  if EPC.db.enableid and kind~="ben" then 
    tooltip:AddDoubleLine(left, right)
  end--锁

  if EPC.db.custom.Demo_List[guin] then
  	tooltip:AddDoubleLine(EPC.db.custom.Demo_List[guin]) 
  elseif RLS[guin] then 
    tooltip:AddDoubleLine(RLS[guin])
  end
  tooltip:Show()
end

local function addLineByKind(self, id, kind)
  if not kind or not id then return end

  if kind == "spell" or kind == "enchant" or kind == "trade" then
    addLine(self, id, kinds.spell)
  elseif kind == "talent" then
    addLine(self, id, kinds.talent)
  elseif kind == "quest" then
    addLine(self, id, kinds.quest)
  elseif kind == "achievement" then
    addLine(self, id, kinds.achievement)
  elseif kind == "item" then
    addLine(self, id, kinds.item)
  elseif kind == "currency" then
    addLine(self, id, kinds.currency)
  elseif kind == "summonmount" then
    addLine(self, id, kinds.mount)
  elseif kind == "companion" then
    addLine(self, id, kinds.companion)
  elseif kind == "macro" then
    addLine(self, id, kinds.macro)
  elseif kind == "equipmentset" then
    addLine(self, id, kinds.equipmentset)
  elseif kind == "visual" then
    addLine(self, id, kinds.visual)
  end

  local spellname=GetSpellInfo(id)
  addLine(self, id,"ben",spellname)
end

-- All kinds种类
local function onSetHyperlink(self, link)--关于设置超链接
  local kind, id = string.match(link,"^(%a+):(%d+)")

  addLineByKind(self, kind, id)
  
end

hooksecurefunc(GameTooltip, "SetAction", function(self, slot)--动作栏
  local kind, id = GetActionInfo(slot)
 
  addLineByKind(self, id, kind)
end)

hooksecurefunc(ItemRefTooltip, "SetHyperlink", onSetHyperlink)
hooksecurefunc(GameTooltip, "SetHyperlink", onSetHyperlink)

-- Spells
hooksecurefunc(GameTooltip, "SetUnitBuff", function(self, ...)
  local id = select(10, UnitBuff(...))
  addLine(self, id, kinds.spell)
end)

hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self, ...)
  local id = select(10, UnitDebuff(...))
  addLine(self, id, kinds.spell)
end)

hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
  local id = select(10, UnitAura(...))
  addLine(self, id, kinds.spell)
end)

hooksecurefunc(GameTooltip, "SetSpellByID", function(self, id)
  addLineByKind(self, id, kinds.spell)
end)

hooksecurefunc("SetItemRef", function(link, ...)
  local id = tonumber(link:match("spell:(%d+)"))
  addLine(ItemRefTooltip, id, kinds.spell)
end)

GameTooltip:HookScript("OnTooltipSetSpell", function(self)
  local id = select(3, self:GetSpell())
  addLine(self, id, kinds.spell)
end)

hooksecurefunc("SpellButton_OnEnter", function(self)
  local slot = SpellBook_GetSpellBookSlot(self)
  local spellID = select(2, GetSpellBookItemInfo(slot, SpellBookFrame.bookType))
  addLine(GameTooltip, spellID, kinds.spell)
end)

hooksecurefunc(GameTooltip, "SetRecipeResultItem", function(self, id)
  addLine(self, id, kinds.spell)
end)

hooksecurefunc(GameTooltip, "SetRecipeRankInfo", function(self, id)
  addLine(self, id, kinds.spell)
end)

-- Artifact Powers
hooksecurefunc(GameTooltip, "SetArtifactPowerByID", function(self, powerID)
  local powerInfo = C_ArtifactUI.GetPowerInfo(powerID)
  addLine(self, powerID, kinds.artifactpower)
  addLine(self, powerInfo.spellID, kinds.spell)
end)

-- Talents人才
hooksecurefunc(GameTooltip, "SetTalent", function(self, id)
  addLine(self, id, kinds.talent)
end)
hooksecurefunc(GameTooltip, "SetPvpTalent", function(self, id)
  addLine(self, id, kinds.talent)
end)

-- NPCs
GameTooltip:HookScript("OnTooltipSetUnit", function(self)
  if C_PetBattles.IsInBattle() then return end
  local unit = select(2, self:GetUnit())

  if unit then
    local guid = UnitGUID(unit) or ""
    local guin = UnitName(unit) or ""
    local id = tonumber(guid:match("-(%d+)-%x+$"), 10)
    if id then 
      addLine(GameTooltip, id, kinds.unit,guin)
    end
  end
  
end)

-- Items项目
hooksecurefunc(GameTooltip, "SetToyByItemID", function(self, id)

  addLine(self, id, kinds.item)
end)

hooksecurefunc(GameTooltip, "SetRecipeReagentItem", function(self, id)

  addLine(self, id, kinds.item)
end)

local function attachItemTooltip(self)

  local link = select(2, self:GetItem())
  if not link then return end

  local itemString = string.match(link, "item:([%-?%d:]+)")
  if not itemString then return end

  local enchantid = ""
  local bonusid = ""
  local gemid = ""
  local bonuses = {}
  local itemSplit = {}

  for v in string.gmatch(itemString, "(%d*:?)") do
    if v == ":" then
      itemSplit[#itemSplit + 1] = 0
    else
      itemSplit[#itemSplit + 1] = string.gsub(v, ":", "")
    end
  end

  for index = 1, tonumber(itemSplit[13]) do
    bonuses[#bonuses + 1] = itemSplit[13 + index]
  end

  local gems = {}
  for i=1, 4 do
    local _,gemLink = GetItemGem(link, i)
    if gemLink then
      local gemDetail = string.match(gemLink, "item[%-?%d:]+")
      gems[#gems + 1] = string.match(gemDetail, "item:(%d+):")
    elseif flags == 256 then
      gems[#gems + 1] = "0"
    end
  end

  local id = string.match(link, "item:(%d*)")
  if (id == "" or id == "0") and TradeSkillFrame ~= nil and TradeSkillFrame:IsVisible() and GetMouseFocus().reagentIndex then
    local selectedRecipe = TradeSkillFrame.RecipeList:GetSelectedRecipeID()
    for i = 1, 8 do
      if GetMouseFocus().reagentIndex == i then
        id = C_TradeSkillUI.GetRecipeReagentItemLink(selectedRecipe, i):match("item:(%d*)") or nil
        break
      end
    end
  end

  if id then
    addLine(self, id, kinds.item)
    if itemSplit[2] ~= 0 then
      enchantid = itemSplit[2]
      addLine(self, enchantid, kinds.enchant)
    end
    if #bonuses ~= 0 then addLine(self, bonuses, kinds.bonus) end
    if #gems ~= 0 then addLine(self, gems, kinds.gem) end
  end
end

-------------------------------------------------
local f = CreateFrame("frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, _, what)
  if what == "Blizzard_AchievementUI" then
    for i,button in ipairs(AchievementFrameAchievementsContainer.buttons) do
      button:HookScript("OnEnter", function()
        GameTooltip:SetOwner(button, "ANCHOR_NONE")
        GameTooltip:SetPoint("TOPLEFT", button, "TOPRIGHT", 0, 0)
        addLine(GameTooltip, button.id, kinds.achievement)
        GameTooltip:Show()
      end)
      button:HookScript("OnLeave", function()
        GameTooltip:Hide()
      end)

      local hooked = {}
      hooksecurefunc("AchievementButton_GetCriteria", function(index, renderOffScreen)
        local frame = _G["AchievementFrameCriteria" .. (renderOffScreen and "OffScreen" or "") .. index]
        if frame and not hooked[frame] then
          frame:HookScript("OnEnter", function(self)
            local button = self:GetParent() and self:GetParent():GetParent()
            if not button or not button.id then return end
            local criteriaid = select(10, GetAchievementCriteriaInfo(button.id, index))
            if criteriaid then
              GameTooltip:SetOwner(button:GetParent(), "ANCHOR_NONE")
              GameTooltip:SetPoint("TOPLEFT", button, "TOPRIGHT", 0, 0)
              addLine(GameTooltip, button.id, kinds.achievement)
              addLine(GameTooltip, criteriaid, kinds.criteria)
              GameTooltip:Show()
            end
          end)
          frame:HookScript("OnLeave", function()
            GameTooltip:Hide()
          end)
          hooked[frame] = true
        end
      end)
    end
  elseif what == "Blizzard_Collections" then
    hooksecurefunc("WardrobeCollectionFrame_SetAppearanceTooltip", function(self, sources)
      local visualIDs = {}
      local sourceIDs = {}
      local itemIDs = {}

      for i = 1, #sources do
        if sources[i].visualID and not contains(visualIDs, sources[i].visualID) then table.insert(visualIDs, sources[i].visualID) end
        if sources[i].sourceID and not contains(visualIDs, sources[i].sourceID) then table.insert(sourceIDs, sources[i].sourceID) end
        if sources[i].itemID and not contains(visualIDs, sources[i].itemID) then table.insert(itemIDs, sources[i].itemID) end
      end

      if #visualIDs ~= 0 then addLine(GameTooltip, visualIDs, kinds.visual) end
      if #sourceIDs ~= 0 then addLine(GameTooltip, sourceIDs, kinds.source) end
      if #itemIDs ~= 0 then addLine(GameTooltip, itemIDs, kinds.item) end
    end)
  end
end)

-- Pet battle buttons宠物战斗按钮
hooksecurefunc("PetBattleAbilityButton_OnEnter", function(self)
  local petIndex = C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY)
  if self:GetEffectiveAlpha() > 0 then
    local id = select(1, C_PetBattles.GetAbilityInfo(LE_BATTLE_PET_ALLY, petIndex, self:GetID()))
    if id then
      local oldText = PetBattlePrimaryAbilityTooltip.Description:GetText(id)
      PetBattlePrimaryAbilityTooltip.Description:SetText(oldText .. "\r\r" .. kinds.ability .. "|cffffffff " .. id .. "|r")
    end
  end
end)

-- Pet battle auras宠物战斗氛围
hooksecurefunc("PetBattleAura_OnEnter", function(self)
  local parent = self:GetParent()
  local id = select(1, C_PetBattles.GetAuraInfo(parent.petOwner, parent.petIndex, self.auraIndex))
  if id then
    local oldText = PetBattlePrimaryAbilityTooltip.Description:GetText(id)
    PetBattlePrimaryAbilityTooltip.Description:SetText(oldText .. "\r\r" .. kinds.ability .. "|cffffffff " .. id .. "|r")
  end
end)

-- Currencies
hooksecurefunc(GameTooltip, "SetCurrencyToken", function(self, index)
  local id = tonumber(string.match(GetCurrencyListLink(index),"currency:(%d+)"))
  addLine(self, id, kinds.currency)
end)

hooksecurefunc(GameTooltip, "SetCurrencyByID", function(self, id)
   addLine(self, id, kinds.currency)
end)

hooksecurefunc(GameTooltip, "SetCurrencyTokenByID", function(self, id)
   addLine(self, id, kinds.currency)
end)

-- Quests任务
hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)
  local id = select(8, GetQuestLogTitle(self.questLogIndex))
  addLine(GameTooltip, id, kinds.quest)
end)

hooksecurefunc("TaskPOI_OnEnter", function(self)
  if self and self.questID then addLine(WorldMapTooltip, self.questID, kinds.quest) end
end)
-------------------------------------------------

local function attachItemTooltip(self)
  local link = select(2, self:GetItem())
  if not link then return end

  local itemString = string.match(link, "item:([%-?%d:]+)")
  if not itemString then return end

  local enchantid = ""
  local bonusid = ""
  local gemid = ""
  local bonuses = {}
  local itemSplit = {}

  for v in string.gmatch(itemString, "(%d*:?)") do
    if v == ":" then
      itemSplit[#itemSplit + 1] = 0
    else
      itemSplit[#itemSplit + 1] = string.gsub(v, ":", "")
    end
  end

  for index = 1, tonumber(itemSplit[13]) do
    bonuses[#bonuses + 1] = itemSplit[13 + index]
  end

  local gems = {}
  for i=1, 4 do
    local _,gemLink = GetItemGem(link, i)
    if gemLink then
      local gemDetail = string.match(gemLink, "item[%-?%d:]+")
      gems[#gems + 1] = string.match(gemDetail, "item:(%d+):")
    elseif flags == 256 then
      gems[#gems + 1] = "0"
    end
  end

  local id = string.match(link, "item:(%d*)")
  if (id == "" or id == "0") and TradeSkillFrame ~= nil and TradeSkillFrame:IsVisible() and GetMouseFocus().reagentIndex then
    local selectedRecipe = TradeSkillFrame.RecipeList:GetSelectedRecipeID()
    for i = 1, 8 do
      if GetMouseFocus().reagentIndex == i then
        id = C_TradeSkillUI.GetRecipeReagentItemLink(selectedRecipe, i):match("item:(%d*)") or nil
        break
      end
    end
  end

  if id then
    addLine(self, id, kinds.item)
    if itemSplit[2] ~= 0 then
      enchantid = itemSplit[2]
      addLine(self, enchantid, kinds.enchant)
    end
    if #bonuses ~= 0 then addLine(self, bonuses, kinds.bonus) end
    if #gems ~= 0 then addLine(self, gems, kinds.gem) end

    addLine(self, id, "ben",GetItemInfo(id))
  end
end
-----------------------------
function EPC:OnInitialize()--初始化
    self.Version = B.Version
    self.db = DB.profile.modules.demo

	GameTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
	ItemRefTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
	ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
	ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
	ShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
	ShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
end

function EPC:RefreshOption()
	LibStub("AceConfigRegistry-3.0"):NotifyChange("LittleBen")
end
function EPC:SetNotificationText()
	local db = self.db.custom
	self.spellMsg = db.enable and db.spellMsg or "格式   名称：内容。"
end





