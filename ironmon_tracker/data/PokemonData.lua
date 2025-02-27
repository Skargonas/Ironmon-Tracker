PokemonData = {
	totalPokemon = 411,
}

PokemonData.IsRand = {
	pokemonTypes = false,
	pokemonAbilities = false, -- Currently unused by the Tracker, as it never reveals this information by default
	pokemonFriendship = false,
}

-- Enumerated constants that defines the various types a Pokémon and its Moves are
PokemonData.Types = {
	NORMAL = "normal",
	FIGHTING = "fighting",
	FLYING = "flying",
	POISON = "poison",
	GROUND = "ground",
	ROCK = "rock",
	BUG = "bug",
	GHOST = "ghost",
	STEEL = "steel",
	FIRE = "fire",
	WATER = "water",
	GRASS = "grass",
	ELECTRIC = "electric",
	PSYCHIC = "psychic",
	ICE = "ice",
	DRAGON = "dragon",
	DARK = "dark",
	-- FAIRY = "fairy", -- Currently unused. Expect this to be unused in Gen 1-5
	UNKNOWN = "unknown", -- For the move "Curse" in Gen 2-4
	EMPTY = "", -- No second type for this Pokémon or an empty field
}

-- Enumerated constants that defines various evolution possibilities
-- This enum does NOT include levels for evolution, only stones, friendship, no evolution, etc.
PokemonData.Evolutions = {
	-- This Pokémon does not evolve.
	NONE = {
		abbreviation = Constants.BLANKLINE,
		short = { Constants.BLANKLINE, },
		detailed = { Constants.BLANKLINE, },
	},
	-- Unused directly, necessary as an info index
	LEVEL = {
		abbreviation = "LEVEL",
		short = { "Lv.%s", }, -- requires level parameter
		detailed = { "Level %s", }, -- requires level value
	},
	-- High friendship
	FRIEND = {
		abbreviation = "FRIEND",
		short = { "Friend", },
		detailed = { "%s Friendship", }, -- requires friendship value
	},
	-- High friendship, Pokémon has enough friendship to evolve
	FRIEND_READY = {
		abbreviation = "READY",
	},
	-- Various evolution stone items
	EEVEE_STONES = {
		abbreviation = "STONE",
		short = { "Thunder", "Water", "Fire", "Sun", "Moon", },
		detailed = { "5 Diff. Stones", },
		evoItemIds = { 93, 94, 95, 96, 97 },
	},
	-- Thunderstone item
	THUNDER = {
		abbreviation = "THUNDER",
		short = { "Thunder", },
		detailed = { "Thunderstone", },
		evoItemIds = { 96 },
	},
	-- Fire stone item
	FIRE = {
		abbreviation = "FIRE",
		short = { "Fire", },
		detailed = { "Fire Stone", },
		evoItemIds = { 95 },
	},
	-- Water stone item
	WATER = {
		abbreviation = "WATER",
		short = { "Water", },
		detailed = { "Water Stone", },
		evoItemIds = { 97 },
	},
	-- Moon stone item
	MOON = {
		abbreviation = "MOON",
		short = { "Moon", },
		detailed = { "Moon Stone", },
		evoItemIds = { 94 },
	},
	-- Leaf stone item
	LEAF = {
		abbreviation = "LEAF",
		short = { "Leaf", },
		detailed = { "Leaf Stone", },
		evoItemIds = { 98 },
	},
	-- Sun stone item
	SUN = {
		abbreviation = "SUN",
		short = { "Sun", },
		detailed = { "Sun Stone", },
		evoItemIds = { 93 },
	},
	-- Leaf or Sun stone items
	LEAF_SUN = {
		abbreviation = "LF/SN",
		short = { "Leaf", "Sun", },
		detailed = { "Leaf Stone", "Sun Stone", },
		evoItemIds = { 93, 98, },
	},
	-- Water stone item or at level 30
	WATER30 = {
		abbreviation = "30/WTR",
		short = { "Lv.30", "Water", },
		detailed = { "Level 30", "Water Stone", },
		evoItemIds = { 97 },
	},
	-- Water stone item or at level 37
	WATER37 = {
		abbreviation = "37/WTR",
		short = { "Lv.37", "Water", },
		detailed = { "Level 37", "Water Stone", },
		evoItemIds = { 97 },
	},
}

PokemonData.BlankPokemon = {
	pokemonID = 0,
	name = Constants.BLANKLINE,
	types = { PokemonData.Types.UNKNOWN, PokemonData.Types.EMPTY },
	abilities = { 0, 0 },
	evolution = PokemonData.Evolutions.NONE,
	bst = Constants.BLANKLINE,
	yield = 0,
	movelvls = { {}, {} },
	weight = 0.0,
	friendship = 0,
	friendshipBase = 0,
}

function PokemonData.initialize()
	-- Reads the types and abilities for each Pokemon in the Pokedex
	-- If any data at all was randomized, read in full Pokemon data from memory
	if PokemonData.checkIfDataIsRandomized() then
		for pokemonID=1, PokemonData.totalPokemon, 1 do
			local pokemonData = PokemonData.Pokemon[pokemonID]

			if PokemonData.IsRand.pokemonTypes then
				local types = PokemonData.readPokemonTypesFromMemory(pokemonID)
				if types ~= nil then
					pokemonData.types = types
				end
			end
			if PokemonData.IsRand.pokemonAbilities then
				local abilities = PokemonData.readPokemonAbilitiesFromMemory(pokemonID)
				if abilities ~= nil then
					pokemonData.abilities = abilities
				end
			end
			if PokemonData.IsRand.pokemonFriendship then
				local friendshipBase = PokemonData.readPokemonBaseFriendshipFromMemory(pokemonID)
				if friendshipBase ~= 0 then
					pokemonData.friendshipBase = friendshipBase
				end
			end
		end
	end

	-- Add in pokemon IDs since they were never manually included in the past
	for id, pokemon in ipairs(PokemonData.Pokemon) do
		if pokemon.bst ~= Constants.BLANKLINE then -- Skip fake Pokemon
			pokemon.pokemonID = id
		end
	end
end

function PokemonData.updateResources()
	for i, val in ipairs(PokemonData.Pokemon) do
		if Resources.Game.PokemonNames[i] then
			val.name = Resources.Game.PokemonNames[i]
		end
	end

	-- Manually add in each evolution translation, as each has different formatting
	local PE = PokemonData.Evolutions
	local RPED = Resources.PokemonEvolutionDetails
	-- PE.LEVEL.abbreviation = RPED.LEVEL.abbreviation -- Doesn't need translation; not displayed
	PE.LEVEL.short = { RPED.LEVEL.short .. "%s" }
	PE.LEVEL.detailed = { RPED.LEVEL.detailed .. " %s" }
	PE.FRIEND.abbreviation = RPED.FRIEND.abbreviation
	PE.FRIEND.short = { RPED.FRIEND.short }
	PE.FRIEND.detailed = { "%s " .. RPED.FRIEND.detailed }
	PE.FRIEND_READY.abbreviation = RPED.FRIEND_READY.abbreviation
	PE.EEVEE_STONES.abbreviation = RPED.EEVEE_STONES.abbreviation
	PE.EEVEE_STONES.short = { RPED.THUNDER.short, RPED.WATER.short, RPED.FIRE.short, RPED.SUN.short, RPED.MOON.short, }
	PE.EEVEE_STONES.detailed = { RPED.EEVEE_STONES.detailed, }
	PE.THUNDER.abbreviation = RPED.THUNDER.abbreviation
	PE.THUNDER.short = { RPED.THUNDER.short }
	PE.THUNDER.detailed = { RPED.THUNDER.detailed }
	PE.FIRE.abbreviation = RPED.FIRE.abbreviation
	PE.FIRE.short = { RPED.FIRE.short }
	PE.FIRE.detailed = { RPED.FIRE.detailed }
	PE.WATER.abbreviation = RPED.WATER.abbreviation
	PE.WATER.short = { RPED.WATER.short }
	PE.WATER.detailed = { RPED.WATER.detailed }
	PE.MOON.abbreviation = RPED.MOON.abbreviation
	PE.MOON.short = { RPED.MOON.short }
	PE.MOON.detailed = { RPED.MOON.detailed }
	PE.LEAF.abbreviation = RPED.LEAF.abbreviation
	PE.LEAF.short = { RPED.LEAF.short }
	PE.LEAF.detailed = { RPED.LEAF.detailed }
	PE.SUN.abbreviation = RPED.SUN.abbreviation
	PE.SUN.short = { RPED.SUN.short }
	PE.SUN.detailed = { RPED.SUN.detailed }
	PE.LEAF_SUN.abbreviation = RPED.LEAF_SUN.abbreviation
	PE.LEAF_SUN.short = { RPED.LEAF.short, RPED.SUN.short, }
	PE.LEAF_SUN.detailed = { RPED.LEAF.detailed, RPED.SUN.detailed, }
	PE.WATER30.abbreviation = RPED.WATER30.abbreviation
	PE.WATER30.short = { RPED.LEVEL.short .. "30", RPED.WATER.short, }
	PE.WATER30.detailed = { RPED.LEVEL.detailed .. " 30", RPED.WATER.detailed, }
	PE.WATER37.abbreviation = RPED.WATER37.abbreviation
	PE.WATER37.short = { RPED.LEVEL.short .. "37", RPED.WATER.short, }
	PE.WATER37.detailed = { RPED.LEVEL.detailed .. " 37", RPED.WATER.detailed, }
end

function PokemonData.getTypeResource(typename)
	typename = typename or "unknown"
	return Resources.Game.PokemonTypes[typename] or Resources.Game.PokemonTypes.unknown
end

function PokemonData.readPokemonTypesFromMemory(pokemonID)
	local typesData = Memory.readword(GameSettings.gBaseStats + (pokemonID * 0x1C) + 0x06)
	local typeOne = Utils.getbits(typesData, 0, 8)
	local typeTwo = Utils.getbits(typesData, 8, 8)

	return {
		PokemonData.TypeIndexMap[typeOne],
		PokemonData.TypeIndexMap[typeTwo],
	}
end

function PokemonData.readPokemonAbilitiesFromMemory(pokemonID)
	local abilitiesData = Memory.readword(GameSettings.gBaseStats + (pokemonID * 0x1C) + 0x16)
	local abilityIdOne = Utils.getbits(abilitiesData, 0, 8)
	local abilityIdTwo = Utils.getbits(abilitiesData, 8, 8)

	return {
		Utils.inlineIf(abilityIdOne == 0, 0, abilityIdOne),
		Utils.inlineIf(abilityIdTwo == 0, 0, abilityIdTwo),
	}
end

function PokemonData.readPokemonBaseFriendshipFromMemory(pokemonID)
	local baseFriendshipData = Memory.readword(GameSettings.gBaseStats + (pokemonID * 0x1C) + 0x12)
	local friendshipBase = Utils.getbits(baseFriendshipData, 0, 8)

	return friendshipBase
end

function PokemonData.checkIfDataIsRandomized()
	local areTypesRandomized = false
	local areAbilitiesRandomized = false
	local areBaseFriendshipsModified = false

	-- Check once if any data was randomized
	local types = PokemonData.readPokemonTypesFromMemory(1) -- Bulbasaur
	local abilities = PokemonData.readPokemonAbilitiesFromMemory(1) -- Bulbasaur
	local friendshipBase = PokemonData.readPokemonBaseFriendshipFromMemory(1) -- Bulbasaur

	if types ~= nil then
		areTypesRandomized = types[1] ~= PokemonData.Types.GRASS or types[2] ~= PokemonData.Types.POISON
	end
	if abilities ~= nil then
		areAbilitiesRandomized = abilities[1] ~= 65 or abilities[2] ~= 65 -- 65 = Overgrow
	end
	if friendshipBase ~= 0 then
		areBaseFriendshipsModified = friendshipBase ~= 70  -- Bulbasaur's base friendship is 70
	end

	-- Check twice if any data was randomized (Randomizer does *not* force a change)
	if not areTypesRandomized or not areAbilitiesRandomized or not areBaseFriendshipsModified then
		types = PokemonData.readPokemonTypesFromMemory(131) -- Lapras
		abilities = PokemonData.readPokemonAbilitiesFromMemory(131) -- Lapras
		friendshipBase = PokemonData.readPokemonBaseFriendshipFromMemory(131) --Lapras

		if types ~= nil and (types[1] ~= PokemonData.Types.WATER or types[2] ~= PokemonData.Types.ICE) then
			areTypesRandomized = true
		end
		if abilities ~= nil and (abilities[1] ~= 11 or abilities[2] ~= 75) then -- 11 = Water Absorb, 75 = Shell Armor
			areAbilitiesRandomized = true
		end
		if friendshipBase ~= 0 and (friendshipBase ~= 70) then -- Lapras' base friendship is 70
			areBaseFriendshipsModified = true
		end
	end

	PokemonData.IsRand.pokemonTypes = areTypesRandomized
	-- For now, read in all ability data since it's not stored in the PokemonData.Pokemon below
	areAbilitiesRandomized = true
	PokemonData.IsRand.pokemonAbilities = areAbilitiesRandomized
	PokemonData.IsRand.pokemonFriendship = areBaseFriendshipsModified

	return areTypesRandomized or areAbilitiesRandomized or areBaseFriendshipsModified
end

--- @return integer abilityId The abilityId of the Pokémon, or 0 if it doesn't exist
function PokemonData.getAbilityId(pokemonID, abilityNum)
	if abilityNum == nil or not PokemonData.isValid(pokemonID) then
		return 0
	end
	local pokemon = PokemonData.Pokemon[pokemonID]
	return pokemon.abilities[abilityNum + 1] or 0 -- abilityNum stored from memory as [0 or 1]
end

function PokemonData.isValid(pokemonID)
	return pokemonID ~= nil and pokemonID >= 1 and pokemonID <= PokemonData.totalPokemon
end

function PokemonData.isImageIDValid(pokemonID)
	--Eggs (412), Ghosts (413), and placeholder (0)
	return PokemonData.isValid(pokemonID) or pokemonID == 412 or pokemonID == 413 or pokemonID == 0
end

local idInternalToNat = {
	[277] = 252, [278] = 253, [279] = 254, [280] = 255, [281] = 256, [282] = 257, [283] = 258, [284] = 259,
	[285] = 260, [286] = 261, [287] = 262, [288] = 263, [289] = 264, [290] = 265, [291] = 266, [292] = 267, [293] = 268, [294] = 269,
	[295] = 270, [296] = 271, [297] = 272, [298] = 273, [299] = 274, [300] = 275, [304] = 276, [305] = 277, [309] = 278, [310] = 279,
	[392] = 280, [393] = 281, [394] = 282, [311] = 283, [312] = 284, [306] = 285, [307] = 286, [364] = 287, [365] = 288, [366] = 289,
	[301] = 290, [302] = 291, [303] = 292, [370] = 293, [371] = 294, [372] = 295, [335] = 296, [336] = 297, [350] = 298, [320] = 299,
	[315] = 300, [316] = 301, [322] = 302, [355] = 303, [382] = 304, [383] = 305, [384] = 306, [356] = 307, [357] = 308, [337] = 309,
	[338] = 310, [353] = 311, [354] = 312, [386] = 313, [387] = 314, [363] = 315, [367] = 316, [368] = 317, [330] = 318, [331] = 319,
	[313] = 320, [314] = 321, [339] = 322, [340] = 323, [321] = 324, [351] = 325, [352] = 326, [308] = 327, [332] = 328, [333] = 329,
	[334] = 330, [344] = 331, [345] = 332, [358] = 333, [359] = 334, [380] = 335, [379] = 336, [348] = 337, [349] = 338, [323] = 339,
	[324] = 340, [326] = 341, [327] = 342, [318] = 343, [319] = 344, [388] = 345, [389] = 346, [390] = 347, [391] = 348, [328] = 349,
	[329] = 350, [385] = 351, [317] = 352, [377] = 353, [378] = 354, [361] = 355, [362] = 356, [369] = 357, [411] = 358, [376] = 359,
	[360] = 360, [346] = 361, [347] = 362, [341] = 363, [342] = 364, [343] = 365, [373] = 366, [374] = 367, [375] = 368, [381] = 369,
	[325] = 370, [395] = 371, [396] = 372, [397] = 373, [398] = 374, [399] = 375, [400] = 376, [401] = 377, [402] = 378, [403] = 379,
	[407] = 380, [408] = 381, [404] = 382, [405] = 383, [406] = 384, [409] = 385, [410] = 386,
}
local idNatToInternal = {
	[252] = 277, [253] = 278, [254] = 279, [255] = 280, [256] = 281, [257] = 282, [258] = 283, [259] = 284,
	[260] = 285, [261] = 286, [262] = 287, [263] = 288, [264] = 289, [265] = 290, [266] = 291, [267] = 292, [268] = 293, [269] = 294,
	[270] = 295, [271] = 296, [272] = 297, [273] = 298, [274] = 299, [275] = 300, [276] = 304, [277] = 305, [278] = 309, [279] = 310,
	[280] = 392, [281] = 393, [282] = 394, [283] = 311, [284] = 312, [285] = 306, [286] = 307, [287] = 364, [288] = 365, [289] = 366,
	[290] = 301, [291] = 302, [292] = 303, [293] = 370, [294] = 371, [295] = 372, [296] = 335, [297] = 336, [298] = 350, [299] = 320,
	[300] = 315, [301] = 316, [302] = 322, [303] = 355, [304] = 382, [305] = 383, [306] = 384, [307] = 356, [308] = 357, [309] = 337,
	[310] = 338, [311] = 353, [312] = 354, [313] = 386, [314] = 387, [315] = 363, [316] = 367, [317] = 368, [318] = 330, [319] = 331,
	[320] = 313, [321] = 314, [322] = 339, [323] = 340, [324] = 321, [325] = 351, [326] = 352, [327] = 308, [328] = 332, [329] = 333,
	[330] = 334, [331] = 344, [332] = 345, [333] = 358, [334] = 359, [335] = 380, [336] = 379, [337] = 348, [338] = 349, [339] = 323,
	[340] = 324, [341] = 326, [342] = 327, [343] = 318, [344] = 319, [345] = 388, [346] = 389, [347] = 390, [348] = 391, [349] = 328,
	[350] = 329, [351] = 385, [352] = 317, [353] = 377, [354] = 378, [355] = 361, [356] = 362, [357] = 369, [358] = 411, [359] = 376,
	[360] = 360, [361] = 346, [362] = 347, [363] = 341, [364] = 342, [365] = 343, [366] = 373, [367] = 374, [368] = 375, [369] = 381,
	[370] = 325, [371] = 395, [372] = 396, [373] = 397, [374] = 398, [375] = 399, [376] = 400, [377] = 401, [378] = 402, [379] = 403,
	[380] = 407, [381] = 408, [382] = 404, [383] = 405, [384] = 406, [385] = 409, [386] = 410,
}

--- Converts a Gen 3 Internal Dex # to its matching National Pokédex #
--- @param pokemonID integer The Pokémon ID to convert (Gen 3 internal Pokédex #)
--- @return integer
function PokemonData.dexMapInternalToNational(pokemonID)
	return idInternalToNat[pokemonID or 0] or pokemonID
end

--- Converts a National Pokédex # to its matching Gen 3 Internal Dex #
--- @param pokemonID integer The Pokémon ID to convert (National Pokédex #)
--- @return integer
function PokemonData.dexMapNationalToInternal(pokemonID)
	return idNatToInternal[pokemonID or 0] or pokemonID
end

function PokemonData.getIdFromName(pokemonName)
	for id, pokemon in pairs(PokemonData.Pokemon) do
		if pokemon.name == pokemonName then
			return id
		end
	end

	return nil
end

function PokemonData.namesToList()
	local pokemonNames = {}
	for _, pokemon in ipairs(PokemonData.Pokemon) do
		if pokemon.bst ~= Constants.BLANKLINE then -- Skip fake Pokemon
			table.insert(pokemonNames, pokemon.name)
		end
	end
	return pokemonNames
end

-- Returns a table that contains the type weaknesses, resistances, and immunities for a Pokémon, listed as type-strings
function PokemonData.getEffectiveness(pokemonID)
	local effectiveness = {
		[0] = {},
		[0.25] = {},
		[0.5] = {},
		[1] = {},
		[2] = {},
		[4] = {},
	}

	if not PokemonData.isValid(pokemonID) then
		return effectiveness
	end

	local pokemon = PokemonData.Pokemon[pokemonID]

	for moveType, typeMultiplier in pairs(MoveData.TypeToEffectiveness) do
		local total = 1
		if typeMultiplier[pokemon.types[1]] ~= nil then
			total = total * typeMultiplier[pokemon.types[1]]
		end
		if pokemon.types[2] ~= pokemon.types[1] and typeMultiplier[pokemon.types[2]] ~= nil then
			total = total * typeMultiplier[pokemon.types[2]]
		end
		if effectiveness[total] ~= nil then
			table.insert(effectiveness[total], moveType)
		end
	end

	return effectiveness
end

PokemonData.TypeIndexMap = {
	[0x00] = PokemonData.Types.NORMAL,
	[0x01] = PokemonData.Types.FIGHTING,
	[0x02] = PokemonData.Types.FLYING,
	[0x03] = PokemonData.Types.POISON,
	[0x04] = PokemonData.Types.GROUND,
	[0x05] = PokemonData.Types.ROCK,
	[0x06] = PokemonData.Types.BUG,
	[0x07] = PokemonData.Types.GHOST,
	[0x08] = PokemonData.Types.STEEL,
	[0x09] = PokemonData.Types.UNKNOWN, -- MYSTERY
	[0x0A] = PokemonData.Types.FIRE,
	[0x0B] = PokemonData.Types.WATER,
	[0x0C] = PokemonData.Types.GRASS,
	[0x0D] = PokemonData.Types.ELECTRIC,
	[0x0E] = PokemonData.Types.PSYCHIC,
	[0x0F] = PokemonData.Types.ICE,
	[0x10] = PokemonData.Types.DRAGON,
	[0x11] = PokemonData.Types.DARK,
}

--[[
Data for each Pokémon (Gen 3) - Sourced from Bulbapedia
Format for an entry:
	name: string -> Name of the Pokémon as it appears in game
	types: {string, string} -> Each Pokémon can have one or two types, using the PokemonData.Types enum to alias the strings
	evolution: string -> Displays the level, item, or other requirement a Pokémon needs to evolve
	bst: string -> A sum of the base stats of the Pokémon
	yield: integer -> Base experience yield of the Pokémon
	movelvls: {{integer list}, {integer list}} -> A pair of tables (1:RSE/2:FRLG) declaring the levels at which a Pokémon learns new moves or an empty list means it learns nothing
	weight: pokemon's weight in kg (mainly used for Low Kick calculations)
]]
PokemonData.Pokemon = {
	{
		name = "Bulbasaur",
		types = { PokemonData.Types.GRASS, PokemonData.Types.POISON },
		evolution = "16",
		bst = "318",
		yield = 64,
		movelvls = { { 4, 7, 10, 15, 15, 20, 25, 32, 39, 46 }, { 4, 7, 10, 15, 15, 20, 25, 32, 39, 46 } },
		weight = 6.9
	},
	{
		name = "Ivysaur",
		types = { PokemonData.Types.GRASS, PokemonData.Types.POISON },
		evolution = "32",
		bst = "405",
		yield = 141,
		movelvls = { { 4, 7, 10, 15, 15, 22, 29, 38, 47, 56 }, { 4, 7, 10, 15, 15, 22, 29, 38, 47, 56 } },
		weight = 13.0
	},
	{
		name = "Venusaur",
		types = { PokemonData.Types.GRASS, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "525",
		yield = 208,
		movelvls = { { 4, 7, 10, 15, 15, 22, 29, 41, 53, 65 }, { 4, 7, 10, 15, 15, 22, 29, 41, 53, 65 } },
		weight = 100.0
	},
	{
		name = "Charmander",
		types = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = "16",
		bst = "309",
		yield = 65,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 8.5
	},
	{
		name = "Charmeleon",
		types = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = "36",
		bst = "405",
		yield = 142,
		movelvls = { { 7, 13, 20, 27, 34, 41, 48, 55 }, { 7, 13, 20, 27, 34, 41, 48, 55 } },
		weight = 19.0
	},
	{
		name = "Charizard",
		types = { PokemonData.Types.FIRE, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "534",
		yield = 209,
		movelvls = { { 7, 13, 20, 27, 34, 36, 44, 54, 64 }, { 7, 13, 20, 27, 34, 36, 44, 54, 64 } },
		weight = 90.5
	},
	{
		name = "Squirtle",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "16",
		bst = "314",
		yield = 66,
		movelvls = { { 4, 7, 10, 13, 18, 23, 28, 33, 40, 47 }, { 4, 7, 10, 13, 18, 23, 28, 33, 40, 47 } },
		weight = 9.0
	},
	{
		name = "Wartortle",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "36",
		bst = "405",
		yield = 143,
		movelvls = { { 4, 7, 10, 13, 19, 25, 31, 37, 45, 53 }, { 4, 7, 10, 13, 19, 25, 31, 37, 45, 53 } },
		weight = 22.5
	},
	{
		name = "Blastoise",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "530",
		yield = 210,
		movelvls = { { 4, 7, 10, 13, 19, 25, 31, 42, 55, 68 }, { 4, 7, 10, 13, 19, 25, 31, 42, 55, 68 } },
		weight = 85.5
	},
	{
		name = "Caterpie",
		types = { PokemonData.Types.BUG, PokemonData.Types.EMPTY },
		evolution = "7",
		bst = "195",
		yield = 53,
		movelvls = { {}, {} },
		weight = 2.9
	},
	{
		name = "Metapod",
		types = { PokemonData.Types.BUG, PokemonData.Types.EMPTY },
		evolution = "10",
		bst = "205",
		yield = 72,
		movelvls = { { 7 }, { 7 } },
		weight = 9.9
	},
	{
		name = "Butterfree",
		types = { PokemonData.Types.BUG, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "385",
		yield = 160,
		movelvls = { { 10, 13, 14, 15, 18, 23, 28, 34, 40, 47 }, { 10, 13, 14, 15, 18, 23, 28, 34, 40, 47 } },
		weight = 32.0
	},
	{
		name = "Weedle",
		types = { PokemonData.Types.BUG, PokemonData.Types.POISON },
		evolution = "7",
		bst = "195",
		yield = 52,
		movelvls = { {}, {} },
		weight = 3.2
	},
	{
		name = "Kakuna",
		types = { PokemonData.Types.BUG, PokemonData.Types.POISON },
		evolution = "10",
		bst = "205",
		yield = 71,
		movelvls = { { 7 }, { 7 } },
		weight = 10.0
	},
	{
		name = "Beedrill",
		types = { PokemonData.Types.BUG, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "385",
		yield = 159,
		movelvls = { { 10, 15, 20, 25, 30, 35, 40, 45 }, { 10, 15, 20, 25, 30, 35, 40, 45 } },
		weight = 29.5
	},
	{
		name = "Pidgey",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = "18",
		bst = "251",
		yield = 55,
		movelvls = { { 5, 9, 13, 19, 25, 31, 39, 47 }, { 5, 9, 13, 19, 25, 31, 39, 47 } },
		weight = 1.8
	},
	{
		name = "Pidgeotto",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = "36",
		bst = "349",
		yield = 113,
		movelvls = { { 5, 9, 13, 20, 27, 34, 43, 52 }, { 5, 9, 13, 20, 27, 34, 43, 52 } },
		weight = 30.0
	},
	{
		name = "Pidgeot",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "469",
		yield = 172,
		movelvls = { { 5, 9, 13, 20, 27, 34, 48, 62 }, { 5, 9, 13, 20, 27, 34, 48, 62 } },
		weight = 39.5
	},
	{
		name = "Rattata",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "20",
		bst = "253",
		yield = 57,
		movelvls = { { 7, 13, 20, 27, 34, 41 }, { 7, 13, 20, 27, 34, 41 } },
		weight = 3.5
	},
	{
		name = "Raticate",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "413",
		yield = 116,
		movelvls = { { 7, 13, 20, 30, 40, 50 }, { 7, 13, 20, 30, 40, 50 } },
		weight = 18.5
	},
	{
		name = "Spearow",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = "20",
		bst = "262",
		yield = 58,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43 }, { 7, 13, 19, 25, 31, 37, 43 } },
		weight = 2.0
	},
	{
		name = "Fearow",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "442",
		yield = 162,
		movelvls = { { 7, 13, 26, 32, 40, 47 }, { 7, 13, 26, 32, 40, 47 } },
		weight = 38.0
	},
	{
		name = "Ekans",
		types = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = "22",
		bst = "288",
		yield = 62,
		movelvls = { { 8, 13, 20, 25, 32, 37, 37, 37, 44 }, { 8, 13, 20, 25, 32, 37, 37, 37, 44 } },
		weight = 6.9
	},
	{
		name = "Arbok",
		types = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "438",
		yield = 147,
		movelvls = { { 8, 13, 20, 28, 38, 46, 46, 46, 56 }, { 8, 13, 20, 28, 38, 46, 46, 46, 56 } },
		weight = 65.0
	},
	{
		name = "Pikachu",
		types = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.THUNDER,
		bst = "300",
		yield = 82,
		movelvls = { { 6, 8, 11, 15, 20, 26, 33, 41, 50 }, { 6, 8, 11, 15, 20, 26, 33, 41, 50 } },
		weight = 6.0
	},
	{
		name = "Raichu",
		types = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "475",
		yield = 122,
		movelvls = { {}, {} },
		weight = 30.0
	},
	{
		name = "Sandshrew",
		types = { PokemonData.Types.GROUND, PokemonData.Types.EMPTY },
		evolution = "22",
		bst = "300",
		yield = 93,
		movelvls = { { 6, 11, 17, 23, 30, 37, 45, 53 }, { 6, 11, 17, 23, 30, 37, 45, 53 } },
		weight = 12.0
	},
	{
		name = "Sandslash",
		types = { PokemonData.Types.GROUND, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "450",
		yield = 163,
		movelvls = { { 6, 11, 17, 24, 33, 42, 52, 62 }, { 6, 11, 17, 24, 33, 42, 52, 62 } },
		weight = 29.5
	},
	{
		name = "Nidoran F",
		types = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = "16",
		bst = "275",
		yield = 59,
		movelvls = { { 8, 12, 17, 20, 23, 30, 38, 47 }, { 8, 12, 17, 20, 23, 30, 38, 47 } },
		weight = 7.0
	},
	{
		name = "Nidorina",
		types = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.MOON,
		bst = "365",
		yield = 117,
		movelvls = { { 8, 12, 18, 22, 26, 34, 43, 53 }, { 8, 12, 18, 22, 26, 34, 43, 53 } },
		weight = 20.0
	},
	{
		name = "Nidoqueen",
		types = { PokemonData.Types.POISON, PokemonData.Types.GROUND },
		evolution = PokemonData.Evolutions.NONE,
		bst = "495",
		yield = 194,
		movelvls = { { 23 }, { 22, 43 } },
		weight = 60.0
	},
	{
		name = "Nidoran M",
		types = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = "16",
		bst = "273",
		yield = 60,
		movelvls = { { 8, 12, 17, 20, 23, 30, 38, 47 }, { 8, 12, 17, 20, 23, 30, 38, 47 } },
		weight = 9.0
	},
	{
		name = "Nidorino",
		types = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.MOON,
		bst = "365",
		yield = 118,
		movelvls = { { 8, 12, 18, 22, 26, 34, 43, 53 }, { 8, 12, 18, 22, 26, 34, 43, 53 } },
		weight = 19.5
	},
	{
		name = "Nidoking",
		types = { PokemonData.Types.POISON, PokemonData.Types.GROUND },
		evolution = PokemonData.Evolutions.NONE,
		bst = "495",
		yield = 195,
		movelvls = { { 23 }, { 22, 43 } },
		weight = 62.0
	},
	{
		name = "Clefairy",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.MOON,
		bst = "323",
		yield = 68,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 } },
		weight = 7.5,
		friendshipBase = 140
	},
	{
		name = "Clefable",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "473",
		yield = 129,
		movelvls = { {}, {} },
		weight = 40.0,
		friendshipBase = 140
	},
	{
		name = "Vulpix",
		types = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.FIRE,
		bst = "299",
		yield = 63,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41 } },
		weight = 9.9
	},
	{
		name = "Ninetales",
		types = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "505",
		yield = 178,
		movelvls = { { 45 }, { 45 } },
		weight = 19.9
	},
	{
		name = "Jigglypuff",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.MOON,
		bst = "270",
		yield = 76,
		movelvls = { { 4, 9, 14, 19, 24, 29, 34, 39, 44, 49 }, { 4, 9, 14, 19, 24, 29, 34, 39, 44, 49 } },
		weight = 5.5
	},
	{
		name = "Wigglytuff",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "425",
		yield = 109,
		movelvls = { {}, {} },
		weight = 12.0
	},
	{
		name = "Zubat",
		types = { PokemonData.Types.POISON, PokemonData.Types.FLYING },
		evolution = "22",
		bst = "245",
		yield = 54,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 7.5
	},
	{
		name = "Golbat",
		types = { PokemonData.Types.POISON, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.FRIEND,
		bst = "455",
		yield = 171,
		movelvls = { { 6, 11, 16, 21, 28, 35, 42, 49, 56 }, { 6, 11, 16, 21, 28, 35, 42, 49, 56 } },
		weight = 55.0
	},
	{
		name = "Oddish",
		types = { PokemonData.Types.GRASS, PokemonData.Types.POISON },
		evolution = "21",
		bst = "320",
		yield = 78,
		movelvls = { { 7, 14, 16, 18, 23, 32, 39 }, { 7, 14, 16, 18, 23, 32, 39 } },
		weight = 5.4
	},
	{
		name = "Gloom",
		types = { PokemonData.Types.GRASS, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.LEAF_SUN,
		bst = "395",
		yield = 132,
		movelvls = { { 7, 14, 16, 18, 24, 35, 44 }, { 7, 14, 16, 18, 24, 35, 44 } },
		weight = 8.6
	},
	{
		name = "Vileplume",
		types = { PokemonData.Types.GRASS, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "480",
		yield = 184,
		movelvls = { { 44 }, { 44 } },
		weight = 18.6
	},
	{
		name = "Paras",
		types = { PokemonData.Types.BUG, PokemonData.Types.GRASS },
		evolution = "24",
		bst = "285",
		yield = 70,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 5.4
	},
	{
		name = "Parasect",
		types = { PokemonData.Types.BUG, PokemonData.Types.GRASS },
		evolution = PokemonData.Evolutions.NONE,
		bst = "405",
		yield = 128,
		movelvls = { { 7, 13, 19, 27, 35, 43, 51, 59 }, { 7, 13, 19, 27, 35, 43, 51, 59 } },
		weight = 29.5
	},
	{
		name = "Venonat",
		types = { PokemonData.Types.BUG, PokemonData.Types.POISON },
		evolution = "31",
		bst = "305",
		yield = 75,
		movelvls = { { 9, 17, 20, 25, 28, 33, 36, 41 }, { 9, 17, 20, 25, 28, 33, 36, 41 } },
		weight = 30.0
	},
	{
		name = "Venomoth",
		types = { PokemonData.Types.BUG, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "450",
		yield = 138,
		movelvls = { { 9, 17, 20, 25, 28, 31, 36, 42, 52 }, { 9, 17, 20, 25, 28, 31, 36, 42, 52 } },
		weight = 12.5
	},
	{
		name = "Diglett",
		types = { PokemonData.Types.GROUND, PokemonData.Types.EMPTY },
		evolution = "26",
		bst = "265",
		yield = 81,
		movelvls = { { 5, 9, 17, 25, 33, 41, 49 }, { 5, 9, 17, 21, 25, 33, 41, 49 } },
		weight = 0.8
	},
	{
		name = "Dugtrio",
		types = { PokemonData.Types.GROUND, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "405",
		yield = 153,
		movelvls = { { 5, 9, 17, 25, 26, 38, 51, 64 }, { 5, 9, 17, 21, 25, 26, 38, 51, 64 } },
		weight = 33.3
	},
	{
		name = "Meowth",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "28",
		bst = "290",
		yield = 69,
		movelvls = { { 11, 20, 28, 35, 41, 46, 50 }, { 10, 18, 25, 31, 36, 40, 43, 45 } },
		weight = 4.2
	},
	{
		name = "Persian",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "440",
		yield = 148,
		movelvls = { { 11, 20, 29, 38, 46, 53, 59 }, { 10, 18, 25, 34, 42, 49, 55, 61 } },
		weight = 32.0
	},
	{
		name = "Psyduck",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "33",
		bst = "320",
		yield = 80,
		movelvls = { { 5, 10, 16, 23, 31, 40, 50 }, { 5, 10, 16, 23, 31, 40, 50 } },
		weight = 19.6
	},
	{
		name = "Golduck",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		yield = 174,
		movelvls = { { 5, 10, 16, 23, 31, 44, 58 }, { 5, 10, 16, 23, 31, 44, 58 } },
		weight = 76.6
	},
	{
		name = "Mankey",
		types = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = "28",
		bst = "305",
		yield = 74,
		movelvls = { { 9, 15, 21, 27, 33, 39, 45, 51 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 28.0
	},
	{
		name = "Primeape",
		types = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "455",
		yield = 149,
		movelvls = { { 9, 15, 21, 27, 28, 36, 45, 54, 63 }, { 6, 11, 16, 21, 26, 28, 35, 44, 53, 62 } },
		weight = 32.0
	},
	{
		name = "Growlithe",
		types = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.FIRE,
		bst = "350",
		yield = 91,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 19.0
	},
	{
		name = "Arcanine",
		types = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "555",
		yield = 213,
		movelvls = { { 49 }, { 49 } },
		weight = 155.0
	},
	{
		name = "Poliwag",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "25",
		bst = "300",
		yield = 77,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43 }, { 7, 13, 19, 25, 31, 37, 43 } },
		weight = 12.4
	},
	{
		name = "Poliwhirl",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.WATER37, -- Level 37 replaces trade evolution for Politoed
		bst = "385",
		yield = 131,
		movelvls = { { 7, 13, 19, 27, 35, 43, 51 }, { 7, 13, 19, 27, 35, 43, 51 } },
		weight = 20.0
	},
	{
		name = "Poliwrath",
		types = { PokemonData.Types.WATER, PokemonData.Types.FIGHTING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		yield = 185,
		movelvls = { { 35, 51 }, { 35, 51 } },
		weight = 54.0
	},
	{
		name = "Abra",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = "16",
		bst = "310",
		yield = 73,
		movelvls = { {}, {} },
		weight = 19.5
	},
	{
		name = "Kadabra",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = "37", -- Level 37 replaces trade evolution
		bst = "400",
		yield = 145,
		movelvls = { { 16, 18, 21, 23, 25, 30, 33, 36, 43 }, { 16, 18, 21, 23, 25, 30, 33, 36, 43 } },
		weight = 56.5
	},
	{
		name = "Alakazam",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "490",
		yield = 186,
		movelvls = { { 16, 18, 21, 23, 25, 30, 33, 36, 43 }, { 16, 18, 21, 23, 25, 30, 33, 36, 43 } },
		weight = 48.0
	},
	{
		name = "Machop",
		types = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = "28",
		bst = "305",
		yield = 88,
		movelvls = { { 7, 13, 19, 22, 25, 31, 37, 40, 43, 49 }, { 7, 13, 19, 22, 25, 31, 37, 40, 43, 49 } },
		weight = 19.5
	},
	{
		name = "Machoke",
		types = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = "37", -- Level 37 replaces trade evolution
		bst = "405",
		yield = 146,
		movelvls = { { 7, 13, 19, 22, 25, 33, 41, 46, 51, 59 }, { 7, 13, 19, 22, 25, 33, 41, 46, 51, 59 } },
		weight = 70.5
	},
	{
		name = "Machamp",
		types = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "505",
		yield = 193,
		movelvls = { { 7, 13, 19, 22, 25, 33, 41, 46, 51, 59 }, { 7, 13, 19, 22, 25, 33, 41, 46, 51, 59 } },
		weight = 130.0
	},
	{
		name = "Bellsprout",
		types = { PokemonData.Types.GRASS, PokemonData.Types.POISON },
		evolution = "21",
		bst = "300",
		yield = 84,
		movelvls = { { 6, 11, 15, 17, 19, 23, 30, 37, 45 }, { 6, 11, 15, 17, 19, 23, 30, 37, 45 } },
		weight = 4.0
	},
	{
		name = "Weepinbell",
		types = { PokemonData.Types.GRASS, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.LEAF,
		bst = "390",
		yield = 151,
		movelvls = { { 6, 11, 15, 17, 19, 24, 33, 42, 54 }, { 6, 11, 15, 17, 19, 24, 33, 42, 54 } },
		weight = 6.4
	},
	{
		name = "Victreebel",
		types = { PokemonData.Types.GRASS, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "480",
		yield = 191,
		movelvls = { {}, {} },
		weight = 15.5
	},
	{
		name = "Tentacool",
		types = { PokemonData.Types.WATER, PokemonData.Types.POISON },
		evolution = "30",
		bst = "335",
		yield = 105,
		movelvls = { { 6, 12, 19, 25, 30, 36, 43, 49 }, { 6, 12, 19, 25, 30, 36, 43, 49 } },
		weight = 45.5
	},
	{
		name = "Tentacruel",
		types = { PokemonData.Types.WATER, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "515",
		yield = 205,
		movelvls = { { 6, 12, 19, 25, 30, 38, 47, 55 }, { 6, 12, 19, 25, 30, 38, 47, 55 } },
		weight = 55.0
	},
	{
		name = "Geodude",
		types = { PokemonData.Types.ROCK, PokemonData.Types.GROUND },
		evolution = "25",
		bst = "300",
		yield = 86,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 20.0
	},
	{
		name = "Graveler",
		types = { PokemonData.Types.ROCK, PokemonData.Types.GROUND },
		evolution = "37", -- Level 37 replaces trade evolution
		bst = "390",
		yield = 134,
		movelvls = { { 6, 11, 16, 21, 29, 37, 45, 53, 62 }, { 6, 11, 16, 21, 29, 37, 45, 53, 62 } },
		weight = 105.0
	},
	{
		name = "Golem",
		types = { PokemonData.Types.ROCK, PokemonData.Types.GROUND },
		evolution = PokemonData.Evolutions.NONE,
		bst = "485",
		yield = 177,
		movelvls = { { 6, 11, 16, 21, 29, 37, 45, 53, 62 }, { 6, 11, 16, 21, 29, 37, 45, 53, 62 } },
		weight = 300.0
	},
	{
		name = "Ponyta",
		types = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = "40",
		bst = "410",
		yield = 152,
		movelvls = { { 5, 9, 14, 19, 25, 31, 38, 45, 53 }, { 5, 9, 14, 19, 25, 31, 38, 45, 53 } },
		weight = 30.0
	},
	{
		name = "Rapidash",
		types = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		yield = 192,
		movelvls = { { 5, 9, 14, 19, 25, 31, 38, 40, 50, 63 }, { 5, 9, 14, 19, 25, 31, 38, 40, 50, 63 } },
		weight = 95.0
	},
	{
		name = "Slowpoke",
		types = { PokemonData.Types.WATER, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.WATER37, -- Water stone replaces trade evolution to Slowking
		bst = "315",
		yield = 99,
		movelvls = { { 6, 15, 20, 29, 34, 43, 48 }, { 6, 13, 17, 24, 29, 36, 40, 47 } },
		weight = 36.0
	},
	{
		name = "Slowbro",
		types = { PokemonData.Types.WATER, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "490",
		yield = 164,
		movelvls = { { 6, 15, 20, 29, 34, 37, 46, 54 }, { 6, 13, 17, 24, 29, 36, 37, 44, 55 } },
		weight = 78.5
	},
	{
		name = "Magnemite",
		types = { PokemonData.Types.ELECTRIC, PokemonData.Types.STEEL },
		evolution = "30",
		bst = "325",
		yield = 89,
		movelvls = { { 6, 11, 16, 21, 26, 32, 38, 44, 50 }, { 6, 11, 16, 21, 26, 32, 38, 44, 50 } },
		weight = 6.0
	},
	{
		name = "Magneton",
		types = { PokemonData.Types.ELECTRIC, PokemonData.Types.STEEL },
		evolution = PokemonData.Evolutions.NONE,
		bst = "465",
		yield = 161,
		movelvls = { { 6, 11, 16, 21, 26, 35, 44, 53, 62 }, { 6, 11, 16, 21, 26, 35, 44, 53, 62 } },
		weight = 60.0
	},
	{
		name = "Farfetch'd",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "352",
		yield = 94,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 15.0
	},
	{
		name = "Doduo",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = "31",
		bst = "310",
		yield = 96,
		movelvls = { { 9, 13, 21, 25, 33, 37, 45 }, { 9, 13, 21, 25, 33, 37, 45 } },
		weight = 39.2
	},
	{
		name = "Dodrio",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "460",
		yield = 158,
		movelvls = { { 9, 13, 21, 25, 38, 47, 60 }, { 9, 13, 21, 25, 38, 47, 60 } },
		weight = 85.2
	},
	{
		name = "Seel",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "34",
		bst = "325",
		yield = 100,
		movelvls = { { 9, 17, 21, 29, 37, 41, 49 }, { 9, 17, 21, 29, 37, 41, 49 } },
		weight = 90.0
	},
	{
		name = "Dewgong",
		types = { PokemonData.Types.WATER, PokemonData.Types.ICE },
		evolution = PokemonData.Evolutions.NONE,
		bst = "475",
		yield = 176,
		movelvls = { { 9, 17, 21, 29, 34, 42, 51, 64 }, { 9, 17, 21, 29, 34, 42, 51, 64 } },
		weight = 120.0
	},
	{
		name = "Grimer",
		types = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = "38",
		bst = "325",
		yield = 90,
		movelvls = { { 4, 8, 13, 19, 26, 34, 43, 53 }, { 4, 8, 13, 19, 26, 34, 43, 53 } },
		weight = 30.0
	},
	{
		name = "Muk", -- PUMP SLOP
		types = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		yield = 157,
		movelvls = { { 4, 8, 13, 19, 26, 34, 47, 61 }, { 4, 8, 13, 19, 26, 34, 47, 61 } },
		weight = 30.0
	},
	{
		name = "Shellder",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.WATER,
		bst = "305",
		yield = 97,
		movelvls = { { 9, 17, 25, 33, 41, 49 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 4.0
	},
	{
		name = "Cloyster",
		types = { PokemonData.Types.WATER, PokemonData.Types.ICE },
		evolution = PokemonData.Evolutions.NONE,
		bst = "525",
		yield = 203,
		movelvls = { { 33, 41 }, { 36, 43 } },
		weight = 132.5
	},
	{
		name = "Gastly",
		types = { PokemonData.Types.GHOST, PokemonData.Types.POISON },
		evolution = "25",
		bst = "310",
		yield = 95,
		movelvls = { { 8, 13, 16, 21, 28, 33, 36 }, { 8, 13, 16, 21, 28, 33, 36, 41, 48 } },
		weight = 0.1
	},
	{
		name = "Haunter",
		types = { PokemonData.Types.GHOST, PokemonData.Types.POISON },
		evolution = "37", -- Level 37 replaces trade evolution
		bst = "405",
		yield = 126,
		movelvls = { { 8, 13, 16, 21, 25, 31, 39, 48 }, { 8, 13, 16, 21, 25, 31, 39, 45, 53, 64 } },
		weight = 0.1
	},
	{
		name = "Gengar",
		types = { PokemonData.Types.GHOST, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		yield = 190,
		movelvls = { { 8, 13, 16, 21, 25, 31, 39, 48 }, { 8, 13, 16, 21, 25, 31, 39, 45, 53, 64 } },
		weight = 40.5
	},
	{
		name = "Onix",
		types = { PokemonData.Types.ROCK, PokemonData.Types.GROUND },
		evolution = "30", -- Level 30 replaces trade evolution
		bst = "385",
		yield = 108,
		movelvls = { { 9, 13, 21, 25, 33, 37, 45, 49, 57 }, { 8, 12, 19, 23, 30, 34, 41, 45, 52, 56 } },
		weight = 210.0
	},
	{
		name = "Drowzee",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = "26",
		bst = "328",
		yield = 102,
		movelvls = { { 10, 18, 25, 31, 36, 40, 43, 45 }, { 7, 11, 17, 21, 27, 31, 37, 41, 47 } },
		weight = 32.4
	},
	{
		name = "Hypno",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "483",
		yield = 165,
		movelvls = { { 10, 18, 25, 33, 40, 49, 55, 60 }, { 7, 11, 17, 21, 29, 35, 43, 49, 57 } },
		weight = 75.6
	},
	{
		name = "Krabby",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "28",
		bst = "325",
		yield = 115,
		movelvls = { { 5, 12, 16, 23, 27, 34, 41, 45 }, { 5, 12, 16, 23, 27, 34, 38, 45, 49 } },
		weight = 6.5
	},
	{
		name = "Kingler",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "475",
		yield = 206,
		movelvls = { { 5, 12, 16, 23, 27, 38, 49, 57 }, { 5, 12, 16, 23, 27, 38, 42, 57, 65 } },
		weight = 60.0
	},
	{
		name = "Voltorb",
		types = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = "30",
		bst = "330",
		yield = 103,
		movelvls = { { 8, 15, 21, 27, 32, 37, 42, 46, 49 }, { 8, 15, 21, 27, 32, 37, 42, 46, 49 } },
		weight = 10.4
	},
	{
		name = "Electrode",
		types = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "480",
		yield = 150,
		movelvls = { { 8, 15, 21, 27, 34, 41, 48, 54, 59 }, { 8, 15, 21, 27, 34, 41, 48, 54, 59 } },
		weight = 66.6
	},
	{
		name = "Exeggcute",
		types = { PokemonData.Types.GRASS, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.LEAF,
		bst = "325",
		yield = 98,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43 }, { 7, 13, 19, 25, 31, 37, 43 } },
		weight = 2.5
	},
	{
		name = "Exeggutor",
		types = { PokemonData.Types.GRASS, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "520",
		yield = 212,
		movelvls = { { 19, 31 }, { 19, 31 } },
		weight = 120.0
	},
	{
		name = "Cubone",
		types = { PokemonData.Types.GROUND, PokemonData.Types.EMPTY },
		evolution = "28",
		bst = "320",
		yield = 87,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 } },
		weight = 6.5
	},
	{
		name = "Marowak",
		types = { PokemonData.Types.GROUND, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "425",
		yield = 124,
		movelvls = { { 5, 9, 13, 17, 21, 25, 32, 39, 46, 53, 61 }, { 5, 9, 13, 17, 21, 25, 32, 39, 46, 53, 61 } },
		weight = 45.0
	},
	{
		name = "Hitmonlee",
		types = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "455",
		yield = 139,
		movelvls = { { 6, 11, 16, 20, 21, 26, 31, 36, 41, 46, 51 }, { 6, 11, 16, 20, 21, 26, 31, 36, 41, 46, 51 } },
		weight = 49.8
	},
	{
		name = "Hitmonchan",
		types = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "455",
		yield = 140,
		movelvls = { { 7, 13, 20, 26, 26, 26, 32, 38, 44, 50 }, { 7, 13, 20, 26, 26, 26, 32, 38, 44, 50 } },
		weight = 50.2
	},
	{
		name = "Lickitung",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "385",
		yield = 127,
		movelvls = { { 7, 12, 18, 23, 29, 34, 40, 45, 51 }, { 7, 12, 18, 23, 29, 34, 40, 45, 51 } },
		weight = 65.5
	},
	{
		name = "Koffing",
		types = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = "35",
		bst = "340",
		yield = 114,
		movelvls = { { 9, 17, 21, 25, 33, 41, 45, 49 }, { 9, 17, 21, 25, 33, 41, 45, 49 } },
		weight = 1.0
	},
	{
		name = "Weezing",
		types = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "490",
		yield = 173,
		movelvls = { { 9, 17, 21, 25, 33, 44, 51, 58 }, { 9, 17, 21, 25, 33, 44, 51, 58 } },
		weight = 9.5
	},
	{
		name = "Rhyhorn",
		types = { PokemonData.Types.GROUND, PokemonData.Types.ROCK },
		evolution = "42",
		bst = "345",
		yield = 135,
		movelvls = { { 10, 15, 24, 29, 38, 43, 52, 57 }, { 10, 15, 24, 29, 38, 43, 52, 57 } },
		weight = 115.0
	},
	{
		name = "Rhydon",
		types = { PokemonData.Types.GROUND, PokemonData.Types.ROCK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "485",
		yield = 204,
		movelvls = { { 10, 15, 24, 29, 38, 46, 58, 66 }, { 10, 15, 24, 29, 38, 46, 58, 66 } },
		weight = 120.0
	},
	{
		name = "Chansey",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.FRIEND,
		bst = "450",
		yield = 255,
		movelvls = { { 5, 9, 13, 17, 23, 29, 35, 41, 49, 57 }, { 5, 9, 13, 17, 23, 29, 35, 41, 49, 57 } },
		weight = 34.6,
		friendshipBase = 140
	},
	{
		name = "Tangela",
		types = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "435",
		yield = 166,
		movelvls = { { 4, 10, 13, 19, 22, 28, 31, 37, 40, 46 }, { 4, 10, 13, 19, 22, 28, 31, 37, 40, 46 } },
		weight = 35.0
	},
	{
		name = "Kangaskhan",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "490",
		yield = 175,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 80.0
	},
	{
		name = "Horsea",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "32",
		bst = "295",
		yield = 83,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 8.0
	},
	{
		name = "Seadra",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "40", -- Level 40 replaces trade evolution
		bst = "440",
		yield = 155,
		movelvls = { { 8, 15, 22, 29, 40, 51, 62 }, { 8, 15, 22, 29, 40, 51, 62 } },
		weight = 25.0
	},
	{
		name = "Goldeen",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "33",
		bst = "320",
		yield = 111,
		movelvls = { { 10, 15, 24, 29, 38, 43, 52 }, { 10, 15, 24, 29, 38, 43, 52, 57 } },
		weight = 15.0
	},
	{
		name = "Seaking",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "450",
		yield = 170,
		movelvls = { { 10, 15, 24, 29, 41, 49, 61 }, { 10, 15, 24, 29, 41, 49, 61, 69 } },
		weight = 39.0
	},
	{
		name = "Staryu",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.WATER,
		bst = "340",
		yield = 106,
		movelvls = { { 6, 10, 15, 19, 24, 28, 33, 37, 42, 46 }, { 6, 10, 15, 19, 24, 28, 33, 37, 42, 46 } },
		weight = 34.5
	},
	{
		name = "Starmie",
		types = { PokemonData.Types.WATER, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "520",
		yield = 207,
		movelvls = { { 33 }, { 33 } },
		weight = 80.0
	},
	{
		name = "Mr. Mime",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "460",
		yield = 136,
		movelvls = { { 5, 9, 13, 17, 21, 21, 25, 29, 33, 37, 41, 45, 49, 53 }, { 5, 8, 12, 15, 19, 19, 22, 26, 29, 33, 36, 40, 43, 47, 50 } },
		weight = 54.5
	},
	{
		name = "Scyther",
		types = { PokemonData.Types.BUG, PokemonData.Types.FLYING },
		evolution = "30", -- Level 30 replaces trade evolution
		bst = "500",
		yield = 187,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 56.0
	},
	{
		name = "Jynx",
		types = { PokemonData.Types.ICE, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "455",
		yield = 137,
		movelvls = { { 9, 13, 21, 25, 35, 41, 51, 57, 67 }, { 9, 13, 21, 25, 35, 41, 51, 57, 67 } },
		weight = 40.6
	},
	{
		name = "Electabuzz",
		types = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "490",
		yield = 156,
		movelvls = { { 9, 17, 25, 36, 47, 58 }, { 9, 17, 25, 36, 47, 58 } },
		weight = 30.0
	},
	{
		name = "Magmar", -- MAMGAR
		types = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "495",
		yield = 167,
		movelvls = { { 7, 13, 19, 25, 33, 41, 49, 57 }, { 7, 13, 19, 25, 33, 41, 49, 57 } },
		weight = 44.5
	},
	{
		name = "Pinsir",
		types = { PokemonData.Types.BUG, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		yield = 200,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 55.0
	},
	{
		name = "Tauros",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "490",
		yield = 211,
		movelvls = { { 4, 8, 13, 19, 26, 34, 43, 53 }, { 4, 8, 13, 19, 26, 34, 43, 53 } },
		weight = 88.4
	},
	{
		name = "Magikarp",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "20",
		bst = "200",
		yield = 20,
		movelvls = { { 15, 30 }, { 15, 30 } },
		weight = 10.0
	},
	{
		name = "Gyarados",
		types = { PokemonData.Types.WATER, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "540",
		yield = 214,
		movelvls = { { 20, 25, 30, 35, 40, 45, 50, 55 }, { 20, 25, 30, 35, 40, 45, 50, 55 } },
		weight = 235.0
	},
	{
		name = "Lapras",
		types = { PokemonData.Types.WATER, PokemonData.Types.ICE },
		evolution = PokemonData.Evolutions.NONE,
		bst = "535",
		yield = 219,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49, 55 }, { 7, 13, 19, 25, 31, 37, 43, 49, 55 } },
		weight = 220.0
	},
	{
		name = "Ditto",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "288",
		yield = 61,
		movelvls = { {}, {} },
		weight = 4.0
	},
	{
		name = "Eevee",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.EEVEE_STONES,
		bst = "325",
		yield = 92,
		movelvls = { { 8, 16, 23, 30, 36, 42 }, { 8, 16, 23, 30, 36, 42 } },
		weight = 6.5
	},
	{
		name = "Vaporeon",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "525",
		yield = 196,
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = 29.0
	},
	{
		name = "Jolteon",
		types = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "525",
		yield = 197,
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = 24.5
	},
	{
		name = "Flareon",
		types = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "525",
		yield = 198,
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = 25.0
	},
	{
		name = "Porygon",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "30", -- Level 30 replaces trade evolution
		bst = "395",
		yield = 130,
		movelvls = { { 9, 12, 20, 24, 32, 36, 44, 48 }, { 9, 12, 20, 24, 32, 36, 44, 48 } },
		weight = 36.5
	},
	{
		name = "Omanyte",
		types = { PokemonData.Types.ROCK, PokemonData.Types.WATER },
		evolution = "40",
		bst = "355",
		yield = 120,
		movelvls = { { 13, 19, 25, 31, 37, 43, 49, 55 }, { 13, 19, 25, 31, 37, 43, 49, 55 } },
		weight = 7.5
	},
	{
		name = "Omastar", -- LORD HELIX
		types = { PokemonData.Types.ROCK, PokemonData.Types.WATER },
		evolution = PokemonData.Evolutions.NONE,
		bst = "495",
		yield = 199,
		movelvls = { { 13, 19, 25, 31, 37, 40, 46, 55, 65 }, { 13, 19, 25, 31, 37, 40, 46, 55, 65 } },
		weight = 35.0
	},
	{
		name = "Kabuto",
		types = { PokemonData.Types.ROCK, PokemonData.Types.WATER },
		evolution = "40",
		bst = "355",
		yield = 119,
		movelvls = { { 13, 19, 25, 31, 37, 43, 49, 55 }, { 13, 19, 25, 31, 37, 43, 49, 55 } },
		weight = 11.5
	},
	{
		name = "Kabutops",
		types = { PokemonData.Types.ROCK, PokemonData.Types.WATER },
		evolution = PokemonData.Evolutions.NONE,
		bst = "495",
		yield = 201,
		movelvls = { { 13, 19, 25, 31, 37, 40, 46, 55, 65 }, { 13, 19, 25, 31, 37, 40, 46, 55, 65 } },
		weight = 40.5
	},
	{
		name = "Aerodactyl",
		types = { PokemonData.Types.ROCK, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "515",
		yield = 202,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 59.0
	},
	{
		name = "Snorlax",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "540",
		yield = 154,
		movelvls = { { 6, 10, 15, 19, 24, 28, 28, 33, 37, 42, 46, 51 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, 53 } },
		weight = 460.0
	},
	{
		name = "Articuno",
		types = { PokemonData.Types.ICE, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "580",
		yield = 215,
		movelvls = { { 13, 25, 37, 49, 61, 73, 85 }, { 13, 25, 37, 49, 61, 73, 85 } },
		weight = 55.4,
		friendshipBase = 35
	},
	{
		name = "Zapdos",
		types = { PokemonData.Types.ELECTRIC, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "580",
		yield = 216,
		movelvls = { { 13, 25, 37, 49, 61, 73, 85 }, { 13, 25, 37, 49, 61, 73, 85 } },
		weight = 52.6,
		friendshipBase = 35
	},
	{
		name = "Moltres",
		types = { PokemonData.Types.FIRE, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "580",
		yield = 217,
		movelvls = { { 13, 25, 37, 49, 61, 73, 85 }, { 13, 25, 37, 49, 61, 73, 85 } },
		weight = 60.0,
		friendshipBase = 35
	},
	{
		name = "Dratini",
		types = { PokemonData.Types.DRAGON, PokemonData.Types.EMPTY },
		evolution = "30",
		bst = "300",
		yield = 67,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 57 }, { 8, 15, 22, 29, 36, 43, 50, 57 } },
		weight = 3.3,
		friendshipBase = 35
	},
	{
		name = "Dragonair",
		types = { PokemonData.Types.DRAGON, PokemonData.Types.EMPTY },
		evolution = "55",
		bst = "420",
		yield = 144,
		movelvls = { { 8, 15, 22, 29, 38, 47, 56, 65 }, { 8, 15, 22, 29, 38, 47, 56, 65 } },
		weight = 16.5,
		friendshipBase = 35
	},
	{
		name = "Dragonite",
		types = { PokemonData.Types.DRAGON, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "600",
		yield = 218,
		movelvls = { { 8, 15, 22, 29, 38, 47, 55, 61, 75 }, { 8, 15, 22, 29, 38, 47, 55, 61, 75 } },
		weight = 210.0,
		friendshipBase = 35
	},
	{
		name = "Mewtwo",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "680",
		yield = 220,
		movelvls = { { 11, 22, 33, 44, 55, 66, 77, 88, 99 }, { 11, 22, 33, 44, 55, 66, 77, 88, 99 } },
		weight = 122.0,
		friendshipBase = 0
	},
	{
		name = "Mew",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "600",
		yield = 64,
		movelvls = { { 10, 20, 30, 40, 50 }, { 10, 20, 30, 40, 50 } },
		weight = 4.0,
		friendshipBase = 100
	},
	{
		name = "Chikorita",
		types = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = "16",
		bst = "318",
		yield = 64,
		movelvls = { { 8, 12, 15, 22, 29, 36, 43, 50 }, { 8, 12, 15, 22, 29, 36, 43, 50 } },
		weight = 6.4
	},
	{
		name = "Bayleef",
		types = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = "32",
		bst = "405",
		yield = 141,
		movelvls = { { 8, 12, 15, 23, 31, 39, 47, 55 }, { 8, 12, 15, 23, 31, 39, 47, 55 } },
		weight = 15.8
	},
	{
		name = "Meganium",
		types = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "525",
		yield = 208,
		movelvls = { { 8, 12, 15, 23, 31, 41, 51, 61 }, { 8, 12, 15, 23, 31, 41, 51, 61 } },
		weight = 100.5
	},
	{
		name = "Cyndaquil",
		types = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = "14",
		bst = "309",
		yield = 65,
		movelvls = { { 6, 12, 19, 27, 36, 46 }, { 6, 12, 19, 27, 36, 46 } },
		weight = 7.9
	},
	{
		name = "Quilava",
		types = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = "36",
		bst = "405",
		yield = 142,
		movelvls = { { 6, 12, 21, 31, 42, 54 }, { 6, 12, 21, 31, 42, 54 } },
		weight = 19.0
	},
	{
		name = "Typhlosion",
		types = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "534",
		yield = 209,
		movelvls = { { 6, 12, 21, 31, 45, 60 }, { 6, 12, 21, 31, 45, 60 } },
		weight = 79.5
	},
	{
		name = "Totodile",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "18",
		bst = "314",
		yield = 66,
		movelvls = { { 7, 13, 20, 27, 35, 43, 52 }, { 7, 13, 20, 27, 35, 43, 52 } },
		weight = 9.5
	},
	{
		name = "Croconaw",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "30",
		bst = "405",
		yield = 143,
		movelvls = { { 7, 13, 21, 28, 37, 45, 55 }, { 7, 13, 21, 28, 37, 45, 55 } },
		weight = 25.0
	},
	{
		name = "Feraligatr",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "530",
		yield = 210,
		movelvls = { { 7, 13, 21, 28, 38, 47, 58 }, { 7, 13, 21, 28, 38, 47, 58 } },
		weight = 88.8
	},
	{
		name = "Sentret",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "15",
		bst = "215",
		yield = 57,
		movelvls = { { 4, 7, 12, 17, 24, 31, 40, 49 }, { 4, 7, 12, 17, 24, 31, 40, 49 } },
		weight = 6.0
	},
	{
		name = "Furret",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "415",
		yield = 116,
		movelvls = { { 4, 7, 12, 19, 28, 37, 48, 59 }, { 4, 7, 12, 19, 28, 37, 48, 59 } },
		weight = 32.5
	},
	{
		name = "Hoothoot",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = "20",
		bst = "262",
		yield = 58,
		movelvls = { { 6, 11, 16, 22, 28, 34, 48 }, { 6, 11, 16, 22, 28, 34, 48 } },
		weight = 21.2
	},
	{
		name = "Noctowl",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "442",
		yield = 162,
		movelvls = { { 6, 11, 16, 25, 33, 41, 57 }, { 6, 11, 16, 25, 33, 41, 57 } },
		weight = 40.8
	},
	{
		name = "Ledyba",
		types = { PokemonData.Types.BUG, PokemonData.Types.FLYING },
		evolution = "18",
		bst = "265",
		yield = 54,
		movelvls = { { 8, 15, 22, 22, 22, 29, 36, 43, 50 }, { 8, 15, 22, 22, 22, 29, 36, 43, 50 } },
		weight = 10.8
	},
	{
		name = "Ledian",
		types = { PokemonData.Types.BUG, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "390",
		yield = 134,
		movelvls = { { 8, 15, 24, 24, 24, 33, 42, 51, 60 }, { 8, 15, 24, 24, 24, 33, 42, 51, 60 } },
		weight = 35.6
	},
	{
		name = "Spinarak",
		types = { PokemonData.Types.BUG, PokemonData.Types.POISON },
		evolution = "22",
		bst = "250",
		yield = 54,
		movelvls = { { 6, 11, 17, 23, 30, 37, 45, 53 }, { 6, 11, 17, 23, 30, 37, 45, 53 } },
		weight = 8.5
	},
	{
		name = "Ariados",
		types = { PokemonData.Types.BUG, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "390",
		yield = 134,
		movelvls = { { 6, 11, 17, 25, 34, 43, 53, 63 }, { 6, 11, 17, 25, 34, 43, 53, 63 } },
		weight = 33.5
	},
	{
		name = "Crobat",
		types = { PokemonData.Types.POISON, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "535",
		yield = 204,
		movelvls = { { 6, 11, 16, 21, 28, 35, 42, 49, 56 }, { 6, 11, 16, 21, 28, 35, 42, 49, 56 } },
		weight = 75.0
	},
	{
		name = "Chinchou",
		types = { PokemonData.Types.WATER, PokemonData.Types.ELECTRIC },
		evolution = "27",
		bst = "330",
		yield = 90,
		movelvls = { { 5, 13, 17, 25, 29, 37, 41, 49 }, { 5, 13, 17, 25, 29, 37, 41, 49 } },
		weight = 12.0
	},
	{
		name = "Lanturn",
		types = { PokemonData.Types.WATER, PokemonData.Types.ELECTRIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "460",
		yield = 156,
		movelvls = { { 5, 13, 17, 25, 32, 43, 50, 61 }, { 5, 13, 17, 25, 32, 43, 50, 61 } },
		weight = 22.5
	},
	{
		name = "Pichu",
		types = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.FRIEND,
		bst = "205",
		yield = 42,
		movelvls = { { 6, 8, 11 }, { 6, 8, 11 } },
		weight = 2.0
	},
	{
		name = "Cleffa",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.FRIEND,
		bst = "218",
		yield = 37,
		movelvls = { { 4, 8, 13 }, { 4, 8, 13, 17 } },
		weight = 3.0,
		friendshipBase = 140
	},
	{
		name = "Igglybuff",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.FRIEND,
		bst = "210",
		yield = 39,
		movelvls = { { 4, 9, 14 }, { 4, 9, 14 } },
		weight = 1.0
	},
	{
		name = "Togepi",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.FRIEND,
		bst = "245",
		yield = 74,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41 }, { 4, 9, 13, 17, 21, 25, 29, 33, 37, 41 } },
		weight = 1.5
	},
	{
		name = "Togetic",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "405",
		yield = 114,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41 }, { 4, 9, 13, 17, 21, 25, 29, 33, 37, 41 } },
		weight = 3.2
	},
	{
		name = "Natu",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.FLYING },
		evolution = "25",
		bst = "320",
		yield = 73,
		movelvls = { { 10, 20, 30, 30, 40, 50 }, { 10, 20, 30, 30, 40, 50 } },
		weight = 2.0
	},
	{
		name = "Xatu",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "470",
		yield = 171,
		movelvls = { { 10, 20, 35, 35, 50, 65 }, { 10, 20, 35, 35, 50, 65 } },
		weight = 15.0
	},
	{
		name = "Mareep",
		types = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = "15",
		bst = "280",
		yield = 59,
		movelvls = { { 9, 16, 23, 30, 37 }, { 9, 16, 23, 30, 37 } },
		weight = 7.8
	},
	{
		name = "Flaaffy",
		types = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = "30",
		bst = "365",
		yield = 117,
		movelvls = { { 9, 18, 27, 36, 45 }, { 9, 18, 27, 36, 45 } },
		weight = 13.3
	},
	{
		name = "Ampharos",
		types = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		yield = 194,
		movelvls = { { 9, 18, 27, 30, 42, 57 }, { 9, 18, 27, 30, 42, 57 } },
		weight = 61.5
	},
	{
		name = "Bellossom",
		types = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "480",
		yield = 184,
		movelvls = { { 44, 55 }, { 44, 55 } },
		weight = 5.8
	},
	{
		name = "Marill",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "18",
		bst = "250",
		yield = 58,
		movelvls = { { 3, 6, 10, 15, 21, 28, 36, 45 }, { 3, 6, 10, 15, 21, 28, 36, 45 } },
		weight = 8.5
	},
	{
		name = "Azumarill",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "410",
		yield = 153,
		movelvls = { { 3, 6, 10, 15, 24, 34, 45, 57 }, { 3, 6, 10, 15, 24, 34, 45, 57 } },
		weight = 28.5
	},
	{
		name = "Sudowoodo",
		types = { PokemonData.Types.ROCK, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "410",
		yield = 135,
		movelvls = { { 9, 17, 25, 33, 41, 49, 57 }, { 9, 17, 25, 33, 41, 49, 57 } },
		weight = 38.0
	},
	{
		name = "Politoed",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		yield = 185,
		movelvls = { { 35, 51 }, { 35, 51 } },
		weight = 33.9
	},
	{
		name = "Hoppip",
		types = { PokemonData.Types.GRASS, PokemonData.Types.FLYING },
		evolution = "18",
		bst = "250",
		yield = 74,
		movelvls = { { 5, 5, 10, 13, 15, 17, 20, 25, 30 }, { 5, 5, 10, 13, 15, 17, 20, 25, 30 } },
		weight = 0.5
	},
	{
		name = "Skiploom",
		types = { PokemonData.Types.GRASS, PokemonData.Types.FLYING },
		evolution = "27",
		bst = "340",
		yield = 136,
		movelvls = { { 5, 5, 10, 13, 15, 17, 22, 29, 36 }, { 5, 5, 10, 13, 15, 17, 22, 29, 36 } },
		weight = 1.0
	},
	{
		name = "Jumpluff",
		types = { PokemonData.Types.GRASS, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "450",
		yield = 176,
		movelvls = { { 5, 5, 10, 13, 15, 17, 22, 33, 44 }, { 5, 5, 10, 13, 15, 17, 22, 33, 44 } },
		weight = 3.0
	},
	{
		name = "Aipom",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "360",
		yield = 94,
		movelvls = { { 6, 13, 18, 25, 31, 38, 43, 50 }, { 6, 13, 18, 25, 31, 38, 43, 50 } },
		weight = 11.5
	},
	{
		name = "Sunkern",
		types = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.SUN,
		bst = "180",
		yield = 52,
		movelvls = { { 6, 13, 18, 25, 30, 37, 42 }, { 6, 13, 18, 25, 30, 37, 42 } },
		weight = 1.8
	},
	{
		name = "Sunflora",
		types = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "425",
		yield = 146,
		movelvls = { { 6, 13, 18, 25, 30, 37, 42 }, { 6, 13, 18, 25, 30, 37, 42 } },
		weight = 8.5
	},
	{
		name = "Yanma",
		types = { PokemonData.Types.BUG, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "390",
		yield = 147,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 6, 12, 17, 23, 28, 34, 39, 45, 50 } },
		weight = 38.0
	},
	{
		name = "Wooper",
		types = { PokemonData.Types.WATER, PokemonData.Types.GROUND },
		evolution = "20",
		bst = "210",
		yield = 52,
		movelvls = { { 11, 16, 21, 31, 36, 41, 51, 51 }, { 11, 16, 21, 31, 36, 41, 51, 51 } },
		weight = 8.5
	},
	{
		name = "Quagsire",
		types = { PokemonData.Types.WATER, PokemonData.Types.GROUND },
		evolution = PokemonData.Evolutions.NONE,
		bst = "430",
		yield = 137,
		movelvls = { { 11, 16, 23, 35, 42, 49, 61, 61 }, { 11, 16, 23, 35, 42, 49, 61, 61 } },
		weight = 75.0
	},
	{
		name = "Espeon",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "525",
		yield = 197,
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = 26.5
	},
	{
		name = "Umbreon",
		types = { PokemonData.Types.DARK, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "525",
		yield = 197,
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = 27.0,
		friendshipBase = 35
	},
	{
		name = "Murkrow",
		types = { PokemonData.Types.DARK, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "405",
		yield = 107,
		movelvls = { { 9, 14, 22, 27, 35, 40, 48 }, { 9, 14, 22, 27, 35, 40, 48 } },
		weight = 2.1,
		friendshipBase = 35
	},
	{
		name = "Slowking",
		types = { PokemonData.Types.WATER, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "490",
		yield = 164,
		movelvls = { { 6, 15, 20, 29, 34, 43, 48 }, { 6, 13, 17, 24, 29, 36, 40, 47 } },
		weight = 79.5
	},
	{
		name = "Misdreavus",
		types = { PokemonData.Types.GHOST, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "435",
		yield = 147,
		movelvls = { { 6, 11, 17, 23, 30, 37, 45, 53 }, { 6, 11, 17, 23, 30, 37, 45, 53 } },
		weight = 1.0,
		friendshipBase = 35
	},
	{
		name = "Unown",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "336",
		yield = 61,
		movelvls = { {}, {} },
		weight = 5.0
	},
	{
		name = "Wobbuffet",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "405",
		yield = 177,
		movelvls = { {}, {} },
		weight = 28.5
	},
	{
		name = "Girafarig",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "455",
		yield = 149,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 41.5
	},
	{
		name = "Pineco",
		types = { PokemonData.Types.BUG, PokemonData.Types.EMPTY },
		evolution = "31",
		bst = "290",
		yield = 60,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 7.2
	},
	{
		name = "Forretress",
		types = { PokemonData.Types.BUG, PokemonData.Types.STEEL },
		evolution = PokemonData.Evolutions.NONE,
		bst = "465",
		yield = 118,
		movelvls = { { 8, 15, 22, 29, 39, 49, 59 }, { 8, 15, 22, 29, 31, 39, 49, 59 } },
		weight = 125.8
	},
	{
		name = "Dunsparce",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "415",
		yield = 75,
		movelvls = { { 4, 11, 14, 21, 24, 31, 34, 41 }, { 4, 11, 14, 21, 24, 31, 34, 41, 44, 51 } },
		weight = 14.0
	},
	{
		name = "Gligar",
		types = { PokemonData.Types.GROUND, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "430",
		yield = 108,
		movelvls = { { 6, 13, 20, 28, 36, 44, 52 }, { 6, 13, 20, 28, 36, 44, 52 } },
		weight = 64.8
	},
	{
		name = "Steelix",
		types = { PokemonData.Types.STEEL, PokemonData.Types.GROUND },
		evolution = PokemonData.Evolutions.NONE,
		bst = "510",
		yield = 196,
		movelvls = { { 9, 13, 21, 25, 33, 37, 45, 49, 57 }, { 8, 12, 19, 23, 30, 34, 41, 45, 52, 56 } },
		weight = 400.0
	},
	{
		name = "Snubbull",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "23",
		bst = "300",
		yield = 63,
		movelvls = { { 4, 8, 13, 19, 26, 34, 43, 53 }, { 4, 8, 13, 19, 26, 34, 43, 53 } },
		weight = 7.8
	},
	{
		name = "Granbull",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "450",
		yield = 178,
		movelvls = { { 4, 8, 13, 19, 28, 38, 49, 61 }, { 4, 8, 13, 19, 28, 38, 49, 61 } },
		weight = 48.7
	},
	{
		name = "Qwilfish",
		types = { PokemonData.Types.WATER, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "430",
		yield = 100,
		movelvls = { { 10, 10, 19, 28, 37, 46 }, { 9, 9, 13, 21, 25, 33, 37, 45 } },
		weight = 3.9
	},
	{
		name = "Scizor",
		types = { PokemonData.Types.BUG, PokemonData.Types.STEEL },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		yield = 200,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 118.0
	},
	{
		name = "Shuckle",
		types = { PokemonData.Types.BUG, PokemonData.Types.ROCK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "505",
		yield = 80,
		movelvls = { { 9, 14, 23, 28, 37 }, { 9, 14, 23, 28, 37 } },
		weight = 20.5
	},
	{
		name = "Heracross",
		types = { PokemonData.Types.BUG, PokemonData.Types.FIGHTING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		yield = 200,
		movelvls = { { 6, 11, 17, 23, 30, 37, 45, 53 }, { 6, 11, 17, 23, 30, 37, 45, 53 } },
		weight = 54.0
	},
	{
		name = "Sneasel",
		types = { PokemonData.Types.DARK, PokemonData.Types.ICE },
		evolution = PokemonData.Evolutions.NONE,
		bst = "430",
		yield = 132,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 57, 64 }, { 8, 15, 22, 29, 36, 43, 50, 57, 64 } },
		weight = 28.0,
		friendshipBase = 35
	},
	{
		name = "Teddiursa",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "30",
		bst = "330",
		yield = 124,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 8.8
	},
	{
		name = "Ursaring",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		yield = 189,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 125.8
	},
	{
		name = "Slugma",
		types = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = "38",
		bst = "250",
		yield = 78,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 35.0
	},
	{
		name = "Magcargo",
		types = { PokemonData.Types.FIRE, PokemonData.Types.ROCK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "410",
		yield = 154,
		movelvls = { { 8, 15, 22, 29, 36, 48, 60 }, { 8, 15, 22, 29, 36, 48, 60 } },
		weight = 55.0
	},
	{
		name = "Swinub",
		types = { PokemonData.Types.ICE, PokemonData.Types.GROUND },
		evolution = "33",
		bst = "250",
		yield = 78,
		movelvls = { { 10, 19, 28, 37, 46, 55 }, { 10, 19, 28, 37, 46, 55 } },
		weight = 6.5
	},
	{
		name = "Piloswine",
		types = { PokemonData.Types.ICE, PokemonData.Types.GROUND },
		evolution = PokemonData.Evolutions.NONE,
		bst = "450",
		yield = 160,
		movelvls = { { 10, 19, 28, 33, 42, 56, 70 }, { 10, 19, 28, 33, 42, 56, 70 } },
		weight = 55.8
	},
	{
		name = "Corsola",
		types = { PokemonData.Types.WATER, PokemonData.Types.ROCK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "380",
		yield = 113,
		movelvls = { { 6, 12, 17, 17, 23, 28, 34, 39, 45 }, { 6, 12, 17, 17, 23, 28, 34, 39, 45 } },
		weight = 5.0
	},
	{
		name = "Remoraid",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "25",
		bst = "300",
		yield = 78,
		movelvls = { { 11, 22, 22, 22, 33, 44, 55 }, { 11, 22, 22, 22, 33, 44, 55 } },
		weight = 12.0
	},
	{
		name = "Octillery",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "480",
		yield = 164,
		movelvls = { { 11, 22, 22, 22, 25, 38, 54, 70 }, { 11, 22, 22, 22, 25, 38, 54, 70 } },
		weight = 28.5
	},
	{
		name = "Delibird",
		types = { PokemonData.Types.ICE, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "330",
		yield = 183,
		movelvls = { {}, {} },
		weight = 16.0
	},
	{
		name = "Mantine",
		types = { PokemonData.Types.WATER, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "465",
		yield = 168,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 220.0
	},
	{
		name = "Skarmory",
		types = { PokemonData.Types.STEEL, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "465",
		yield = 168,
		movelvls = { { 10, 13, 16, 26, 29, 32, 42, 45 }, { 10, 13, 16, 26, 29, 32, 42, 45 } },
		weight = 50.5
	},
	{
		name = "Houndour",
		types = { PokemonData.Types.DARK, PokemonData.Types.FIRE },
		evolution = "24",
		bst = "330",
		yield = 114,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 10.8,
		friendshipBase = 35
	},
	{
		name = "Houndoom",
		types = { PokemonData.Types.DARK, PokemonData.Types.FIRE },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		yield = 204,
		movelvls = { { 7, 13, 19, 27, 35, 43, 51, 59 }, { 7, 13, 19, 27, 35, 43, 51, 59 } },
		weight = 35.0,
		friendshipBase = 35
	},
	{
		name = "Kingdra",
		types = { PokemonData.Types.WATER, PokemonData.Types.DRAGON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "540",
		yield = 207,
		movelvls = { { 8, 15, 22, 29, 40, 51, 62 }, { 8, 15, 22, 29, 40, 51, 62 } },
		weight = 152.0
	},
	{
		name = "Phanpy",
		types = { PokemonData.Types.GROUND, PokemonData.Types.EMPTY },
		evolution = "25",
		bst = "330",
		yield = 124,
		movelvls = { { 9, 17, 25, 33, 41, 49 }, { 9, 17, 25, 33, 41, 49 } },
		weight = 33.5
	},
	{
		name = "Donphan",
		types = { PokemonData.Types.GROUND, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		yield = 189,
		movelvls = { { 9, 17, 25, 33, 41, 49 }, { 9, 17, 25, 33, 41, 49 } },
		weight = 120.0
	},
	{
		name = "Porygon2",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "515",
		yield = 1302,
		movelvls = { { 9, 12, 20, 24, 32, 36, 44, 48 }, { 9, 12, 20, 24, 32, 36, 44, 48 } },
		weight = 32.5
	},
	{
		name = "Stantler",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "465",
		yield = 165,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 11, 17, 21, 27, 31, 37, 41, 47 } },
		weight = 71.2
	},
	{
		name = "Smeargle",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "250",
		yield = 106,
		movelvls = { { 11, 21, 31, 41, 51, 61, 71, 81, 91 }, { 11, 21, 31, 41, 51, 61, 71, 81, 91 } },
		weight = 58.0
	},
	{
		name = "Tyrogue",
		types = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = "20",
		bst = "210",
		yield = 91,
		movelvls = { {}, {} },
		weight = 21.0
	},
	{
		name = "Hitmontop",
		types = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "455",
		yield = 138,
		movelvls = { { 7, 13, 19, 20, 25, 31, 37, 43, 49 }, { 7, 13, 19, 20, 25, 31, 37, 43, 49 } },
		weight = 48.0
	},
	{
		name = "Smoochum",
		types = { PokemonData.Types.ICE, PokemonData.Types.PSYCHIC },
		evolution = "30",
		bst = "305",
		yield = 87,
		movelvls = { { 9, 13, 21, 25, 33, 37, 45, 49, 57 }, { 9, 13, 21, 25, 33, 37, 45, 49, 57 } },
		weight = 6.0
	},
	{
		name = "Elekid",
		types = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = "30",
		bst = "360",
		yield = 106,
		movelvls = { { 9, 17, 25, 33, 41, 49 }, { 9, 17, 25, 33, 41, 49 } },
		weight = 23.5
	},
	{
		name = "Magby",
		types = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = "30",
		bst = "365",
		yield = 117,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 21.4
	},
	{
		name = "Miltank",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "490",
		yield = 200,
		movelvls = { { 4, 8, 13, 19, 26, 34, 43, 53 }, { 4, 8, 13, 19, 26, 34, 43, 53 } },
		weight = 75.5
	},
	{
		name = "Blissey",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "540",
		yield = 255,
		movelvls = { { 4, 7, 10, 13, 18, 23, 28, 33, 40, 47 }, { 4, 7, 10, 13, 18, 23, 28, 33, 40, 47 } },
		weight = 46.8,
		friendshipBase = 140
	},
	{
		name = "Raikou",
		types = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "580",
		yield = 216,
		movelvls = { { 11, 21, 31, 41, 51, 61, 71, 81 }, { 11, 21, 31, 41, 51, 61, 71, 81 } },
		weight = 178.0,
		friendshipBase = 35
	},
	{
		name = "Entei",
		types = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "580",
		yield = 217,
		movelvls = { { 11, 21, 31, 41, 51, 61, 71, 81 }, { 11, 21, 31, 41, 51, 61, 71, 81 } },
		weight = 198.0,
		friendshipBase = 35
	},
	{
		name = "Suicune",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "580",
		yield = 215,
		movelvls = { { 11, 21, 31, 41, 51, 61, 71, 81 }, { 11, 21, 31, 41, 51, 61, 71, 81 } },
		weight = 187.0,
		friendshipBase = 35
	},
	{
		name = "Larvitar",
		types = { PokemonData.Types.ROCK, PokemonData.Types.GROUND },
		evolution = "30",
		bst = "300",
		yield = 67,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 57 }, { 8, 15, 22, 29, 36, 43, 50, 57 } },
		weight = 72.0,
		friendshipBase = 35
	},
	{
		name = "Pupitar",
		types = { PokemonData.Types.ROCK, PokemonData.Types.GROUND },
		evolution = "55",
		bst = "410",
		yield = 144,
		movelvls = { { 8, 15, 22, 29, 38, 47, 56, 65 }, { 8, 15, 22, 29, 38, 47, 56, 65 } },
		weight = 152.0,
		friendshipBase = 35
	},
	{
		name = "Tyranitar",
		types = { PokemonData.Types.ROCK, PokemonData.Types.DARK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "600",
		yield = 218,
		movelvls = { { 8, 15, 22, 29, 38, 47, 61, 75 }, { 8, 15, 22, 29, 38, 47, 61, 75 } },
		weight = 202.0,
		friendshipBase = 35
	},
	{
		name = "Lugia",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "680",
		yield = 220,
		movelvls = { { 11, 22, 33, 44, 55, 66, 77, 88, 99 }, { 11, 22, 33, 44, 55, 66, 77, 88, 99 } },
		weight = 216.0,
		friendshipBase = 0
	},
	{
		name = "Ho-Oh",
		types = { PokemonData.Types.FIRE, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "680",
		yield = 220,
		movelvls = { { 11, 22, 33, 44, 55, 66, 77, 88, 99 }, { 11, 22, 33, 44, 55, 66, 77, 88, 99 } },
		weight = 199.0,
		friendshipBase = 0
	},
	{
		name = "Celebi",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.GRASS },
		evolution = PokemonData.Evolutions.NONE,
		bst = "600",
		yield = 64,
		movelvls = { { 10, 20, 30, 40, 50 }, { 10, 20, 30, 40, 50 } },
		weight = 5.0,
		friendshipBase = 100
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "none",
		types = { PokemonData.Types.EMPTY, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = Constants.BLANKLINE,
		yield = 0,
		movelvls = { {}, {} },
		weight = 0.0,
	},
	{
		name = "Treecko",
		types = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = "16",
		bst = "310",
		yield = 65,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 5.0
	},
	{
		name = "Grovyle",
		types = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = "36",
		bst = "405",
		yield = 141,
		movelvls = { { 6, 11, 16, 17, 23, 29, 35, 41, 47, 53 }, { 6, 11, 16, 17, 23, 29, 35, 41, 47, 53 } },
		weight = 21.6
	},
	{
		name = "Sceptile",
		types = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "530",
		yield = 208,
		movelvls = { { 6, 11, 16, 17, 23, 29, 35, 43, 51, 59 }, { 6, 11, 16, 17, 23, 29, 35, 43, 51, 59 } },
		weight = 52.2
	},
	{
		name = "Torchic",
		types = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = "16",
		bst = "310",
		yield = 65,
		movelvls = { { 7, 10, 16, 19, 25, 28, 34, 37, 43 }, { 7, 10, 16, 19, 25, 28, 34, 37, 43 } },
		weight = 2.5
	},
	{
		name = "Combusken",
		types = { PokemonData.Types.FIRE, PokemonData.Types.FIGHTING },
		evolution = "36",
		bst = "405",
		yield = 142,
		movelvls = { { 7, 13, 16, 17, 21, 28, 32, 39, 43, 50 }, { 7, 13, 16, 17, 21, 28, 32, 39, 43, 50 } },
		weight = 19.5
	},
	{
		name = "Blaziken",
		types = { PokemonData.Types.FIRE, PokemonData.Types.FIGHTING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "530",
		yield = 209,
		movelvls = { { 7, 13, 16, 17, 21, 28, 32, 36, 42, 49, 59 }, { 7, 13, 16, 17, 21, 28, 32, 36, 42, 49, 59 } },
		weight = 52.0
	},
	{
		name = "Mudkip",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "16",
		bst = "310",
		yield = 65,
		movelvls = { { 6, 10, 15, 19, 24, 28, 33, 37, 42, 46 }, { 6, 10, 15, 19, 24, 28, 33, 37, 42, 46 } },
		weight = 7.6
	},
	{
		name = "Marshtomp",
		types = { PokemonData.Types.WATER, PokemonData.Types.GROUND },
		evolution = "36",
		bst = "405",
		yield = 143,
		movelvls = { { 6, 10, 15, 16, 20, 25, 31, 37, 42, 46, 53 }, { 6, 10, 15, 16, 20, 25, 31, 37, 42, 46, 53 } },
		weight = 28.0
	},
	{
		name = "Swampert",
		types = { PokemonData.Types.WATER, PokemonData.Types.GROUND },
		evolution = PokemonData.Evolutions.NONE,
		bst = "535",
		yield = 210,
		movelvls = { { 6, 10, 15, 16, 20, 25, 31, 39, 46, 52, 61 }, { 6, 10, 15, 16, 20, 25, 31, 39, 46, 52, 61 } },
		weight = 81.9
	},
	{
		name = "Poochyena",
		types = { PokemonData.Types.DARK, PokemonData.Types.EMPTY },
		evolution = "18",
		bst = "220",
		yield = 55,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 } },
		weight = 13.6
	},
	{
		name = "Mightyena",
		types = { PokemonData.Types.DARK, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "420",
		yield = 128,
		movelvls = { { 5, 9, 13, 17, 22, 27, 32, 37, 42, 47, 52 }, { 5, 9, 13, 17, 22, 27, 32, 37, 42, 47, 52 } },
		weight = 37.0
	},
	{
		name = "Zigzagoon",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "20",
		bst = "240",
		yield = 60,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41 } },
		weight = 17.5
	},
	{
		name = "Linoone",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "420",
		yield = 128,
		movelvls = { { 5, 9, 13, 17, 23, 29, 35, 41, 47, 53 }, { 5, 9, 13, 17, 23, 29, 35, 41, 47, 53 } },
		weight = 32.5
	},
	{
		name = "Wurmple",
		types = { PokemonData.Types.BUG, PokemonData.Types.EMPTY },
		evolution = "7",
		bst = "195",
		yield = 54,
		movelvls = { { 5 }, { 5 } },
		weight = 3.6
	},
	{
		name = "Silcoon",
		types = { PokemonData.Types.BUG, PokemonData.Types.EMPTY },
		evolution = "10",
		bst = "205",
		yield = 71,
		movelvls = { { 7 }, { 7 } },
		weight = 10.0
	},
	{
		name = "Beautifly",
		types = { PokemonData.Types.BUG, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "385",
		yield = 161,
		movelvls = { { 10, 13, 17, 20, 24, 27, 31, 34, 38 }, { 10, 13, 17, 20, 24, 27, 31, 34, 38 } },
		weight = 28.4
	},
	{
		name = "Cascoon",
		types = { PokemonData.Types.BUG, PokemonData.Types.EMPTY },
		evolution = "10",
		bst = "205",
		yield = 72,
		movelvls = { { 7 }, { 7 } },
		weight = 11.5
	},
	{
		name = "Dustox",
		types = { PokemonData.Types.BUG, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "385",
		yield = 160,
		movelvls = { { 10, 13, 17, 20, 24, 27, 31, 34, 38 }, { 10, 13, 17, 20, 24, 27, 31, 34, 38 } },
		weight = 31.6
	},
	{
		name = "Lotad",
		types = { PokemonData.Types.WATER, PokemonData.Types.GRASS },
		evolution = "14",
		bst = "220",
		yield = 74,
		movelvls = { { 3, 7, 13, 21, 31, 43 }, { 3, 7, 13, 21, 31, 43 } },
		weight = 2.6
	},
	{
		name = "Lombre",
		types = { PokemonData.Types.WATER, PokemonData.Types.GRASS },
		evolution = PokemonData.Evolutions.WATER,
		bst = "340",
		yield = 141,
		movelvls = { { 3, 7, 13, 19, 25, 31, 37, 43, 49 }, { 3, 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 32.5
	},
	{
		name = "Ludicolo",
		types = { PokemonData.Types.WATER, PokemonData.Types.GRASS },
		evolution = PokemonData.Evolutions.NONE,
		bst = "480",
		yield = 181,
		movelvls = { {}, {} },
		weight = 55.0
	},
	{
		name = "Seedot",
		types = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = "14",
		bst = "220",
		yield = 74,
		movelvls = { { 3, 7, 13, 21, 31, 43 }, { 3, 7, 13, 21, 31, 43 } },
		weight = 4.0
	},
	{
		name = "Nuzleaf",
		types = { PokemonData.Types.GRASS, PokemonData.Types.DARK },
		evolution = PokemonData.Evolutions.LEAF,
		bst = "340",
		yield = 141,
		movelvls = { { 3, 7, 13, 19, 25, 31, 37, 43, 49 }, { 3, 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 28.0
	},
	{
		name = "Shiftry",
		types = { PokemonData.Types.GRASS, PokemonData.Types.DARK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "480",
		yield = 181,
		movelvls = { {}, {} },
		weight = 59.6
	},
	{
		name = "Nincada",
		types = { PokemonData.Types.BUG, PokemonData.Types.GROUND },
		evolution = "20",
		bst = "266",
		yield = 65,
		movelvls = { { 5, 9, 14, 19, 25, 31, 38, 45 }, { 5, 9, 14, 19, 25, 31, 38, 45 } },
		weight = 5.5
	},
	{
		name = "Ninjask",
		types = { PokemonData.Types.BUG, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "456",
		yield = 155,
		movelvls = { { 5, 9, 14, 19, 20, 20, 20, 25, 31, 38, 45 }, { 5, 9, 14, 19, 20, 20, 20, 25, 31, 38, 45 } },
		weight = 12.0
	},
	{
		name = "Shedinja",
		types = { PokemonData.Types.BUG, PokemonData.Types.GHOST },
		evolution = PokemonData.Evolutions.NONE,
		bst = "236",
		yield = 95,
		movelvls = { { 5, 9, 14, 19, 25, 31, 38, 45 }, { 5, 9, 14, 19, 25, 31, 38, 45 } },
		weight = 1.2
	},
	{
		name = "Taillow",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = "22",
		bst = "270",
		yield = 59,
		movelvls = { { 4, 8, 13, 19, 26, 34, 43 }, { 4, 8, 13, 19, 26, 34, 43 } },
		weight = 2.3
	},
	{
		name = "Swellow",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "430",
		yield = 162,
		movelvls = { { 4, 8, 13, 19, 28, 38, 49 }, { 4, 8, 13, 19, 28, 38, 49 } },
		weight = 19.8
	},
	{
		name = "Shroomish",
		types = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = "23",
		bst = "295",
		yield = 65,
		movelvls = { { 4, 7, 10, 16, 22, 28, 36, 45, 54 }, { 4, 7, 10, 16, 22, 28, 36, 45, 54 } },
		weight = 4.5
	},
	{
		name = "Breloom",
		types = { PokemonData.Types.GRASS, PokemonData.Types.FIGHTING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "460",
		yield = 165,
		movelvls = { { 4, 7, 10, 16, 22, 23, 28, 36, 45, 54 }, { 4, 7, 10, 16, 22, 23, 28, 36, 45, 54 } },
		weight = 39.2
	},
	{
		name = "Spinda",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "360",
		yield = 85,
		movelvls = { { 5, 12, 16, 23, 27, 34, 38, 45, 49, 56 }, { 5, 12, 16, 23, 27, 34, 38, 45, 49, 56 } },
		weight = 5.0
	},
	{
		name = "Wingull",
		types = { PokemonData.Types.WATER, PokemonData.Types.FLYING },
		evolution = "25",
		bst = "270",
		yield = 64,
		movelvls = { { 7, 13, 21, 31, 43, 55 }, { 7, 13, 21, 31, 43, 55 } },
		weight = 9.5
	},
	{
		name = "Pelipper",
		types = { PokemonData.Types.WATER, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "430",
		yield = 164,
		movelvls = { { 3, 7, 13, 21, 25, 33, 33, 47, 61 }, { 3, 7, 13, 21, 25, 33, 33, 47, 61 } },
		weight = 28.0
	},
	{
		name = "Surskit",
		types = { PokemonData.Types.BUG, PokemonData.Types.WATER },
		evolution = "22",
		bst = "269",
		yield = 63,
		movelvls = { { 7, 13, 19, 25, 31, 37, 37 }, { 7, 13, 19, 25, 31, 37, 37 } },
		weight = 1.7
	},
	{
		name = "Masquerain",
		types = { PokemonData.Types.BUG, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "414",
		yield = 128,
		movelvls = { { 7, 13, 19, 26, 33, 40, 47, 53 }, { 7, 13, 19, 26, 33, 40, 47, 53 } },
		weight = 3.6
	},
	{
		name = "Wailmer",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "40",
		bst = "400",
		yield = 137,
		movelvls = { { 5, 10, 14, 19, 23, 28, 32, 37, 41, 46, 50 }, { 5, 10, 14, 19, 23, 28, 32, 37, 41, 46, 50 } },
		weight = 130.0
	},
	{
		name = "Wailord", -- STONKS
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		yield = 206,
		movelvls = { { 5, 10, 14, 19, 23, 28, 32, 37, 44, 52, 59 }, { 5, 10, 14, 19, 23, 28, 32, 37, 44, 52, 59 } },
		weight = 398.0
	},
	{
		name = "Skitty",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.MOON,
		bst = "260",
		yield = 65,
		movelvls = { { 3, 7, 13, 15, 19, 25, 27, 31, 37, 39 }, { 3, 7, 13, 15, 19, 25, 27, 31, 37, 39 } },
		weight = 11.0
	},
	{
		name = "Delcatty",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "380",
		yield = 138,
		movelvls = { {}, {} },
		weight = 32.6
	},
	{
		name = "Kecleon", -- KEKLEO-N
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "440",
		yield = 132,
		movelvls = { { 4, 7, 12, 17, 24, 31, 40, 49 }, { 4, 7, 12, 17, 24, 31, 40, 49 } },
		weight = 22.0
	},
	{
		name = "Baltoy",
		types = { PokemonData.Types.GROUND, PokemonData.Types.PSYCHIC },
		evolution = "36",
		bst = "300",
		yield = 58,
		movelvls = { { 3, 5, 7, 11, 15, 19, 25, 31, 37, 45 }, { 3, 5, 7, 11, 15, 19, 25, 31, 37, 45 } },
		weight = 21.5
	},
	{
		name = "Claydol",
		types = { PokemonData.Types.GROUND, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "500",
		yield = 189,
		movelvls = { { 3, 5, 7, 11, 15, 19, 25, 31, 36, 42, 55 }, { 3, 5, 7, 11, 15, 19, 25, 31, 36, 42, 55 } },
		weight = 108.0
	},
	{
		name = "Nosepass",
		types = { PokemonData.Types.ROCK, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "375",
		yield = 108,
		movelvls = { { 7, 13, 16, 22, 28, 31, 37, 43, 46 }, { 7, 13, 16, 22, 28, 31, 37, 43, 46 } },
		weight = 97.0
	},
	{
		name = "Torkoal",
		types = { PokemonData.Types.FIRE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "470",
		yield = 161,
		movelvls = { { 4, 7, 14, 17, 20, 27, 30, 33, 40, 43, 46 }, { 4, 7, 14, 17, 20, 27, 30, 33, 40, 43, 46 } },
		weight = 80.4
	},
	{
		name = "Sableye",
		types = { PokemonData.Types.DARK, PokemonData.Types.GHOST },
		evolution = PokemonData.Evolutions.NONE,
		bst = "380",
		yield = 98,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 } },
		weight = 11.0,
		friendshipBase = 35
	},
	{
		name = "Barboach",
		types = { PokemonData.Types.WATER, PokemonData.Types.GROUND },
		evolution = "30",
		bst = "288",
		yield = 92,
		movelvls = { { 6, 6, 11, 16, 21, 26, 26, 31, 36, 41 }, { 6, 6, 11, 16, 21, 26, 26, 31, 36, 41 } },
		weight = 1.9
	},
	{
		name = "Whiscash",
		types = { PokemonData.Types.WATER, PokemonData.Types.GROUND },
		evolution = PokemonData.Evolutions.NONE,
		bst = "468",
		yield = 158,
		movelvls = { { 6, 6, 11, 16, 21, 26, 26, 36, 46, 56 }, { 6, 6, 11, 16, 21, 26, 26, 36, 46, 56 } },
		weight = 23.6
	},
	{
		name = "Luvdisc",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "330",
		yield = 110,
		movelvls = { { 4, 12, 16, 24, 28, 36, 40, 48 }, { 4, 12, 16, 24, 28, 36, 40, 48 } },
		weight = 8.7
	},
	{
		name = "Corphish",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "30",
		bst = "308",
		yield = 111,
		movelvls = { { 7, 10, 13, 20, 23, 26, 32, 35, 38, 44 }, { 7, 10, 13, 19, 22, 25, 31, 34, 37, 43, 46 } },
		weight = 11.5
	},
	{
		name = "Crawdaunt", -- FRAUD
		types = { PokemonData.Types.WATER, PokemonData.Types.DARK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "468",
		yield = 161,
		movelvls = { { 7, 10, 13, 20, 23, 26, 34, 39, 44, 52 }, { 7, 10, 13, 19, 22, 25, 33, 38, 43, 51, 56 } },
		weight = 32.8
	},
	{
		name = "Feebas",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = "35", -- Level 35 replaces beauty condition
		bst = "200",
		yield = 61,
		movelvls = { { 15, 30 }, { 15, 30 } },
		weight = 7.4
	},
	{
		name = "Milotic", -- THICC
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "540",
		yield = 213,
		movelvls = { { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 }, { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 } },
		weight = 162.0
	},
	{
		name = "Carvanha",
		types = { PokemonData.Types.WATER, PokemonData.Types.DARK },
		evolution = "30",
		bst = "305",
		yield = 88,
		movelvls = { { 7, 13, 16, 22, 28, 31, 37, 43 }, { 7, 13, 16, 22, 28, 31, 37, 43 } },
		weight = 20.8,
		friendshipBase = 35
	},
	{
		name = "Sharpedo",
		types = { PokemonData.Types.WATER, PokemonData.Types.DARK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "460",
		yield = 175,
		movelvls = { { 7, 13, 16, 22, 28, 33, 38, 43, 48, 53 }, { 7, 13, 16, 22, 28, 33, 38, 43, 48, 53 } },
		weight = 88.8,
		friendshipBase = 35
	},
	{
		name = "Trapinch",
		types = { PokemonData.Types.GROUND, PokemonData.Types.EMPTY },
		evolution = "35",
		bst = "290",
		yield = 73,
		movelvls = { { 9, 17, 25, 33, 41, 49, 57 }, { 9, 17, 25, 33, 41, 49, 57 } },
		weight = 15.0
	},
	{
		name = "Vibrava",
		types = { PokemonData.Types.GROUND, PokemonData.Types.DRAGON },
		evolution = "45",
		bst = "340",
		yield = 126,
		movelvls = { { 9, 17, 25, 33, 35, 41, 49, 57 }, { 9, 17, 25, 33, 35, 41, 49, 57 } },
		weight = 15.3
	},
	{
		name = "Flygon",
		types = { PokemonData.Types.GROUND, PokemonData.Types.DRAGON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "520",
		yield = 197,
		movelvls = { { 9, 17, 25, 33, 35, 41, 53, 65 }, { 9, 17, 25, 33, 35, 41, 53, 65 } },
		weight = 82.0
	},
	{
		name = "Makuhita",
		types = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = "24",
		bst = "237",
		yield = 87,
		movelvls = { { 4, 10, 13, 19, 22, 28, 31, 37, 40, 46, 49 }, { 4, 10, 13, 19, 22, 28, 31, 37, 40, 46, 49 } },
		weight = 86.4
	},
	{
		name = "Hariyama",
		types = { PokemonData.Types.FIGHTING, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "474",
		yield = 184,
		movelvls = { { 4, 10, 13, 19, 22, 29, 33, 40, 44, 51, 55 }, { 4, 10, 13, 19, 22, 29, 33, 40, 44, 51, 55 } },
		weight = 253.8
	},
	{
		name = "Electrike",
		types = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = "26",
		bst = "295",
		yield = 104,
		movelvls = { { 4, 9, 12, 17, 20, 25, 28, 33, 36, 41 }, { 4, 9, 12, 17, 20, 25, 28, 33, 36, 41 } },
		weight = 15.2
	},
	{
		name = "Manectric",
		types = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "475",
		yield = 168,
		movelvls = { { 4, 9, 12, 17, 20, 25, 31, 39, 45, 53 }, { 4, 9, 12, 17, 20, 25, 31, 39, 45, 53 } },
		weight = 40.2
	},
	{
		name = "Numel",
		types = { PokemonData.Types.FIRE, PokemonData.Types.GROUND },
		evolution = "33",
		bst = "305",
		yield = 88,
		movelvls = { { 11, 19, 25, 29, 31, 35, 41, 49 }, { 11, 19, 25, 29, 31, 35, 41, 49 } },
		weight = 24.0
	},
	{
		name = "Camerupt",
		types = { PokemonData.Types.FIRE, PokemonData.Types.GROUND },
		evolution = PokemonData.Evolutions.NONE,
		bst = "460",
		yield = 175,
		movelvls = { { 11, 19, 25, 29, 31, 33, 37, 45, 55 }, { 11, 19, 25, 29, 31, 33, 37, 45, 55 } },
		weight = 220.0
	},
	{
		name = "Spheal",
		types = { PokemonData.Types.ICE, PokemonData.Types.WATER },
		evolution = "32",
		bst = "290",
		yield = 75,
		movelvls = { { 7, 13, 19, 25, 31, 37, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 37, 43, 49 } },
		weight = 39.5
	},
	{
		name = "Sealeo",
		types = { PokemonData.Types.ICE, PokemonData.Types.WATER },
		evolution = "44",
		bst = "410",
		yield = 128,
		movelvls = { { 7, 13, 19, 25, 31, 39, 39, 47, 55 }, { 7, 13, 19, 25, 31, 39, 39, 47, 55 } },
		weight = 87.6
	},
	{
		name = "Walrein",
		types = { PokemonData.Types.ICE, PokemonData.Types.WATER },
		evolution = PokemonData.Evolutions.NONE,
		bst = "530",
		yield = 192,
		movelvls = { { 7, 13, 19, 25, 31, 39, 39, 50, 61 }, { 7, 13, 19, 25, 31, 39, 39, 50, 61 } },
		weight = 150.6
	},
	{
		name = "Cacnea",
		types = { PokemonData.Types.GRASS, PokemonData.Types.EMPTY },
		evolution = "32",
		bst = "335",
		yield = 97,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49 } },
		weight = 51.3,
		friendshipBase = 35
	},
	{
		name = "Cacturne",
		types = { PokemonData.Types.GRASS, PokemonData.Types.DARK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "475",
		yield = 177,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 35, 41, 47, 53 }, { 5, 9, 13, 17, 21, 25, 29, 35, 41, 47, 53, 59 } },
		weight = 77.4,
		friendshipBase = 35
	},
	{
		name = "Snorunt",
		types = { PokemonData.Types.ICE, PokemonData.Types.EMPTY },
		evolution = "42",
		bst = "300",
		yield = 74,
		movelvls = { { 7, 10, 16, 19, 25, 28, 34, 37, 43 }, { 7, 10, 16, 19, 25, 28, 34, 37, 43 } },
		weight = 16.8
	},
	{
		name = "Glalie",
		types = { PokemonData.Types.ICE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "480",
		yield = 187,
		movelvls = { { 7, 10, 16, 19, 25, 28, 34, 42, 53, 61 }, { 7, 10, 16, 19, 25, 28, 34, 42, 53, 61 } },
		weight = 256.5
	},
	{
		name = "Lunatone",
		types = { PokemonData.Types.ROCK, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "440",
		yield = 150,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 168.0
	},
	{
		name = "Solrock",
		types = { PokemonData.Types.ROCK, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "440",
		yield = 150,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 154.0
	},
	{
		name = "Azurill",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.FRIEND,
		bst = "190",
		yield = 33,
		movelvls = { { 3, 6, 10, 15, 21 }, { 3, 6, 10, 15, 21 } },
		weight = 2.0
	},
	{
		name = "Spoink",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = "32",
		bst = "330",
		yield = 89,
		movelvls = { { 7, 10, 16, 19, 25, 28, 34, 37, 37, 43 }, { 7, 10, 16, 19, 25, 28, 34, 37, 37, 43 } },
		weight = 30.6
	},
	{
		name = "Grumpig",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "470",
		yield = 164,
		movelvls = { { 7, 10, 16, 19, 25, 28, 37, 43, 43, 55 }, { 7, 10, 16, 19, 25, 28, 37, 43, 43, 55 } },
		weight = 71.5
	},
	{
		name = "Plusle",
		types = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "405",
		yield = 120,
		movelvls = { { 4, 10, 13, 19, 22, 28, 31, 37, 40, 47 }, { 4, 10, 13, 19, 22, 28, 31, 37, 40, 47 } },
		weight = 4.2
	},
	{
		name = "Minun",
		types = { PokemonData.Types.ELECTRIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "405",
		yield = 120,
		movelvls = { { 4, 10, 13, 19, 22, 28, 31, 37, 40, 47 }, { 4, 10, 13, 19, 22, 28, 31, 37, 40, 47 } },
		weight = 4.2
	},
	{
		name = "Mawile",
		types = { PokemonData.Types.STEEL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "380",
		yield = 98,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46, 46, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46, 46, 46 } },
		weight = 11.5
	},
	{
		name = "Meditite",
		types = { PokemonData.Types.FIGHTING, PokemonData.Types.PSYCHIC },
		evolution = "37",
		bst = "280",
		yield = 91,
		movelvls = { { 4, 9, 12, 18, 22, 28, 32, 38, 42, 48 }, { 4, 9, 12, 17, 20, 25, 28, 33, 36, 41, 44 } },
		weight = 11.2
	},
	{
		name = "Medicham",
		types = { PokemonData.Types.FIGHTING, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "410",
		yield = 153,
		movelvls = { { 4, 9, 12, 18, 22, 28, 32, 40, 46, 54 }, { 4, 9, 12, 17, 20, 25, 28, 33, 36, 47, 56 } },
		weight = 31.5
	},
	{
		name = "Swablu",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.FLYING },
		evolution = "35",
		bst = "310",
		yield = 74,
		movelvls = { { 8, 11, 18, 21, 28, 31, 38, 41, 48 }, { 8, 11, 18, 21, 28, 31, 38, 41, 48 } },
		weight = 1.2
	},
	{
		name = "Altaria",
		types = { PokemonData.Types.DRAGON, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "490",
		yield = 188,
		movelvls = { { 8, 11, 18, 21, 28, 31, 35, 40, 45, 54, 59 }, { 8, 11, 18, 21, 28, 31, 35, 40, 45, 54, 59 } },
		weight = 20.6
	},
	{
		name = "Wynaut",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = "15",
		bst = "260",
		yield = 44,
		movelvls = { { 15, 15, 15, 15 }, { 15, 15, 15, 15 } },
		weight = 14.0
	},
	{
		name = "Duskull",
		types = { PokemonData.Types.GHOST, PokemonData.Types.EMPTY },
		evolution = "37",
		bst = "295",
		yield = 97,
		movelvls = { { 5, 12, 16, 23, 27, 34, 38, 45, 49 }, { 5, 12, 16, 23, 27, 34, 38, 45, 49 } },
		weight = 15.0,
		friendshipBase = 35
	},
	{
		name = "Dusclops",
		types = { PokemonData.Types.GHOST, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "455",
		yield = 179,
		movelvls = { { 5, 12, 16, 23, 27, 34, 37, 41, 51, 58 }, { 5, 12, 16, 23, 27, 34, 37, 41, 51, 58 } },
		weight = 30.6,
		friendshipBase = 35
	},
	{
		name = "Roselia",
		types = { PokemonData.Types.GRASS, PokemonData.Types.POISON },
		evolution = PokemonData.Evolutions.NONE,
		bst = "400",
		yield = 152,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, 53, 57 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, 53, 57 } },
		weight = 2.0
	},
	{
		name = "Slakoth",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "18",
		bst = "280",
		yield = 83,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43 }, { 7, 13, 19, 25, 31, 37, 43 } },
		weight = 24.0
	},
	{
		name = "Vigoroth",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "36",
		bst = "440",
		yield = 126,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 46.5
	},
	{
		name = "Slaking",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "670",
		yield = 210,
		movelvls = { { 7, 13, 19, 25, 31, 36, 37, 43 }, { 7, 13, 19, 25, 31, 36, 37, 43 } },
		weight = 130.5
	},
	{
		name = "Gulpin",
		types = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = "26",
		bst = "302",
		yield = 75,
		movelvls = { { 6, 9, 14, 17, 23, 28, 34, 34, 34, 39 }, { 6, 9, 14, 17, 23, 28, 34, 34, 34, 39 } },
		weight = 10.3
	},
	{
		name = "Swalot",
		types = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "467",
		yield = 168,
		movelvls = { { 6, 9, 14, 17, 23, 26, 31, 40, 40, 40, 48 }, { 6, 9, 14, 17, 23, 26, 31, 40, 40, 40, 48 } },
		weight = 80.0
	},
	{
		name = "Tropius",
		types = { PokemonData.Types.GRASS, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "460",
		yield = 169,
		movelvls = { { 7, 11, 17, 21, 27, 31, 37, 41, 47 }, { 7, 11, 17, 21, 27, 31, 37, 41, 47 } },
		weight = 100.0
	},
	{
		name = "Whismur",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "20",
		bst = "240",
		yield = 68,
		movelvls = { { 5, 11, 15, 21, 25, 31, 35, 41, 41, 45 }, { 5, 11, 15, 21, 25, 31, 35, 41, 41, 45 } },
		weight = 16.3
	},
	{
		name = "Loudred",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = "40",
		bst = "360",
		yield = 126,
		movelvls = { { 5, 11, 15, 23, 29, 37, 43, 51, 51, 57 }, { 5, 11, 15, 23, 29, 37, 43, 51, 51, 57 } },
		weight = 40.5
	},
	{
		name = "Exploud",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "480",
		yield = 184,
		movelvls = { { 5, 11, 15, 23, 29, 37, 40, 45, 55, 55, 63 }, { 5, 11, 15, 23, 29, 37, 40, 45, 55, 55, 63 } },
		weight = 84.0
	},
	{
		name = "Clamperl",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.WATER30, -- Level 30 and stone replace trade evolution
		bst = "345",
		yield = 142,
		movelvls = { {}, {} },
		weight = 52.5
	},
	{
		name = "Huntail",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "485",
		yield = 178,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 27.0
	},
	{
		name = "Gorebyss",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "485",
		yield = 178,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 22.6
	},
	{
		name = "Absol",
		types = { PokemonData.Types.DARK, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "465",
		yield = 174,
		movelvls = { { 5, 9, 13, 17, 21, 26, 31, 36, 41, 46 }, { 5, 9, 13, 17, 21, 26, 31, 36, 41, 46 } },
		weight = 47.0,
		friendshipBase = 35
	},
	{
		name = "Shuppet",
		types = { PokemonData.Types.GHOST, PokemonData.Types.EMPTY },
		evolution = "37",
		bst = "295",
		yield = 97,
		movelvls = { { 8, 13, 20, 25, 32, 37, 44, 49, 56 }, { 8, 13, 20, 25, 32, 37, 44, 49, 56 } },
		weight = 2.3,
		friendshipBase = 35
	},
	{
		name = "Banette",
		types = { PokemonData.Types.GHOST, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "455",
		yield = 179,
		movelvls = { { 8, 13, 20, 25, 32, 39, 48, 55, 64 }, { 8, 13, 20, 25, 32, 39, 48, 55, 64 } },
		weight = 12.5,
		friendshipBase = 35
	},
	{
		name = "Seviper",
		types = { PokemonData.Types.POISON, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "458",
		yield = 165,
		movelvls = { { 7, 10, 16, 19, 25, 28, 34, 37, 43 }, { 7, 10, 16, 19, 25, 28, 34, 37, 43 } },
		weight = 52.5
	},
	{
		name = "Zangoose",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "458",
		yield = 165,
		movelvls = { { 4, 7, 10, 13, 19, 25, 31, 37, 46, 55 }, { 4, 7, 10, 13, 19, 25, 31, 37, 46, 55 } },
		weight = 40.3
	},
	{
		name = "Relicanth",
		types = { PokemonData.Types.WATER, PokemonData.Types.ROCK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "485",
		yield = 198,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 57, 64 }, { 8, 15, 22, 29, 36, 43, 50, 57, 64 } },
		weight = 23.4
	},
	{
		name = "Aron",
		types = { PokemonData.Types.STEEL, PokemonData.Types.ROCK },
		evolution = "32",
		bst = "330",
		yield = 96,
		movelvls = { { 4, 7, 10, 13, 17, 21, 25, 29, 34, 39, 44 }, { 4, 7, 10, 13, 17, 21, 25, 29, 34, 39, 44 } },
		weight = 60.0,
		friendshipBase = 35
	},
	{
		name = "Lairon",
		types = { PokemonData.Types.STEEL, PokemonData.Types.ROCK },
		evolution = "42",
		bst = "430",
		yield = 152,
		movelvls = { { 4, 7, 10, 13, 17, 21, 25, 29, 37, 45, 53 }, { 4, 7, 10, 13, 17, 21, 25, 29, 37, 45, 53 } },
		weight = 120.0,
		friendshipBase = 35
	},
	{
		name = "Aggron",
		types = { PokemonData.Types.STEEL, PokemonData.Types.ROCK },
		evolution = PokemonData.Evolutions.NONE,
		bst = "530",
		yield = 205,
		movelvls = { { 4, 7, 10, 13, 17, 21, 25, 29, 37, 50, 63 }, { 4, 7, 10, 13, 17, 21, 25, 29, 37, 50, 63 } },
		weight = 360.0,
		friendshipBase = 35
	},
	{
		name = "Castform",
		types = { PokemonData.Types.NORMAL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "420",
		yield = 145,
		movelvls = { { 10, 10, 10, 20, 20, 20, 30 }, { 10, 10, 10, 20, 20, 20, 30 } },
		weight = 0.8
	},
	{
		name = "Volbeat",
		types = { PokemonData.Types.BUG, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "400",
		yield = 146,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37 } },
		weight = 17.7
	},
	{
		name = "Illumise",
		types = { PokemonData.Types.BUG, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "400",
		yield = 146,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37 } },
		weight = 17.7
	},
	{
		name = "Lileep",
		types = { PokemonData.Types.ROCK, PokemonData.Types.GRASS },
		evolution = "40",
		bst = "355",
		yield = 121,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 50, 50 }, { 8, 15, 22, 29, 36, 43, 50, 50, 50 } },
		weight = 23.8
	},
	{
		name = "Cradily",
		types = { PokemonData.Types.ROCK, PokemonData.Types.GRASS },
		evolution = PokemonData.Evolutions.NONE,
		bst = "495",
		yield = 201,
		movelvls = { { 8, 15, 22, 29, 36, 48, 60, 60, 60 }, { 8, 15, 22, 29, 36, 48, 60, 60, 60 } },
		weight = 60.4
	},
	{
		name = "Anorith",
		types = { PokemonData.Types.ROCK, PokemonData.Types.BUG },
		evolution = "40",
		bst = "355",
		yield = 119,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49, 55 }, { 7, 13, 19, 25, 31, 37, 43, 49, 55 } },
		weight = 12.5
	},
	{
		name = "Armaldo",
		types = { PokemonData.Types.ROCK, PokemonData.Types.BUG },
		evolution = PokemonData.Evolutions.NONE,
		bst = "495",
		yield = 200,
		movelvls = { { 7, 13, 19, 25, 31, 37, 46, 55, 64 }, { 7, 13, 19, 25, 31, 37, 46, 55, 64 } },
		weight = 68.2
	},
	{
		name = "Ralts",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = "20",
		bst = "198",
		yield = 70,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 6.6,
		friendshipBase = 35
	},
	{
		name = "Kirlia",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = "30",
		bst = "278",
		yield = 140,
		movelvls = { { 6, 11, 16, 21, 26, 33, 40, 47, 54 }, { 6, 11, 16, 21, 26, 33, 40, 47, 54 } },
		weight = 20.2,
		friendshipBase = 35
	},
	{
		name = "Gardevoir",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "518",
		yield = 208,
		movelvls = { { 6, 11, 16, 21, 26, 33, 42, 51, 60 }, { 6, 11, 16, 21, 26, 33, 42, 51, 60 } },
		weight = 48.4,
		friendshipBase = 35
	},
	{
		name = "Bagon",
		types = { PokemonData.Types.DRAGON, PokemonData.Types.EMPTY },
		evolution = "30",
		bst = "300",
		yield = 89,
		movelvls = { { 5, 9, 17, 21, 25, 33, 37, 41, 49, 53 }, { 5, 9, 17, 21, 25, 33, 37, 41, 49, 53 } },
		weight = 42.1,
		friendshipBase = 35
	},
	{
		name = "Shelgon",
		types = { PokemonData.Types.DRAGON, PokemonData.Types.EMPTY },
		evolution = "50",
		bst = "420",
		yield = 144,
		movelvls = { { 5, 9, 17, 21, 25, 30, 38, 47, 56, 69, 78 }, { 5, 9, 17, 21, 25, 30, 38, 47, 56, 69, 78 } },
		weight = 110.5,
		friendshipBase = 35
	},
	{
		name = "Salamence",
		types = { PokemonData.Types.DRAGON, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "600",
		yield = 218,
		movelvls = { { 5, 9, 17, 21, 25, 30, 38, 47, 50, 61, 79, 93 }, { 5, 9, 17, 21, 25, 30, 38, 47, 50, 61, 79, 93 } },
		weight = 102.6,
		friendshipBase = 35
	},
	{
		name = "Beldum",
		types = { PokemonData.Types.STEEL, PokemonData.Types.PSYCHIC },
		evolution = "20",
		bst = "300",
		yield = 103,
		movelvls = { {}, {} },
		weight = 95.2,
		friendshipBase = 35
	},
	{
		name = "Metang",
		types = { PokemonData.Types.STEEL, PokemonData.Types.PSYCHIC },
		evolution = "45",
		bst = "420",
		yield = 153,
		movelvls = { { 20, 20, 26, 32, 38, 44, 50, 56, 62 }, { 20, 20, 26, 32, 38, 44, 50, 56, 62 } },
		weight = 202.5,
		friendshipBase = 35
	},
	{
		name = "Metagross",
		types = { PokemonData.Types.STEEL, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "600",
		yield = 210,
		movelvls = { { 20, 20, 26, 32, 38, 44, 55, 66, 77 }, { 20, 20, 26, 32, 38, 44, 55, 66, 77 } },
		weight = 550.0,
		friendshipBase = 35
	},
	{
		name = "Regirock",
		types = { PokemonData.Types.ROCK, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "580",
		yield = 217,
		movelvls = { { 9, 17, 25, 33, 41, 49, 57, 65 }, { 9, 17, 25, 33, 41, 49, 57, 65 } },
		weight = 230.0,
		friendshipBase = 35
	},
	{
		name = "Regice",
		types = { PokemonData.Types.ICE, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "580",
		yield = 216,
		movelvls = { { 9, 17, 25, 33, 41, 49, 57, 65 }, { 9, 17, 25, 33, 41, 49, 57, 65 } },
		weight = 175.0,
		friendshipBase = 35
	},
	{
		name = "Registeel",
		types = { PokemonData.Types.STEEL, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "580",
		yield = 215,
		movelvls = { { 9, 17, 25, 33, 41, 41, 49, 57, 65 }, { 9, 17, 25, 33, 41, 41, 49, 57, 65 } },
		weight = 205.0,
		friendshipBase = 35
	},
	{
		name = "Kyogre",
		types = { PokemonData.Types.WATER, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "670",
		yield = 218,
		movelvls = { { 5, 15, 20, 30, 35, 45, 50, 60, 65, 75 }, { 5, 15, 20, 30, 35, 45, 50, 60, 65, 75 } },
		weight = 352.0,
		friendshipBase = 0
	},
	{
		name = "Groudon",
		types = { PokemonData.Types.GROUND, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "670",
		yield = 218,
		movelvls = { { 5, 15, 20, 30, 35, 45, 50, 60, 65, 75 }, { 5, 15, 20, 30, 35, 45, 50, 60, 65, 75 } },
		weight = 950.0,
		friendshipBase = 0
	},
	{
		name = "Rayquaza",
		types = { PokemonData.Types.DRAGON, PokemonData.Types.FLYING },
		evolution = PokemonData.Evolutions.NONE,
		bst = "680",
		yield = 220,
		movelvls = { { 5, 15, 20, 30, 35, 45, 50, 60, 65, 75 }, { 5, 15, 20, 30, 35, 45, 50, 60, 65, 75 } },
		weight = 206.5,
		friendshipBase = 0
	},
	{
		name = "Latias",
		types = { PokemonData.Types.DRAGON, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "600",
		yield = 211,
		movelvls = { { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 }, { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 } },
		weight = 40.0,
		friendshipBase = 90
	},
	{
		name = "Latios",
		types = { PokemonData.Types.DRAGON, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "600",
		yield = 211,
		movelvls = { { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 }, { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 } },
		weight = 60.0,
		friendshipBase = 90
	},
	{
		name = "Jirachi",
		types = { PokemonData.Types.STEEL, PokemonData.Types.PSYCHIC },
		evolution = PokemonData.Evolutions.NONE,
		bst = "600",
		yield = 215,
		movelvls = { { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 }, { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 } },
		weight = 1.1,
		friendshipBase = 100
	},
	{
		name = "Deoxys",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "600",
		yield = 215,
		movelvls = { { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 }, { 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 } },
		weight = 60.8,
		friendshipBase = 0
	},
	{
		name = "Chimecho",
		types = { PokemonData.Types.PSYCHIC, PokemonData.Types.EMPTY },
		evolution = PokemonData.Evolutions.NONE,
		bst = "425",
		yield = 147,
		movelvls = { { 6, 9, 14, 17, 22, 25, 30, 33, 38, 41, 46 }, { 6, 9, 14, 17, 22, 25, 30, 33, 38, 41, 46 } },
		weight = 1.0
	},
}
