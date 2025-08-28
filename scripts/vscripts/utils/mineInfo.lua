if mi == nil then
    mi = class({})
end

mi.ores = {
	["iron"] = {chance = 75, value = 3, item = "item_dotac_iron"},
	["silver"] = {chance = 30, value = 5, item = "item_dotac_silver"},
	["gold"] = {chance = 5, value = 7, item = "item_dotac_gold"},
}

return mi