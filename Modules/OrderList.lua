--  ///////////////////////////////////////////////////////////////////////////////////////////
--
--   
--  Author: SLOKnightfall

--  


--  ///////////////////////////////////////////////////////////////////////////////////////////

local addonName, addon = ...
addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local AceGUI = LibStub("AceGUI-3.0")
--local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local frames = {} 
addon.frames = frames

local PTC = {
  OrderType={
	RightCellPadding=0,
	Padding=10,
	LeftCellPadding=0,
	Width=145
  },
  Tip={
	RightCellPadding=0,
	Padding=10,
	LeftCellPadding=0,
	Width=150
  },
  Procs = {
  	RightCellPadding=0,
	Padding=10,
	LeftCellPadding=0,
	Width=180
  },
  CustomerName={
	RightCellPadding=0,
	Padding=10,
	LeftCellPadding=0,
	Width=155
  },
  NoPadding=0,
  StandardPadding=10,
  Name={
	LeftCellPadding=10,
	RightCellPadding=0,
	Padding=0,
	FillCoefficient=1,
	Width=75
  },
  ItemName={
	RightCellPadding=0,
	Padding=10,
	LeftCellPadding=0,
	Width=280
  },
   Date={
	RightCellPadding=0,
	Padding=10,
	LeftCellPadding=0,
	Width=140
  },
  Profession={
	RightCellPadding=0,
	Padding=10,
	LeftCellPadding=0,
	Width=110
  },
  Type={
	RightCellPadding=0,
	Padding=10,
	LeftCellPadding=0,
	Width=70
  }
}

local ignoreSkillLine = true;
local OrderBrowseType = EnumUtil.MakeEnum("Flat", "Bucketed", "None");
local orderTypeTabTitles =
{
	[Enum.CraftingOrderType.Public] = PROFESSIONS_CRAFTER_ORDER_TAB_PUBLIC,
	[Enum.CraftingOrderType.Guild] = PROFESSIONS_CRAFTER_ORDER_TAB_GUILD,
	[Enum.CraftingOrderType.Personal] = PROFESSIONS_CRAFTER_ORDER_TAB_PERSONAL,
};


local function GetHeaderNameFromSortOrder(sortOrder)
	if sortOrder == ProfessionsSortOrder.Tip then
		return PROFESSIONS_COLUMN_HEADER_TIP;
	elseif sortOrder == ProfessionsSortOrder.Reagents then
		return PROFESSIONS_COLUMN_HEADER_REAGENTS;
	elseif sortOrder == ProfessionsSortOrder.ItemName then
		return AUCTION_HOUSE_BROWSE_HEADER_NAME;
	elseif sortOrder == ProfessionsSortOrder.CustomerName then
		return CRAFTING_ORDERS_BROWSE_HEADER_CUSTOMER_NAME;
	elseif sortOrder == "Date" then
		return "Date";
	elseif sortOrder == "TYPE" then
		return "Type";
	elseif sortOrder == "Profession" then
		return "Profession";
	end
end

ProfessionsCrafterOrderListElementMixin2 = CreateFromMixins(ProfessionsCrafterOrderListElementMixin)
function ProfessionsCrafterOrderListElementMixin2:OnLineEnter()

	local hyperlink
	if not  self.option.results then
		_, hyperlink = GetItemInfo(self.option.orderInfo.itemID) 
	else
		hyperlink = self.option.results.hyperlink
	end

	if not hyperlink then return end

	self.HighlightTexture:Show();
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")

	GameTooltip:SetHyperlink(hyperlink)
end

function ProfessionsCrafterOrderListElementMixin2:OnClick(button)
end

ProfessionsCraftingOrderPageMixin2 = CreateFromMixins(ProfessionsCraftingOrderPageMixin)
function ProfessionsCraftingOrderPageMixin2:InitButtons()
end

function ProfessionsCraftingOrderPageMixin2:OnLoad()
	self:SetBrowseType(OrderBrowseType.None);
	self:InitOrderList();
	self:SetupTable();
end

function ProfessionsCraftingOrderPageMixin2:OnShow()
	local list = CopyTable(addon.db.char.orders)
	self:ShowGeneric(list, OrderBrowseType.None, 0, false);
end

function ProfessionsCraftingOrderPageMixin2:OnHide()
end

function ProfessionsCraftingOrderPageMixin2:InitOrderList()
	local pad = 5;
	local spacing = 1;
	local view = CreateScrollBoxListLinearView(pad, pad, pad, pad, spacing);
	view:SetElementInitializer("ProfessionsCrafterOrderListElementTemplate2", function(button, elementData)
		button:Init(elementData);
	end);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.BrowseFrame.OrderList.ScrollBox, self.BrowseFrame.OrderList.ScrollBar, view);

	UIDropDownMenu_SetInitializeFunction(self.BrowseFrame.OrderList.ContextMenu, GenerateClosure(self.InitContextMenu, self));
	UIDropDownMenu_SetDisplayMode(self.BrowseFrame.OrderList.ContextMenu, "MENU");
end

function ProfessionsCraftingOrderPageMixin2:SetupTable()
	local browseType = self:GetBrowseType();
	if not self.tableBuilder then
		self.tableBuilder = CreateTableBuilder(nil, RecieptProfessionsTableBuilderMixin);
		local function ElementDataTranslator(elementData)
			return elementData;
		end;
		ScrollUtil.RegisterTableBuilder(self.BrowseFrame.OrderList.ScrollBox, self.tableBuilder, ElementDataTranslator);
	
		local function ElementDataProvider(elementData)
			return elementData;
		end;
		self.tableBuilder:SetDataProvider(ElementDataProvider);
	end

	self.tableBuilder:Reset();
	self.tableBuilder:SetColumnHeaderOverlap(2);
	self.tableBuilder:SetHeaderContainer(self.BrowseFrame.OrderList.HeaderContainer);
	self.tableBuilder:SetTableMargins(-3, 5);
	self.tableBuilder:SetTableWidth(747);

	self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.Date.Width, PTC.Date.LeftCellPadding,
											  PTC.Date.RightCellPadding, "Date", "RecieptTableCellCustomerDateTemplate");
	
	self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.Profession.Width, PTC.Profession.LeftCellPadding,
											  PTC.Profession.RightCellPadding, "Profession", "RecieptTableCellProfessionTemplate");
	
	self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.Type.Width, PTC.Type.LeftCellPadding,
											  PTC.Type.RightCellPadding, "TYPE", "RecieptTableCellCustomerTypeTemplate");
	
	self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.ItemName.Width, PTC.ItemName.LeftCellPadding,
		 PTC.ItemName.RightCellPadding, ProfessionsSortOrder.ItemName, "RecieptTableCellItemNameTemplate");


	self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.CustomerName.Width, PTC.CustomerName.LeftCellPadding,
											  PTC.CustomerName.RightCellPadding, ProfessionsSortOrder.CustomerName, "RecieptTableCellCustomerNameTemplate");

	self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.Tip.Width, PTC.Tip.LeftCellPadding,
											  PTC.Tip.RightCellPadding, ProfessionsSortOrder.Tip, "RecieptTableCellActualCommissionTemplate");

	self.tableBuilder:AddUnsortableFixedWidthColumn(self, PTC.NoPadding, PTC.Procs.Width, PTC.Procs.LeftCellPadding,
											  PTC.Procs.RightCellPadding, "Procs", "RecieptTableCellProcsTemplate");

	self.tableBuilder:Arrange();
end

function ProfessionsCraftingOrderPageMixin2:SortOrderIsValid(sortOrder)
	return true
end


function date_to_excel_date(ss, min, hh, dd, mm, yy) 
local days, monthdays, leapyears, nonleapyears, nonnonleapyears

    monthdays= { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

    leapyears=tonumber(math.floor((yy-1900)/4));
    nonleapyears=tonumber(math.floor((yy-1900)/100))
    nonnonleapyears=tonumber(math.floor((yy-1600)/400))

    if (((yy%4)==0) and mm<3) then
      leapyears = leapyears - 1
    end

    days= 365 * (yy-1900) + leapyears - nonleapyears + nonnonleapyears

    c=1
    while (c<mm) do
      days = days + monthdays[c]
    c=c+1
    end

    days = days + dd + 1
	daysInMinutes = days * 24 * 60
	minutes = (hh * 60) + min
	seconds = ((daysInMinutes + minutes) * 60) + ss

    return seconds
end

local function SortDate(lhs, rhs)
	if not lhs or not rhs then return false end

	a = date_to_excel_date(lhs.date.sec, lhs.date.min, lhs.date.hour, lhs.date.day, lhs.date.month, lhs.date.year)
	b = date_to_excel_date(rhs.date.sec, rhs.date.min, rhs.date.hour, rhs.date.day, rhs.date.month, rhs.date.year)
	return a > b
end

local function ApplySortOrder(sortOrder, lhs, rhs)
	--if not lhs or not rhs then return false, false end
	if sortOrder == "Name" or sortOrder == ProfessionsSortOrder.ItemName then
		local lhsItem = Item:CreateFromItemID(lhs.orderInfo.itemID);
		local rhsItem = Item:CreateFromItemID(rhs.orderInfo.itemID);
		local lhsItemName = lhsItem:GetItemName();
		local rhsItemName = rhsItem:GetItemName();
		if not lhsItemName or not rhsItemName then return false, false end
		return lhsItemName < rhsItemName, lhsItemName == rhsItemName;
	elseif sortOrder == ProfessionsSortOrder.CustomerName then
		return lhs.orderInfo.customerName < rhs.orderInfo.customerName, lhs.orderInfo.customerName == rhs.orderInfo.customerName;
	elseif sortOrder == ProfessionsSortOrder.Tip then
		return lhs.orderInfo.tipAmount > rhs.orderInfo.tipAmount, lhs.orderInfo.tipAmount == rhs.orderInfo.tipAmount;
	elseif sortOrder == "Profession" then
		return lhs.profession > rhs.profession, lhs.profession == rhs.profession;
	elseif sortOrder == "TYPE" then
		return lhs.orderInfo.orderType > rhs.orderInfo.orderType, lhs.orderInfo.orderType == rhs.orderInfo.orderType;
	else --if sortOrder == "Date" then
		return SortDate(lhs, rhs), (
			lhs.date.sec == rhs.date.sec and 
			lhs.date.min == rhs.date.min and 
			lhs.date.hour == rhs.date.hour and 
			lhs.date.year == rhs.date.year and
			lhs.date.month == rhs.date.month and 
			lhs.date.day == rhs.date.day
		)
	end

	--return false, false;
end

function ProfessionsCraftingOrderPageMixin2:ResetSortOrder()
	self.primarySort =
	{
		order = "Date";
		ascending = true;
	};

	self.secondarySort = nil;

	if self.tableBuilder then
		for frame in self.tableBuilder:EnumerateHeaders() do
			frame:UpdateArrow();
		end
	end
end

function ProfessionsCraftingOrderPageMixin2:SetSortOrder(sortOrder)
	if self.primarySort.order == sortOrder then
		self.primarySort.ascending = not self.primarySort.ascending;
	else
		self.secondarySort = CopyTable(self.primarySort);
		self.primarySort =
		{
			order = sortOrder;
			ascending = true;
		};
	end

	if self.tableBuilder then
		for frame in self.tableBuilder:EnumerateHeaders() do
			frame:UpdateArrow();
		end
	end

	if self.lastRequest then
		self.lastRequest.offset = 0; -- Get a fresh page of sorted results
		self:SendOrderRequest(self.lastRequest);
	else
		local request =
		{
			orderType = self.orderType,
			selectedSkillLineAbility = selectedSkillLineAbility,
			searchFavorites = searchFavorites,
			initialNonPublicSearch = initialNonPublicSearch,
			offset = 0,
			forCrafter = true,
			--profession = self.professionInfo.profession,
		};
		self:SendOrderRequest(request);
	end
end

function ProfessionsCraftingOrderPageMixin2:SendOrderRequest(request)
	local isFlatSearch = request.selectedSkillLineAbility ~= nil;
	--self.BrowseFrame.RecipeList:ClearSelectedRecipe();
	self.selectedRecipe = nil;

	if request.offset == 0 then
		self.lastRequest = request;

		self.BrowseFrame.OrderList.ResultsText:Hide();
		self.BrowseFrame.OrderList.LoadingSpinner:Show();
		self.BrowseFrame.OrderList.SpinnerAnim:Restart();
		self.BrowseFrame.OrderList.ScrollBox:Hide();

		if not request.selectedSkillLineAbility then
			-- NOTE: This may not actually display buckets; we don't know until the server responds
			self.lastBucketRequest = request;
		end
	end

	-- Sort orders added to request in the send in case search orders changed from a cached request
	--request.primarySort = Professions.TranslateSearchSort(self.primarySort);
	--request.secondarySort = Professions.TranslateSearchSort(self.secondarySort) or (isFlatSearch and defaultFlatSecondarySort or defaultBucketSecondarySort);

	--if self.requestCallback then
		--self.requestCallback:Cancel();
	--end
	--self.requestCallback = C_FunctionContainers.CreateCallback(function(...) self:OrderRequestCallback(...); end);
	--request.callback = self.requestCallback;
	--C_CraftingOrders.RequestCrafterOrders(request);
	self:ShowOrders(offset, isSorted);
end

function ProfessionsCraftingOrderPageMixin2:OrderRequestCallback(result, orderType, displayBuckets, expectMoreRows, offset, isSorted)
	if orderType ~= self.orderType then
		return;
	end

	self.expectMoreRows = expectMoreRows;
	self:ShowOrders(offset, isSorted);

	self.requestCallback = nil;
end

function ProfessionsCraftingOrderPageMixin2:ShowOrders(offset, isSorted)
	if self.lastRequest == self.lastBucketRequest then
		-- We requested bucketed orders and were handed a flat list
		self.lastBucketRequest = nil;
	end
	--self.BrowseFrame.BackButton:SetShown(self.lastBucketRequest ~= nil);
	local list = CopyTable(addon.db.char.orders)
	self:ShowGeneric(list, OrderBrowseType.None, 0, false);
end 

function ProfessionsCraftingOrderPageMixin2:ShowGeneric(orders, browseType, offset, isSorted)
	
	self.BrowseFrame.OrderList.LoadingSpinner:Hide();
	self.BrowseFrame.OrderList.SpinnerAnim:Stop();
	self.BrowseFrame.OrderList.ScrollBox:Show();

	local dataProvider;
	if offset == 0 then
		dataProvider = CreateDataProvider();
		-- Need to set an initially empty provider in case the table columns changed
		self.BrowseFrame.OrderList.ScrollBox:SetDataProvider(dataProvider);
	end

	local sortlist = {}
	for id, data in pairs(orders) do
		tinsert(sortlist, data)
	end

	if not isSorted then
		table.sort(sortlist, function(lhs, rhs)
			local res, equal = ApplySortOrder(self.primarySort.order, lhs, rhs);
			if not equal then
				if self.primarySort.ascending then
					return res;
				else
					return not res;
				end
			end

			if self.secondarySort then
				--print(self.secondarySort.order)
			--	res, equal = ApplySortOrder(self.secondarySort.order, lhs, rhs);
				if self.secondarySort.ascending then
				--	return res;
				else
				--	return equal or (not res);
				end
			end

			return false;
		end);
	end
	
	self:SetBrowseType(browseType);


	if #sortlist == 0 then
		self.BrowseFrame.OrderList.ResultsText:SetText(PROFESSIONS_CUSTOMER_NO_ORDERS);
		self.BrowseFrame.OrderList.ResultsText:Show();
	else
		self.BrowseFrame.OrderList.ResultsText:Hide();
	end

	if offset == 0 then
		dataProvider = CreateDataProvider();
		for _, order in ipairs(sortlist) do
			dataProvider:Insert({option = order, browseType = browseType, pageFrame = self, contextMenu = self.BrowseFrame.OrderList.ContextMenu});
		end
		self.BrowseFrame.OrderList.ScrollBox:SetDataProvider(dataProvider);
	else
		dataProvider = self.BrowseFrame.OrderList.ScrollBox:GetDataProvider();
		for idx = offset + 1, #sortlist do
			local order = sortlist[idx];
			dataProvider:Insert({option = order, browseType = browseType, pageFrame = self, contextMenu = self.BrowseFrame.OrderList.ContextMenu});
		end
	end

	self.numOrders = #sortlist;
end

function ProfessionsCraftingOrderPageMixin2:OnRecipeSelected(recipeInfo, recipeList)
end

RecieptProfessionsTableBuilderMixin = CreateFromMixins(ProfessionsTableBuilderMixin);
function RecieptProfessionsTableBuilderMixin:AddColumnInternal(owner, sortOrder, cellTemplate, ...)
	local column = self:AddColumn();

	--if sortOrder then
		local headerName = GetHeaderNameFromSortOrder(sortOrder);
		column:ConstructHeader("BUTTON", "ProfessionsCrafterTableHeaderStringTemplate", owner, headerName, sortOrder);
	--end

	column:ConstructCells("FRAME", cellTemplate, owner, ...);

	return column;
end

RecieptTableCellDateMixin = CreateFromMixins(TableBuilderCellMixin);
function RecieptTableCellDateMixin:Populate(rowData, dataIndex)
	local orderdate = rowData.option.date

	zone = "am"
	hour = orderdate.hour
	if (hour > 11) then
		zone = "pm"
	end

	hour = hour % 12
	if (hour == 0) then
		hour = 12
	end

	minute = orderdate.min
	if (minute < 10) then
		minute = "0"..minute
	end

	local text = "  "..orderdate.month.."/"..orderdate.day.."/"..orderdate.year.." "..hour..":"..minute.." "..zone

	ProfessionsTableCellTextMixin.SetText(self, text);
end

RecieptTableCellProfessionMixin = CreateFromMixins(TableBuilderCellMixin);
function RecieptTableCellProfessionMixin:Populate(rowData, dataIndex)
	local text = addon:GetProfessionName(rowData.option.profession)

	ProfessionsTableCellTextMixin.SetText(self, text);
end

RecieptTableCellTypeMixin = CreateFromMixins(TableBuilderCellMixin);
function RecieptTableCellTypeMixin:Populate(rowData, dataIndex)
	local text = "";
	local order = rowData.option.orderInfo.orderType

	if order == 0 then
		 text = "Public"
	elseif order == 1 then
		 text = "Guild"
	elseif order == 2 then
		 text = "Personal"
	end

	ProfessionsTableCellTextMixin.SetText(self, text);
end

RecieptTableCellItemNameMixin = CreateFromMixins(TableBuilderCellMixin);
function RecieptTableCellItemNameMixin:Populate(rowData, dataIndex)
	local hyperlink
	if not  rowData.option.results then
		_, hyperlink = GetItemInfo(rowData.option.orderInfo.itemID) 
	else
		hyperlink = rowData.option.results.hyperlink
	end
	ProfessionsTableCellTextMixin.SetText(self, (hyperlink and hyperlink) or "Item Data Missing");
end

RecieptTableCellCustomerNameMixin = CreateFromMixins(TableBuilderCellMixin);
function RecieptTableCellCustomerNameMixin:Populate(rowData, dataIndex)
	local text = rowData.option.orderInfo.customerName
	ProfessionsTableCellTextMixin.SetText(self, text);
end

RecieptTableCellActualCommissionMixin = CreateFromMixins(TableBuilderCellMixin);
function RecieptTableCellActualCommissionMixin:Populate(rowData, dataIndex)
	local tipAmount = rowData.option.orderInfo.tipAmount
	local consortiumCut = rowData.option.orderInfo.consortiumCut
	local profit = tipAmount - consortiumCut;
	profit = addon:ConvertToGold(profit)

	--TODO: hide values of 0
	local text = profit[1].."   "..profit[2].."   "..profit[3]
	if rowData.option.orderInfo.isFulfillable then
		text = "--- recraft ---";
	end
	ProfessionsTableCellTextMixin.SetText(self, text);
end

RecieptTableCellProcsMixin = CreateFromMixins(TableBuilderCellMixin);
function RecieptTableCellProcsMixin:Populate(rowData, dataIndex)
	local text = ""
	local comma = ""
	if not rowData.option.results or not rowData.option.details then 
		ProfessionsTableCellTextMixin.SetText(self, "");
		return
	end

	if rowData.option.results.firstCraftReward then
		text = text.."1st Craft"
		comma = ", "
	end

	local craftQuality = rowData.option.details.craftingQuality or 0
	local actualQuality = rowData.option.results.craftingQuality or 0

	if rowData.option.results.isCrit then
		text = text..comma.."Inspired"
		comma = ", "
	else
		if actualQuality ~= 0  and craftQuality ~= actualQuality then
			local skill = rowData.option.details.upperSkillTreshold - (rowData.option.details.baseSkill  + rowData.option.details.bonusSkill)
			text = text.."Lucky(+"..skill..")"
			comma = ", "
		end
	end

	self:SetScript("OnEnter", function() end)
	self:SetScript("OnLeave", function()
			GameTooltip_Hide(); 
		end)

	if rowData.option.results.resourcesReturned then
		text = text..comma.."Resourceful"
		comma = ", "

		self:SetScript("OnEnter", function()
		local text = ""
		for i, d in ipairs(rowData.option.results.resourcesReturned) do
			local ItemID = Item:CreateFromItemID(d.itemID);
			local ItemName = ItemID:GetItemName();
			local quantity = d.quantity

			if (ItemName == nil) then
				ItemName = ''
			end

			text = text..ItemName.."("..quantity..")"
		end

		GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
		GameTooltip:SetText(text, nil, nil, nil, nil, true);
		GameTooltip:Show()
		end)
	end

	if rowData.option.results.multicraft ~= 0 then
		text = text..comma.."Multicraft"
	end

	ProfessionsTableCellTextMixin.SetText(self, text);
end