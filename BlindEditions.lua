--- STEAMODDED HEADER
--- MOD_NAME: Blind Editions
--- MOD_ID: BlindEditions
--- PREFIX: ble
--- MOD_AUTHOR: [mathguy]
--- MOD_DESCRIPTION: Blinds may now have editions.
--- VERSION: 1.0.0
--- PRIORITY: -100
----------------------------------------------
------------MOD CODE -------------------------

function SMODS.current_mod.process_loc_text()
    G.localization.descriptions.BlindEdition = {}
end

SMODS.BlindEditions = {}
SMODS.BlindEdition = SMODS.GameObject:extend {
    obj_table = SMODS.BlindEditions,
    obj_buffer = {},
    required_params = {
        'key',
    },
    set = 'BlindEdition',
    weight = 1,
    class_prefix = 'ble',
    inject = function(self)
        G.P_BLIND_EDITIONS[self.key] = self
    end,
    no_color = function(self)
        if not self.colour and not self.new_colour and not self.special_colour and not self.tertiary_colour then
            return true
        end
        return false
    end,
    get_weight = function(self, blind_on_deck)
        return self.weight
    end,
    in_pool = function(self, blind_on_deck)
        return true
    end
}

SMODS.BlindEdition {
    key = 'base',
    weight = 4,
    has_text = false
}

SMODS.BlindEdition {
    key = 'foil',
    blind_shader = 'foil',
    loc_txt = {
        name = "",
        text = {"X#1# Blind Size"}
    },
    blind_size_mult = 1.5,
    weight = 0.4,
    loc_vars = function(self, blind_on_deck)
        return {1.5}
    end,
    dollars_mod = 1
}

SMODS.BlindEdition {
    key = 'holographic',
    blind_shader = 'holo',
    loc_txt = {
        name = "",
        text = {"-#1# Hand"}
    },
    weight = 0.3,
    loc_vars = function(self, blind_on_deck)
        return {1}
    end,
    set_blind = function(self, blind_on_deck)
        ease_hands_played(-1)
    end,
    dollars_mod = 2
}

SMODS.BlindEdition {
    key = 'polychrome',
    blind_shader = 'polychrome',
    weight = 0.2,
    dollars_mod = 3,
    loc_txt = {
        name = "",
        text = {"-#1# Hand Size"}
    },
    contrast = 3,
    set_blind = function(self, blind_on_deck)
        G.hand:change_size(-1)
    end,
    defeat = function(self, blind_on_deck)
        G.hand:change_size(1)
    end,
    loc_vars = function(self, blind_on_deck)
        return {1}
    end,

}

SMODS.BlindEdition {
    key = 'negative',
    blind_shader = 'negative',
    weight = 0.1,
    loc_txt = {
        name = "",
        text = {
            "X-#1# Blind Reward",
            "Unskippable"
        }
    },
    dollars_mod = function(self, dollars)
        return -dollars
    end,
    loc_vars = function(self, blind_on_deck)
        return {1}
    end,
    no_skip = true

}

function set_blind_editions()
    G.GAME.blind_edition = {
        Small = "",
        Big = "",
        Boss = "",
    }
    for i, j in pairs(G.GAME.blind_edition) do
        local total_weight = 0
        local weight_table = {}
        for i2, j2 in pairs(G.P_BLIND_EDITIONS or {}) do
            if j2.in_pool and (type(j2.in_pool) == "function") and j2:in_pool(i) then
                local weight = j2.get_weight and (type(j2.get_weight) == "function") and j2:get_weight(i) or j2.weight or 1
                table.insert(weight_table, {key = j2.key, weight = weight})
                total_weight = total_weight + weight
            end
        end
        if total_weight > 0 then
            local num = pseudorandom('blind_edition') * total_weight
            local curr_weight = 0
            local selected = weight_table[#weight_table].key
            for i2, j2 in ipairs(weight_table) do
                curr_weight = curr_weight + j2.weight
                if num < curr_weight then
                    selected = j2.key
                    break
                end
            end
            G.GAME.blind_edition[i] = selected
        else
            G.GAME.blind_edition[i] = 'ble_ble_base'
        end
    end
end

function type_(a)
    return type(a)
end

function dollars_to_string(dollars)
    if not dollars then
        return "-"
    end
    if dollars <= -9 then
        return "-$" .. tostring(-dollars)
    elseif dollars < 0 then
        return "-" .. string.rep("$", -dollars)
    elseif dollars >= 9 then
        return "$" .. tostring(dollars)
    elseif dollars > 0 then
        return string.rep("$", dollars)
    else
        return ""
    end
end

----------------------------------------------
------------MOD CODE END----------------------