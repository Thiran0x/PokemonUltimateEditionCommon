-- Battle State
NO_BATTLE = 0
SELECT_POKEMON = 1
PRE_MOVE_RESOLVE_STATUS = 2
SELECT_MOVE = 3
ROLL_EFFECTS = 4
RESOLVE_STATUS = 5
ROLL_ATTACK = 6
RESOLVE = 7

-- Roll State
PLACING = 0
NONE = 1
ROLLING = 2
CALCULATE = 3

-- Move State
DEFAULT = 0
EFFECTIVE = 1
WEAK = 2
DISABLED = 3
SUPER_WEAK = 4
SUPER_EFFECTIVE = 5


-- Trainer type
PLAYER = 0
GYM = 1
TRAINER = 2
WILD = 3
RIVAL = 4

ATTACKER = true
DEFENDER = false

local defenderConfirmed = false
local attackerConfirmed = false

local debug = false

-- GUIDS
local gyms = { "20bcd5", "ec01e5", "f2f4fe", "d8dc51", "b564fd", "22cc88", "c4bd30", "c9dd73", "a0f650", "c970ca", "19db0d" }
local deploy_pokeballs = { "9c4411", "c988ea", "2cf16d", "986cb5", "f66036", "e46f90" }
local wildPokeZone = "f10ab0"

local blueRack = nil
local greenRack = nil
local orangeRack = nil
local purpleRack = nil
local redRack = nil
local yellowRack = nil
local evolvePokeballGUID = {"757125", "6fd4a0", "23f409", "caf1c8", "35376b", "f353e7", "68c4b0", "96358f"}
local evolvedPokeballGUID = "140fbd"
local effectDice="6a319d"
local critDice="229313"
local d4Dice="7c6144"
local d6Dice="15df3c"
local statusGUID = {burned="3b8a3d", poisoned="26c816", sleep="00dbc5", paralysed="040f66", frozen="d8769a", confused="d2fe3e"}

local levelDiceXOffset = 0.205
local levelDiceZOffset = 0.13

local attackerData={
  type = nil,
  dice = {},
  attackValue={level=0, movePower=0, effectiveness=0, attackRoll=0, item=0, total=0},
  arenaEffects={},
  previousMove={},
  canSelectMove=true,
  selectedMoveIndex=-1,
  selectedMoveData=nil,
  diceMod=0,
  teraType=nil,
  model_GUID=nil
}
local attackerPokemon=nil

local defenderData={
  type = nil,
  dice = {},
  attackValue={level=0, movePower=0, effectiveness=0, attackRoll=0, item=0, total=0},
  arenaEffects={},
  previousMove={},
  canSelectMove=true,
  selectedMoveIndex=-1,
  selectedMoveData=nil,
  diceMod=0,
  teraType=nil,
  model_GUID=nil
}
local defenderPokemon=nil

local atkCounter="73b431"
local atkMoveText={"d91743","8895de", "0390e6"}
local atkText="a5671b"
local defCounter="b76b2a"
local defMoveText={"9e8ac1","68aee8", "8099cc"}
local defText="e6c686"
local roundText="8ba5f3"
local arenaTextGUID="f0b393"
local currRound = 0

-- Arena Button Positions
local incLevelAtkPos = {x=8.14, z=6.28}
local decLevelAtkPos = {x=6.53, z=6.28}
local incStatusAtkPos = {x=12.98, z=6.81}
local decStatusAtkPos = {x=11.18, z=6.81}
local movesAtkPos = {x=10.50, z=2.47}
local teamAtkPos = {x=12.00, z=2.47}
local recallAtkPos = {x=13.50, z=2.47}
local atkEvolve1Pos = {x=5.69, z=5.07}
local atkEvolve2Pos = {x=8.90, z=5.07}
local atkMoveZPos = 8.3
local atkConfirmPos = {x=7.29, z=11.87}

local incLevelDefPos = {x=8.14, z=-6.12}
local decLevelDefPos = {x=6.53, z=-6.12}
local incStatusDefPos = {x=12.98, z=-6.60}
local decStatusDefPos = {x=11.18, z=-6.60}
local movesDefPos = {x=10.49, z=-2.34}
local teamDefPos = {x=11.99, z=-2.34}
local recallDefPos = {x=13.49, z=-2.34}
local defEvolve1Pos = {x=5.69, z=-4.94}
local defEvolve2Pos = {x=8.90, z=-4.94}
local defMoveZPos = -8.85
local defConfirmPos = {x=7.35, z=-11.74}

local rivalFipButtonPos = {x=7.33, z=6.28}

local attackRollState = PLACING
local defendRollState = PLACING

local aiDifficulty = 0
local scriptingEnabled = false
local noMoveData = {name="NoMove", power=0, dice=6, status=DEFAULT}
local wildPokemonGUID = nil
local wildPokemonKanto = nil
local wildPokemonColorIndex = nil
local gymLeaderGuid = nil
local isSecondTrainer = false

local multiEvolving = false
local multiEvoData={}
-- Used for models during multi-evo.
local multiEvoGuids={}

-- States.
local inBattle = false
local battleState = NO_BATTLE

--Arena Positions
local defenderPos = {pokemon={-36.01, 4.19}, dice={-36.03, 6.26}, status={-31.25, 4.44}, statusCounters={-31.25, 6.72}, item={-40.87, 4.26}, moveDice={-36.11, 8.66}}
local attackerPos = {pokemon={-36.06,-4.23}, dice={-36.03,-6.15}, status={-31.25,-4.31}, statusCounters={-31.25,-6.74}, item={-40.87,-4.13}, moveDice={-36.11,-8.53}}

-- This one will likely never be used sadly. There is no way to add a zone to each mod with the same GUID.
-- We can't save the zone as an object. :/
local xAttackLookupTable = { 
    ["91bbed"] = true,
    ["979ce4"] = true,
    ["017e6a"] = true,
    ["f062ef"] = true,
    ["cc20b4"] = true,
    ["f9ae34"] = true,
    ["65c113"] = true,
    ["bdb6b6"] = true
  }
-- This will return nil if the lookup fails.
local typeBoosterLookupTable = { 
    ["Grass Booster"] = "Grass",
    ["Water Booster"] = "Water",
    ["Fire Booster"] = "Fire",
    ["Poison Booster"] = "Poison",
    ["Ice Booster"] = "Ice",
    ["Dark Booster"] = "Dark",
    ["Steel Booster"] = "Steel",
    ["Psychic Booster"] = "Psychic",
    ["Ghost Booster"] = "Ghost",
    ["Fairy Booster"] = "Fairy",
    ["Ground Booster"] = "Ground",
    ["Fighting Booster"] = "Fighting",
    ["Normal Booster"] = "Normal",
    ["Dragon Booster"] = "Dragon",
    ["Flying Booster"] = "Flying",
    ["Electric Booster"] = "Electric",
    ["Bug Booster"] = "Bug",
    ["Rock Booster"] = "Rock"
  }

--------------------------
-- Save/Load functions.
--------------------------

-- Basic initialize function that receives the rack GUIDs.
function initialize(params)
  yellowRack = params[1]
  greenRack = params[2]
  blueRack = params[3]
  redRack = params[4]
  purpleRack = params[5]
  orangeRack = params[6]
end

function onSave()
  local save_table = {
    in_battle = inBattle,
    blueRack = blueRack,
    greenRack = greenRack,
    orangeRack = orangeRack,
    purpleRack = purpleRack,
    redRack = redRack,
    yellowRack = yellowRack
  }
  return JSON.encode(save_table)
end

function onLoad(saved_data)
    -- Check if there is saved data.
    local save_table
    if saved_data and saved_data ~= "" then
      save_table = JSON.decode(saved_data)
    end

    -- Parse the saved data.
    if save_table then
      inBattle = save_table.in_battle
      blueRack = save_table.blueRack
      greenRack = save_table.greenRack
      orangeRack = save_table.orangeRack
      purpleRack = save_table.purpleRack
      redRack = save_table.redRack
      yellowRack = save_table.yellowRack
    end
  
    -- Do some safety checks.
    if inBattle == nil then
      inBattle = false
    end

    -- Create Arena Buttons
    self.createButton({label="TEAM", click_function="seeAttackerRack",function_owner=self, tooltip="See Team",position={teamAtkPos.x, 1000, teamAtkPos.z}, height=300, width=720, font_size=200})
    self.createButton({label="MOVES", click_function="seeMoveRules",function_owner=self, tooltip="Show Move Rules",position={movesAtkPos.x, 1000, movesAtkPos.z}, height=300, width=720, font_size=200})
    self.createButton({label="RECALL", click_function="recallAtkArena",function_owner=self, tooltip="Recall Pokémon",position={recallAtkPos.x, 1000, recallAtkPos.z}, height=300, width=720, font_size=200})
    self.createButton({label="+", click_function="increaseAtkArena",function_owner=self, tooltip="Increase Level",position={incLevelAtkPos.x, 1000, incLevelAtkPos.z}, height=300, width=240, font_size=200})
    self.createButton({label="-", click_function="decreaseAtkArena",function_owner=self, tooltip="Decrease Level",position={decLevelAtkPos.x, 1000, decLevelAtkPos.z}, height=300, width=240, font_size=200})
    self.createButton({label="+", click_function="addAtkStatus",function_owner=self, tooltip="Add Status Counter",position={incStatusAtkPos.x, 1000, incStatusAtkPos.z}, height=300, width=200, font_size=200})
    self.createButton({label="-", click_function="removeAtkStatus",function_owner=self, tooltip="Remove Status Counter",position={decStatusAtkPos.x, 1000, decStatusAtkPos.z}, height=300, width=200, font_size=200})
    self.createButton({label="E1", click_function="evolveAtk",function_owner=self, tooltip="Choose Evolution 1",position={-42.5, 1000, -0.33}, height=300, width=240, font_size=200})
    self.createButton({label="E2", click_function="evolveTwoAtk",function_owner=self, tooltip="Choose Evolution 2",position={-45.15, 1000, -0.33}, height=300, width=240, font_size=200})
    self.createButton({label="Move 1", click_function="attackMove1", function_owner=self, position={-45, 1000, atkMoveZPos}, height=300, width=1600, font_size=200})
    self.createButton({label="Move 2", click_function="attackMove2", function_owner=self, position={-40, 1000, atkMoveZPos}, height=300, width=1600, font_size=200})
    self.createButton({label="Move 3", click_function="attackMove3", function_owner=self, position={-35, 1000, atkMoveZPos}, height=300, width=1600, font_size=200})
    self.createButton({label="CONFIRM", click_function="confirmAttack", function_owner=self, position={atkConfirmPos.x, 1000, atkConfirmPos.z}, height=300, width=1600, font_size=200})

    self.createButton({label="TEAM", click_function="seeDefenderRack",function_owner=self, tooltip="See Team",position={teamDefPos.x, 1000, teamDefPos.z}, height=300, width=720, font_size=200})
    self.createButton({label="MOVES", click_function="seeMoveRules",function_owner=self, tooltip="Show Move Rules",position={movesDefPos.x, 1000, movesDefPos.z}, height=300, width=720, font_size=200})
    self.createButton({label="RECALL", click_function="recallDefArena",function_owner=self, tooltip="Recall Pokémon",position={recallDefPos.x, 1000, recallDefPos.z}, height=300, width=720, font_size=200})
    self.createButton({label="+", click_function="increaseDefArena",function_owner=self, tooltip="Increase Level",position={incLevelDefPos.x, 1000, incLevelDefPos.z}, height=300, width=240, font_size=200})
    self.createButton({label="-", click_function="decreaseDefArena",function_owner=self, tooltip="Decrease Level",position={decLevelDefPos.x, 1000, decLevelDefPos.z}, height=300, width=240, font_size=200})
    self.createButton({label="+", click_function="addDefStatus",function_owner=self, tooltip="Add Status Counter",position={incStatusDefPos.x, 1000, incStatusDefPos.z}, height=300, width=200, font_size=200})
    self.createButton({label="-", click_function="removeDefStatus",function_owner=self, tooltip="Remove Status Counter",position={decStatusDefPos.x, 1000, decStatusDefPos.z}, height=300, width=200, font_size=200})
    self.createButton({label="E1", click_function="evolveDef",function_owner=self, tooltip="Choose Evolution 1",position={-38, 1000, -7.19}, height=300, width=240, font_size=200})
    self.createButton({label="E2", click_function="evolveTwoDef",function_owner=self, tooltip="Choose Evolution 2",position={-37, 1000, -7.19}, height=300, width=240, font_size=200})
    self.createButton({label="Move 1", click_function="defenceMove1", function_owner=self, position={-45, 1000, defMoveZPos}, height=300, width=1600, font_size=200})
    self.createButton({label="Move 2", click_function="defenceMove2", function_owner=self, position={-40, 1000, defMoveZPos}, height=300, width=1600, font_size=200})
    self.createButton({label="Move 3", click_function="defenceMove3", function_owner=self, position={-35, 1000, defMoveZPos}, height=300, width=1600, font_size=200})
    self.createButton({label="Move 3", click_function="attackMove3", function_owner=self, position={-35, 1000, atkMoveZPos}, height=300, width=1600, font_size=200})
    self.createButton({label="CONFIRM", click_function="confirmDefence", function_owner=self, position={defConfirmPos.x, 1000, defConfirmPos.z}, height=300, width=1600, font_size=200})

    -- Multi Evolution Buttons
    self.createButton({label="SELECT", click_function="multiEvo1", function_owner=self, position={0, 1000, 0}, height=300, width=1000, font_size=200})
    self.createButton({label="SELECT", click_function="multiEvo2", function_owner=self, position={0, 1000, 0}, height=300, width=1000, font_size=200})
    self.createButton({label="SELECT", click_function="multiEvo3", function_owner=self, position={0, 1000, 0}, height=300, width=1000, font_size=200})
    self.createButton({label="SELECT", click_function="multiEvo4", function_owner=self, position={0, 1000, 0}, height=300, width=1000, font_size=200})
    self.createButton({label="SELECT", click_function="multiEvo5", function_owner=self, position={0, 1000, 0}, height=300, width=1000, font_size=200})
    self.createButton({label="SELECT", click_function="multiEvo6", function_owner=self, position={0, 1000, 0}, height=300, width=1000, font_size=200})
    self.createButton({label="SELECT", click_function="multiEvo7", function_owner=self, position={0, 1000, 0}, height=300, width=1000, font_size=200})
    self.createButton({label="SELECT", click_function="multiEvo8", function_owner=self, position={0, 1000, 0}, height=300, width=1000, font_size=200})
    self.createButton({label="SELECT", click_function="multiEvo9", function_owner=self, position={0, 1000, 0}, height=300, width=1000, font_size=200})
    
    self.createButton({label="BATTLE", click_function="battleWildPokemon", function_owner=self, position={defConfirmPos.x, 1000, -6.2}, height=300, width=1600, font_size=200})
    self.createButton({label="NEXT POKEMON", click_function="flipGymLeader", function_owner=self, position={3.5, 1000, -0.6}, height=300, width=1600, font_size=200})
    self.createButton({label="", click_function="changeAttackerTeraType", function_owner=self, tooltip="Terastallize Attacker", position={3.5, 1000, -0.6}, height=300, width=1600, font_size=200})
    self.createButton({label="", click_function="changeDefenderTeraType", function_owner=self, tooltip="Terastallize Defender", position={3.5, 1000, -0.6}, height=300, width=1600, font_size=200})
    self.createButton({label="NEXT POKEMON", click_function="flipRivalPokemon", function_owner=self, position={3.5, 1000, -0.6}, height=300, width=1600, font_size=200})

    -- Check if we are in battle.
    if inBattle then
      -- Panic, <wave hand>. We are no longer in battle.
      inBattle = false

      -- Clear texts.
      clearMoveText(ATTACKER)
      clearMoveText(DEFENDER)
      
      -- Mass clear of buttons and labels.
      hideConfirmButton(DEFENDER)
      showFlipRivalButton(false)
      self.editButton({index=36, label="BATTLE"})
      showWildPokemonButton(false)
      showFlipGymButton(false)
      hideConfirmButton(ATTACKER)
      setBattleState(NO_BATTLE)
      showAtkButtons(false)
      showDefButtons(false)

      -- Clear data.
      clearPokemonData(DEFENDER)
      clearTrainerData(DEFENDER)
      clearPokemonData(ATTACKER)
      clearTrainerData(ATTACKER)

      Global.call("PlayRouteMusic",{})
    end
end

--------------------------
-- Support functions called by Global.lua.
--------------------------

function isBattleInProgress()
  -- TODO: this returns true if the Trainer controlled attacker Pokemon is in the arena waiting. This is fine *for now*.
  -- NOTE: I am dumb. I forgot there is a "inBattle" variable. Can it be trusted? >.>
  if attackerData == nil or defenderData == nil then return false end
  return attackerData.type ~= nil or defenderData.type ~= nil
end

function getAttackerType()
  if attackerData == nil or attackerData.type == nil then
    return nil
  end

  return attackerData.type
end

function getDefenderType()
  if defenderData == nil or defenderData.type == nil then
    return nil
  end

  return defenderData.type
end

--------------------------
-- Tera related functions.
--------------------------

function changeAttackerTeraType()
  if attackerPokemon.teraType == nil or attackerPokemon.types == nil then
    print("Cannot Terastallize the attacker without a Tera card!")
    return
  end
  
  -- Update the atacker type.
  -- The tera type is TECHNICALLY the only active type during dual typing. 
  -- But the token value can't change so oh well.
  local previousType = attackerPokemon.types[1]
  attackerPokemon.types[1] = attackerPokemon.teraType
  attackerPokemon.teraType = previousType

  -- Update the effectiveness of moves.
  updateTypeEffectiveness()

  showAttackerTeraButton(true, attackerPokemon.types[1])
end

function changeDefenderTeraType()
  if defenderPokemon.teraType == nil or defenderPokemon.types == nil then
    print("Cannot Terastallize the defender without a Tera card!")
    return
  end

  -- Update the defender type.
  -- The tera type is TECHNICALLY the only active type during dual typing. 
  -- But the token value can't change so oh well.
  local previousType = defenderPokemon.types[1]
  defenderPokemon.types[1] = defenderPokemon.teraType
  defenderPokemon.teraType = previousType

  -- Update the effectiveness of moves.
  updateTypeEffectiveness()

  showDefenderTeraButton(true, defenderPokemon.types[1])
end

--------------------------
-- Core BattleManager functionality.
--------------------------

function flipGymLeader()
  if defenderData.type ~= GYM then
    return
  end

  -- Reformat the data so that the model code can use it. (Sorry, I know this is hideous.) This is extra gross because
  -- I didn't feel like figuring out to fake allllll of the initialization process for RivalData models that may 
  -- never ever get seen for a game. Also it is extra complicated because we need two models per token.
  if Global.call("get_models_enabled") then
    -- Get the active model GUID. This prevents despawning the wrong model.
    local model_guid = Global.call("get_model_guid", defenderPokemon.pokemonGUID)
    if model_guid == nil then
      model_guid = defenderPokemon.model_GUID
    end
    
    local despawn_data = {
      chip = defenderPokemon.pokemonGUID,
      state = defenderPokemon,
      base = defenderPokemon,
      model = model_guid
    }

    Global.call("despawn_now", despawn_data)
  end

  -- Check if there is a secondary type token to despawn.
  if Global.call("getDualTypeEffectiveness") then
    local token_guid = Global.call("get_secondary_type_token_guid", defenderPokemon.pokemonGUID)
    if token_guid then
      Global.call("despawn_secondary_type_token", {pokemon=defenderPokemon, secondary_type_token=token_guid})
    end
  end

  -- Remove the current data 
  Global.call("remove_from_active_chips_by_GUID", defenderPokemon.pokemonGUID)

  -- Update pokemon and arena info
  --defenderPokemon = defenderData.pokemon[2]
  setNewPokemon(defenderPokemon, defenderPokemon.pokemon2, defenderPokemon.pokemonGUID)
  updateMoves(DEFENDER, defenderPokemon)
  showFlipGymButton(false)

  -- Update the defender pokemon value counter.
  defenderData.attackValue.level = defenderPokemon.pokemon2.baseLevel
  updateAttackValue(DEFENDER)

  -- Get the rival token object handle.
  local gymLeaderCard = getObjectFromGUID(defenderData.trainerGUID)

  -- Handle the model.
  local pokemonModelData = nil
  if Global.call("get_models_enabled") then
    -- The model fields don't get passed in via params here because the gyms don't save it. Modifying all of
    -- files would make me very sad.
    local gymData = Global.call("GetGymDataByGUID", {guid=defenderData.trainerGUID})
    
    -- Reformat the data so that the model code can use it. (Sorry, I know this is hideous.) This is extra gross because
    -- I didn't feel like figuring out to fake allllll of the initialization process for RivalData models that may 
    -- never ever get seen for a game. Also it is extra complicated because we need two models per token.
    pokemonModelData = {
      chip_GUID = defenderData.trainerGUID,
      base = {
        name = defenderPokemon.name,
        created_before = false,
        in_creation = false,
        persistent_state = true,
        picked_up = false,
        despawn_time = 1.0,
        model_GUID = defenderPokemon.model_GUID,
        custom_rotation = {gymLeaderCard.getRotation().x, gymLeaderCard.getRotation().y, gymLeaderCard.getRotation().z}
      },
      picked_up = false,
      in_creation = false,
      scale_set = {},
      isTwoFaced = true
    }
    pokemonModelData.chip = defenderData.trainerGUID

    -- Copy the base to a state.
    pokemonModelData.state = pokemonModelData.base

    -- Check if the params have field overrides.
    if gymData.pokemon[2].offset == nil then pokemonModelData.base.offset = {x=0, y=0, z=-0.17} else pokemonModelData.base.offset = gymData.pokemon[2].offset end
    if gymData.pokemon[2].custom_scale == nil then pokemonModelData.base.custom_scale = 1 else pokemonModelData.base.custom_scale = gymData.pokemon[2].custom_scale end
    if gymData.pokemon[2].idle_effect == nil then pokemonModelData.base.idle_effect = "Idle" else pokemonModelData.base.idle_effect = gymData.pokemon[2].idle_effect end
    if gymData.pokemon[2].spawn_effect == nil then pokemonModelData.base.spawn_effect = "Special Attack" else pokemonModelData.base.spawn_effect = gymData.pokemon[2].spawn_effect end
    if gymData.pokemon[2].run_effect == nil then pokemonModelData.base.run_effect = "Run" else pokemonModelData.base.run_effect = gymData.pokemon[2].run_effect end
    if gymData.pokemon[2].faint_effect == nil then pokemonModelData.base.faint_effect = "Faint" else pokemonModelData.base.faint_effect = gymData.pokemon[2].faint_effect end
  end

  -- Flip the gym leader card.
  gymLeaderCard.unlock()
  gymLeaderCard.flip()

  if Global.call("get_models_enabled") then
    -- Add it to the active chips.
    local model_already_created = Global.call("add_to_active_chips_by_GUID", {guid=defenderPokemon.pokemonGUID, data=pokemonModelData})
    pokemonModelData.base.created_before = model_already_created

    -- Wait until the gym leader card is idle.
    Wait.condition(
      function() -- Conditional function.
        -- Spawn in the model with the above arguments.
        Global.call("check_for_spawn_or_despawn", pokemonModelData)
      end,
      function() -- Condition function
        return gymLeaderCard ~= nil and gymLeaderCard.resting
      end,
      2,
      function() -- Timeout function.
        -- Spawn in the model with the above arguments. But this time the card is still moving, darn.
        Global.call("check_for_spawn_or_despawn", pokemonModelData)
      end
    )
    
    -- Sometimes the model gets placed upside down (I have no idea why lol). Detect it and fix it if needed.
    Wait.condition(
      function() -- Conditional function.
        -- Get a handle to the model.
        local model_guid = Global.call("get_model_guid", defenderData.trainerGUID)
        if model_guid == nil then return end
        local model = getObjectFromGUID(model_guid)
        if model ~= nil then
          local model_rotation = model.getRotation()
          if math.abs(model_rotation.z-180) < 1 or math.abs(model_rotation.x-0) then
            model.setRotation({0, model_rotation.y, 0})
          end
        end
      end,
      function() -- Condition function
        return Global.call("get_model_guid", defenderData.trainerGUID) ~= nil
      end,
      2
    )
  end

  Wait.condition(
    function()
      -- Lock the gym card in place.
      gymLeaderCard.lock()
    end,
    function() -- Condition function
      return gymLeaderCard ~= nil and gymLeaderCard.resting
    end,
    2
  )

  -- Check if we spawn a secondary type token.
  if Global.call("getDualTypeEffectiveness") then
    -- Reformat the data so that the secondary type token code can use it.
    local secondary_token_data = {
      chip_GUID = defenderData.trainerGUID,
      base = {
        name = defenderPokemon.name,
        created_before = false,
        in_creation = false,
        persistent_state = true,
        picked_up = false,
        types = defenderPokemon.types
      },
      picked_up = false,
      in_creation = false,
      isTwoFaced = true
    }
    secondary_token_data.chip = defenderData.trainerGUID
    secondary_token_data.base.token_offset = {x=1.9, y=0, z=1.0}

    -- Copy the base to a state.
    secondary_token_data.state = secondary_token_data.base

    Global.call("check_for_spawn_or_despawn_secondary_type_token", secondary_token_data)
  end

  -- Clear texts.
  clearMoveText(ATTACKER)
  clearMoveText(DEFENDER)
end

function flipRivalPokemon()
  if attackerData.type ~= RIVAL then
    return
  end

  -- Reformat the data so that the model code can use it. (Sorry, I know this is hideous.) This is extra gross because
  -- I didn't feel like figuring out to fake allllll of the initialization process for RivalData models that may 
  -- never ever get seen for a game. Also it is extra complicated because we need two models per token.
  if Global.call("get_models_enabled") then
    -- Get the active model GUID. This prevents despawning the wrong model.
    local model_guid = Global.call("get_model_guid", attackerPokemon.pokemonGUID)
    if model_guid == nil then
      model_guid = attackerPokemon.model_GUID
    end

    local despawn_data = {
      chip = attackerPokemon.pokemonGUID,
      state = attackerPokemon,
      base = attackerPokemon,
      model = model_guid
    }

    Global.call("despawn_now", despawn_data)
  end

  -- Check if there is a secondary type token to despawn.
  if Global.call("getDualTypeEffectiveness") then
    local token_guid = Global.call("get_secondary_type_token_guid", attackerPokemon.pokemonGUID)
    if token_guid then
      Global.call("despawn_secondary_type_token", {pokemon=attackerPokemon, secondary_type_token=token_guid})
    end
  end

  -- Remove the current data 
  Global.call("remove_from_active_chips_by_GUID", attackerPokemon.pokemonGUID)

  -- Update pokemon and arena info
  setNewPokemon(attackerPokemon, attackerPokemon.pokemon2, attackerPokemon.pokemonGUID)
  updateMoves(ATTACKER, attackerPokemon)
  showFlipRivalButton(false)

  -- Update the attacker value counter.
  attackerData.attackValue.level = attackerPokemon.baseLevel
  updateAttackValue(ATTACKER)

  -- Get the rival token object handle.
  local rivalToken = getObjectFromGUID(attackerPokemon.pokemonGUID)
  
  -- Handle the model.
  local pokemonModelData = nil
  if Global.call("get_models_enabled") then
    -- Reformat the data so that the model code can use it to spawn the next model. (Sorry, I know this is hideous.) 
    -- This is extra gross because I didn't feel like figuring out to fake allllll of the initialization process for
    -- RivalData models that may never ever get seen for a game. Also it is extra complicated because we need two models per token.
    pokemonModelData = {
      chip_GUID = attackerPokemon.pokemonGUID,
      base = {
        name = attackerPokemon.name,
        created_before = false,
        in_creation = false,
        persistent_state = true,
        picked_up = false,
        despawn_time = 1.0,
        model_GUID = attackerPokemon.model_GUID,
        custom_rotation = {rivalToken.getRotation().x, rivalToken.getRotation().y + 180.0, rivalToken.getRotation().z}
      },
      picked_up = false,
      in_creation = false,
      scale_set = {},
      isTwoFaced = true
    } 
    pokemonModelData.chip = attackerPokemon.pokemonGUID

    -- Copy the base to a state.
    pokemonModelData.state = pokemonModelData.base

    -- Check if the params have field overrides.
    if attackerPokemon.offset == nil then pokemonModelData.base.offset = {x=0, y=0, z=-0.17} else pokemonModelData.base.offset = attackerPokemon.offset end
    if attackerPokemon.custom_scale == nil then pokemonModelData.base.custom_scale = 1 else pokemonModelData.base.custom_scale = attackerPokemon.custom_scale end
    if attackerPokemon.idle_effect == nil then pokemonModelData.base.idle_effect = "Idle" else pokemonModelData.base.idle_effect = attackerPokemon.idle_effect end
    if attackerPokemon.spawn_effect == nil then pokemonModelData.base.spawn_effect = "Special Attack" else pokemonModelData.base.spawn_effect = attackerPokemon.spawn_effect end
    if attackerPokemon.run_effect == nil then pokemonModelData.base.run_effect = "Run" else pokemonModelData.base.run_effect = attackerPokemon.run_effect end
    if attackerPokemon.faint_effect == nil then pokemonModelData.base.faint_effect = "Faint" else pokemonModelData.base.faint_effect = attackerPokemon.faint_effect end
  end

  -- Flip the rival token.
  rivalToken.unlock()
  rivalToken.flip()
  
  if Global.call("get_models_enabled") then
    -- Add it to the active chips.
    local model_already_created = Global.call("add_to_active_chips_by_GUID", {guid=attackerPokemon.pokemonGUID, data=pokemonModelData})

    -- Spawn in the model with the above arguments.
    pokemonModelData.base.created_before = model_already_created
    Global.call("check_for_spawn_or_despawn", pokemonModelData)
  end

  -- Lock the rival token in place.
  Wait.condition(
    function()
      -- Lock the rival in place.
      rivalToken.lock()
    end,
    function() -- Condition function
      return rivalToken ~= nil and rivalToken.resting
    end,
    2
  )

  -- Check if we spawn a secondary type token.
  if Global.call("getDualTypeEffectiveness") then
    -- Reformat the data so that the secondary type token code can use it.
    local secondary_token_data = {
      chip_GUID = attackerPokemon.pokemonGUID,
      base = {
        name = attackerPokemon.name,
        created_before = false,
        in_creation = false,
        persistent_state = true,
        picked_up = false,
        types = attackerPokemon.types
      },
      picked_up = false,
      in_creation = false,
      isTwoFaced = true
    }
    secondary_token_data.chip = attackerPokemon.pokemonGUID
    secondary_token_data.base.token_offset = {x=1.7, y=-0.1, z=0.7}

    -- Copy the base to a state.
    secondary_token_data.state = secondary_token_data.base

    Global.call("check_for_spawn_or_despawn_secondary_type_token", secondary_token_data)
  end

  -- Clear texts.
  clearMoveText(ATTACKER)
  clearMoveText(DEFENDER)
end

-- This function is called by Global. When called, the BattleManager will move the Wild token 
-- to the arena and start the battle. The params.recall_params will allow a recall button to show.
function moveAndBattleWildPokemon(params)
  -- Check if a battle is in progress or if the Defender position is already occupied.
  if getDefenderType() ~= nil then
    printToAll("There is already a defending Pokémon in the arena")
    return
  end

  -- Get a handle on the model.
  local token = getObjectFromGUID(params.chip_guid)
  if not token then
    printToAll("Failed to find token for GUID " .. tostring(params.chip_guid))
    return
  end

  -- Move the Pokemon to the defender position.
  token.setPosition({defenderPos.pokemon[1], 2, defenderPos.pokemon[2]})

  -- Move the model.
  local pokemonData = Global.call("simple_get_active_pokemon_by_GUID", params.chip_guid)
  local pokemonModel = getObjectFromGUID(pokemonData.base.model_GUID)
  if pokemonModel ~= nil and Global.call("get_models_enabled") then
    -- Reformat the data so that the model code can use it. (Sorry, I know this is hideous.)
    pokemonData.chip = params.chip_guid

    Wait.condition(
      function() -- Conditional function.
        -- Move the model.
        pokemonModel.setPosition(Global.call("model_position", pokemonData))
        pokemonModel.setRotation({token.getRotation().x, token.getRotation().y, token.getRotation().z})
        pokemonModel.setLock(true)
      end,
      function() -- Condition function
        return token ~= nil and token.resting and token.getPosition().y < 1.0
      end,
      2,
      function() -- Timeout function.
        -- Move the model. But the token is still moving, darn.
        pokemonModel.setPosition(Global.call("model_position", pokemonData))
        pokemonModel.setRotation({token.getRotation().x, token.getRotation().y, token.getRotation().z})
        pokemonModel.setLock(true)
      end
    )
  end

  -- Wait for the token to come to a rest, then wait 0.5 seconds longer and start the battle.
  Wait.condition(
    function()
      Wait.time(function() battleWildPokemon(params.wild_battle_params, true) end, 0.5)
    end,
    function() -- Condition function
      return token.resting
    end,
    2
  )
end

function battleWildPokemon(wild_battle_params, is_automated)
  -- Check if in a battle.
  if inBattle == false then
    -- Check if we have a GUID.
    if not wildPokemonGUID then return end

    -- Get the data of the Pokemon token we think is present.
    local pokemonData = Global.call("GetPokemonDataByGUID",{guid=wildPokemonGUID})

    -- Check if the pokemon token is on the table.
    local token = getObjectFromGUID(wildPokemonGUID)
    if not token then
      if pokemonData then
        printToAll(pokemonData.name " token is not on the table")
      else
        printToAll("No data known for this token or the token is not on the table")
      end
      wildPokemonGUID = nil
      wildPokemonKanto = nil
      wildPokemonColorIndex = nil
      return
    end

    -- Lock the wild token.
    token.lock()

    -- Update the BM data.
    setTrainerType(DEFENDER, WILD)
    defenderPokemon = {}
    setNewPokemon(defenderPokemon, pokemonData, wildPokemonGUID)
    inBattle = true
    Global.call("PlayTrainerBattleMusic",{})
    printToAll("Wild " .. defenderPokemon.name .. " appeared!")
    updateMoves(DEFENDER, defenderPokemon)

    -- Update the defender value counter.
    defenderData.attackValue.level = defenderPokemon.baseLevel
    updateAttackValue(DEFENDER)

    aiDifficulty = Global.call("GetAIDifficulty")

    if scriptingEnabled then
      showWildPokemonButton(false)
      defenderConfirmed = true
      if attackerConfirmed then
        startBattle()
      end
    else
      local numMoves = #defenderPokemon.moves
      if numMoves > 1 then
        showConfirmButton(DEFENDER, "RANDOM MOVE")
      end
      self.editButton({index=36, label="END BATTLE"})
    end
    
    -- Create a button that allows someone to click it to catch the wild Pokemon.
    self.editButton({index=13, position={teamDefPos.x, 0.4, teamDefPos.z}, click_function="wildPokemonCatch", label="CATCH", tooltip="Catch Pokemon"})

    -- Check if this is an automated Wild Battle.
    -- NOTE: When using the BATTLE button manually this field is not empty since we are using
    --       an Object-owned button. Userdata nonsense gets put in front of our arguments. So
    --       we can't just check the wild_battle_params.
    if type(is_automated) == "boolean" and is_automated then
      -- Check if we can give a Recall button.
      if wild_battle_params.position then
        -- Valid position received.
        wildPokemonKanto = wild_battle_params.position
        self.editButton({index=14, position={movesDefPos.x, 0.4, movesDefPos.z}, click_function="wildPokemonFlee", label="FLEE", tooltip="Wild Pokemon Flees"})
      else
        print("Invalid Recall color given to battleWildPokemon: " .. tostring(wild_battle_params.color_index))
      end
      
      -- Check if we can give a Faint button.
      if wild_battle_params.color_index then
        if wild_battle_params.color_index > 0 and wild_battle_params.color_index < 7 then
          -- Valid color_index received.
          wildPokemonColorIndex = wild_battle_params.color_index
          self.editButton({index=15, position={recallDefPos.x, 0.4, recallDefPos.z}, click_function="wildPokemonFaint", label="FAINT", tooltip="Wild Pokemon Faints"})
        else
          print("Invalid Faint color given to battleWildPokemon: " .. tostring(wild_battle_params.color_index))
        end
      end 
    end
  else
    -- Check if the pokemon token is on the table.
    local token = getObjectFromGUID(wildPokemonGUID)
    if token then
      -- Unock the wild token.
      token.unlock()
    end

    inBattle = false
    text = getObjectFromGUID(defText)
    text.setValue(" ")
    hideConfirmButton(DEFENDER)

    clearPokemonData(DEFENDER)
    clearTrainerData(DEFENDER)
    self.editButton({index=36, label="BATTLE"})

    Global.call("PlayRouteMusic",{})

    -- Clear the wild Pokemon data.
    wildPokemonGUID = nil
    wildPokemonKanto = nil
    wildPokemonColorIndex = nil
    
    -- Reset the buttons.
    self.editButton({index=13, position={teamDefPos.x, 1000, teamDefPos.z}, click_function="seeDefenderRack", label="TEAM", tooltip="See Team"})
    self.editButton({index=14, position={movesDefPos.x, 1000, movesDefPos.z}, click_function="seeMoveRules", label="MOVES", tooltip="Show Move Rules"})
    self.editButton({index=15, position={recallDefPos.x, 1000, recallDefPos.z}, click_function="recallDefArena", label="RECALL", tooltip="Recall Pokémon"})
  end
end

--------------------------
-- Wild Battle Functions
--------------------------

function wildPokemonCatch(obj, player_color)
  -- First, save off the wild Pokemon's GUID.
  local wild_chip_guid = wildPokemonGUID
  local color_index = wildPokemonColorIndex

  -- Check if the user that clicked the button is the same user who is on attack, if applicable.
  if attackerData.playerColor ~= nil and attackerData.playerColor ~= player_color then return end

  -- Next, end the battle.
  battleWildPokemon()

  -- Figure out which rack we are dealing with.
  local rack = nil
  local rotation = { 0, 0, 0 }
  if player_color == "Yellow" then
    rack = getObjectFromGUID(yellowRack)
    rotation[2] = -90
  elseif player_color == "Green" then
    rack = getObjectFromGUID(greenRack)
    rotation[2] = -90
  elseif player_color == "Blue" then
    rack = getObjectFromGUID(blueRack)
    rotation[2] = -180
  elseif player_color == "Red" then
    rack = getObjectFromGUID(redRack)
    rotation[2] = -180
  elseif player_color == "Purple" then
    rack = getObjectFromGUID(purpleRack)
    rotation[2] = -270
  elseif player_color == "Orange" then
    rack = getObjectFromGUID(orangeRack)
    rotation[2] = -270
  else
    return
  end

  -- Make sure the rack exists.
  if not rack then
    print("Failed to get rack handle to allow a wild Pokémon to be caught. WHAT DID YOU DO?")
    return
  end

  -- Get a handle on the chip.
  local token = getObjectFromGUID(wild_chip_guid)
  if not token then
    print("Failed to get chip handle to allow a wild Pokémon to Flee. WHAT DID YOU DO?")
    return
  end

  -- Get the rack X Pokemon positions.
  local pokemon_x_pos_list = rack.call("getAvailablePokemonXPos")

  -- Initialize the cast params.
  local castParams = {}
  castParams.direction = {0,-1,0}
  castParams.type = 1
  castParams.max_distance = 0.7
  castParams.debug = debug

  -- Loop through each X position and find the first empty slot.
  local new_pokemon_position = nil
  for x_index=1, #pokemon_x_pos_list do
    local origin = {pokemon_x_pos_list[x_index], 0.94, -0.1}
    castParams.origin = rack.positionToWorld(origin)
    local hits = Physics.cast(castParams)

    if #hits == 0 then -- Empty Slot
      new_pokemon_position = castParams.origin
      break
    end
  end

  -- Check if the Trainer has no empty slots.
  if not new_pokemon_position then
    -- Determine the player's name.
    local player_name = player_color
    if Player[player_color].steam_name ~= nil then
        player_name = Player[player_color].steam_name
    end
    printToAll(player_name .. " needs to release a Pokémon (including statuses, attach cards and level dice) before they can catch a wild Pokémon", player_color)
    return
  end

  -- Catch the Pokemon.
  token.setPosition(new_pokemon_position)
  token.setRotation(rotation)

  -- Move the model.
  local pokemonData = Global.call("simple_get_active_pokemon_by_GUID", wild_chip_guid)
  local pokemonModel = getObjectFromGUID(pokemonData.base.model_GUID)
  if pokemonModel ~= nil and Global.call("get_models_enabled") then
    -- Reformat the data so that the model code can use it. (Sorry, I know this is hideous.)
    pokemonData.chip = wild_chip_guid

    Wait.condition(
      function() -- Conditional function.
        -- Move the model.
        pokemonModel.setPosition(Global.call("model_position", pokemonData))
        pokemonModel.setRotation({token.getRotation().x, token.getRotation().y, token.getRotation().z})
        pokemonModel.setLock(true)
      end,
      function() -- Condition function
        return token ~= nil and token.resting and token.getPosition().y < 0.4
      end,
      2,
      function() -- Timeout function.
        -- Move the model. But the token is still moving, darn.
        pokemonModel.setPosition(Global.call("model_position", pokemonData))
        pokemonModel.setRotation({token.getRotation().x, token.getRotation().y, token.getRotation().z})
        pokemonModel.setLock(true)
      end
    )
  end

  -- Wait for the token to come to a rest, then wait 0.2 seconds longer and start the battle.
  Wait.condition(
    function()
      -- Refresh the rack.
      rack.call("rackRefreshPokemon")
    end,
    function() -- Condition function
      return token.resting and token.getPosition().y < 0.4
    end,
    2
  )

  -- Get a handle on the pokeball that we care about.
  local pokeball = nil
  if color_index ~= nil then
    pokeball = getObjectFromGUID(deploy_pokeballs[color_index])
    if not pokeball then
      print("Failed to get Pokeball handle to allow a wild Pokémon to be caught. WHAT DID YOU DO?")
      return
    end
  else
    printToAll("Cannot deal a new Pokémon token unless you utilize the hotkey to initiate Wild Pokémon battles (Options > Game Keys > Wild Battle Pokemon)", player_color)
  end

  -- Wait for the token to come to a rest, then wait 0.3 seconds longer and deal a new token.
  if pokeball ~= nil then
    Wait.condition(
      function()
        -- Deal a new Pokemon chip of the appropriate color.
        Wait.time(function() pokeball.call("deal") end, 0.3)
      end,
      function() -- Condition function
        return token.resting
      end,
      2
    )
  end
end

function wildPokemonFlee()
  -- First, save off the wild Pokemon's GUID and kanto location.
  local wild_chip_guid = wildPokemonGUID
  local kanto_location = wildPokemonKanto

  -- Next, end the battle.
  battleWildPokemon()

  -- Get a handle on the chip.
  local token = getObjectFromGUID(wild_chip_guid)
  if not token then
    print("Failed to get chip handle to allow a wild Pokémon to Flee. WHAT DID YOU DO?")
    return
  end
  
  -- Move the Pokemon chip back to its kanto location.
  token.setPosition({kanto_location.x, 2, kanto_location.z})

  -- Move the model.
  local pokemonData = Global.call("simple_get_active_pokemon_by_GUID", wild_chip_guid)
  local pokemonModel = getObjectFromGUID(pokemonData.base.model_GUID)
  if pokemonModel ~= nil and Global.call("get_models_enabled") then
    -- Reformat the data so that the model code can use it. (Sorry, I know this is hideous.)
    pokemonData.chip = wild_chip_guid

    Wait.condition(
      function() -- Conditional function.
        -- Move the model.
        pokemonModel.setPosition(Global.call("model_position", pokemonData))
        pokemonModel.setRotation({token.getRotation().x, token.getRotation().y, token.getRotation().z})
        pokemonModel.setLock(true)
      end,
      function() -- Condition function
        return token ~= nil and token.resting and token.getPosition().y < 1.1
      end,
      2,
      function() -- Timeout function.
        -- Move the model. But the token is still moving, darn.
        pokemonModel.setPosition(Global.call("model_position", pokemonData))
        pokemonModel.setRotation({token.getRotation().x, token.getRotation().y, token.getRotation().z})
        pokemonModel.setLock(true)
      end
    )
  end
end

function wildPokemonFaint()
  -- First, save off the wild Pokemon's GUID and color index.
  local wild_chip_guid = wildPokemonGUID
  local color_index = wildPokemonColorIndex

  -- Next, end the battle.
  battleWildPokemon()

  -- Get a handle on the chip.
  local chip = getObjectFromGUID(wild_chip_guid)
  if not chip then
    print("Failed to get chip handle to allow a wild Pokémon to Faint. WHAT DID YOU DO?")
    return
  end

  -- Get a handle on the pokeball that we care about.
  local pokeball = getObjectFromGUID(deploy_pokeballs[color_index])
  if not pokeball then
    print("Failed to get Pokeball handle to allow a wild Pokémon to Faint. WHAT DID YOU DO?")
    return
  end

  -- Check if there is a secondary type token to despawn.
  if Global.call("getDualTypeEffectiveness") then
    local pokemonData = Global.call("GetPokemonDataByGUID",{guid=wild_chip_guid})
    local token_guid = Global.call("get_secondary_type_token_guid", wild_chip_guid)
    if pokemonData and token_guid then
      Global.call("despawn_secondary_type_token", {pokemon=pokemonData, secondary_type_token=token_guid})
    end
  end

  -- Put the Pokemon chip back in its place.
  pokeball.putObject(chip)

  -- Wait for the token to come to a rest, then wait 0.3 seconds longer and deal a new token.
  Wait.condition(
    function()
      -- Deal a new Pokemon chip of the appropriate color.
      Wait.time(function() pokeball.call("deal") end, 0.3)
    end,
    function() -- Condition function
      return getObjectFromGUID(wildPokemonGUID) == nil
    end,
    2
  )
end

--------------------------
-- "AI" Functions
--------------------------

function setScriptingEnabled(enabled)
  scriptingEnabled = enabled
end

function setBattleState(state)
  local arenaText = getObjectFromGUID(arenaTextGUID)
  battleState = state
  if battleState == SELECT_MOVE then
    arenaText.TextTool.setValue("SELECT MOVE")
  elseif battleState == ROLL_EFFECTS then
    arenaText.TextTool.setValue("ROLL EFFECTS")
  elseif battleState == ROLL_ATTACK then
    arenaText.TextTool.setValue("ROLL ATTACK")
  elseif battleState == PRE_MOVE_RESOLVE_STATUS or battleState == RESOLVE_STATUS then
    arenaText.TextTool.setValue("RESOLVE STATUS")
  elseif battleState == SELECT_POKEMON then
    arenaText.TextTool.setValue("SELECT POKEMON")
  elseif battleState == NO_BATTLE then
    arenaText.TextTool.setValue("ARENA")
  end
end

function confirmAttack()

  if scriptingEnabled == false then
    selectRandomMove(ATTACKER)
    return
  end

  attackerConfirmed = true
  hideConfirmButton(ATTACKER)
  if defenderConfirmed then
    if battleState == NO_BATTLE then
      startBattle()
    elseif battleState == SELECT_POKEMON then
      if attackerPokemon == nil then
        forfeit(ATTACKER)
      else
        resolvePokemon()
      end
    elseif battleState == ROLL_EFFECTS then
      resolveEffects()
    elseif battleState == PRE_MOVE_RESOLVE_STATUS or battleState == RESOLVE_STATUS then
      resolveStatuses()
    elseif battleState == ROLL_ATTACK then
      resolveAttacks()
    end
  end
end


function confirmDefence()

  if scriptingEnabled == false then
    selectRandomMove(DEFENDER)
    return
  end

  defenderConfirmed = true
  hideConfirmButton(DEFENDER)
  if attackerConfirmed then
    if battleState == NO_BATTLE then
      startBattle()
    elseif battleState == SELECT_POKEMON then
      if defenderPokemon == nil then
        forfeit(DEFENDER)
      else
        resolvePokemon()
      end
    elseif battleState == ROLL_EFFECTS then
      resolveEffects()
    elseif battleState == PRE_MOVE_RESOLVE_STATUS or battleState == RESOLVE_STATUS then
      resolveStatuses()
    elseif battleState == ROLL_ATTACK then
      resolveAttacks()
    end
  end
end

function selectRandomMove(isAttacker)

  local data = isAttacker and attackerData or defenderData

  if data.type == GYM then
    move = math.random(1,3)
  elseif data.type == TRAINER or data.type == WILD or data.type == RIVAL then
    move = math.random(1,2)
  end

  selectMove(move, isAttacker, true)
end

function startBattle()

  setBattleState(SELECT_MOVE)
  if defenderType ~= GYM and defenderType ~= WILD and attackerType ~= TRAINER then
    inBattle = true
    Global.call("PlayTrainerBattleMusic",{})
  end

  resolvePokemon()
end

function forfeit(isAttacker)

  local data = isAttacker and attackerData or defenderData
  printToAll(Player[data.playerColor].steam_name .. " forfeitted the battle!")

  if isAttacker then
    if defenderData.type == GYM then
      local gym = getObjectFromGUID(defenderData.gymGUID)
      gym.call("recall");
    elseif defenderData.type == WILD then
      defenderData.wildPokemonGUID = nil
    end
  else
    if attackerData.type == TRAINER then
      local pokeball = getObjectFromGUID(attackerData.pokeballGUID)
      pokeball.call("recall")
    end
  end

  endBattle()
end


function resolvePokemon()

  setRound(currRound + 1)
  updateStatus(ATTACKER, attackerData.status)
  updateStatus(DEFENDER, defenderData.status)

  local rollEffects = false
  local attackerStatus = attackerData.status
  if attackerStatus ~= nil then
    if attackerStatus == "Paralyse" or attackerStatus == "Freeze" then
      rollEffects = true
      spawnStatusDice(ATTACKER)
      showConfirmButton(ATTACKER, "CONFIRM")
    end
  else
    attackerConfirmed = true
  end
  local defenderStatus = defenderData.status
  if defenderStatus ~= nil then
    if defenderStatus == "Paralyse" or defenderStatus == "Freeze" then
      rollEffects = true
      spawnStatusDice(DEFENDER)
      showConfirmButton(DEFENDER, "CONFIRM")
    end
  else
    defenderConfirmed = true
  end

  if rollEffects then
    setBattleState(PRE_MOVE_RESOLVE_STATUS)
    hideArenaMoveButtons(ATTACKER)
    hideArenaMoveButtons(DEFENDER)
  else

    attackerConfirmed = not attackerData.canSelectMove
    defenderConfirmed = not defenderData.canSelectMove
    setBattleState(SELECT_MOVE)
    updateTypeEffectiveness()
  end

end

function resolveStatuses()

  if #attackerDice > 0 then
    resolveStatus(ATTACKER, attackerDice[1])
  end
  if #defenderDice > 0 then
    resolveStatus(DEFENDER, defenderDice[1])
  end

  clearDice(ATTACKER)
  clearDice(DEFENDER)

  if battleState == PRE_MOVE_RESOLVE_STATUS then

    showMoveButtons(ATTACKER)
    showMoveButtons(DEFENDER)
    attackerConfirmed = not attackerData.canSelectMove
    defenderConfirmed = not defenderData.canSelectMove
    setBattleState(SELECT_MOVE)
    updateTypeEffectiveness()

  else

    setBattleState(ROLL_ATTACK)

    spawnDice(attackerData.selectedMoveData, ATTACKER, attackerPokemon.effects)
    spawnDice(defenderData.selectedMoveData, DEFENDER, defenderPokemon.effects)

    showConfirmButton(ATTACKER, "CONFIRM")
    showConfirmButton(DEFENDER, "CONFIRM")

  end
end

function resolveStatus(isAttacker, diceGUID)

  local data = isAttacker and attackerData or defenderData
  local dice = getObjectFromGUID(diceGUID)
  local diceValue = dice.getValue()
  local statusCard = getObjectFromGUID(data.statusGUID)
  if data.status == "Paralyse" then
    if diceValue == 1 then
      statusCard.flip()
      clearMoveData(isAttacker, "'s fully paralsed!")
    end
  elseif data.status == "Sleep" then
    clearMoveData(isAttacker, " is fast asleep!")
    addStatusCounters(isAttacker, diceValue)
    statusCard.flip()
  elseif data.status == "Freeze" then
      if diceValue == 4 then
        removeStatus(data)
      else
        clearMoveData(isAttacker, " is frozen solid!")
      end
  end
end

function clearMoveData(isAttacker, reason)

  if isAttacker then
    move = attackerMove
    atkValue = attackerAttackValue
    textfield = atkText
    pokemonName = attackerData.name
    attackerData.canSelectMove = false
  else
    move = defenderMove
    atkValue = defenderAttackValue
    textfield = defText
    pokemonName = defenderData.name
    defenderData.canSelectMove = false
  end

  if move.name ~= nil and move.name == "NoMove" then
    return
  end

  atkValue.movePower = 0
  atkValue.effectiveness = 0
  local textObj = getObjectFromGUID(textfield)
  textObj.TextTool.setValue(" ")

  if isAttacker then
    attackerMove = noMoveData
  else
    defenderMove = noMoveData
  end
end


function resolveAttacks()

  calculateAttackRoll(ATTACKER)
  calculateAttackRoll(DEFENDER)

  calculateFinalAttack(ATTACKER)
  calculateFinalAttack(DEFENDER)

  if attackerData.attackValue.total == defenderData.attackValue.total then

    printToAll("Draw. Re-roll attack dice.")
    showConfirmButton(ATTACKER, "CONFIRM")
    showConfirmButton(DEFENDER, "CONFIRM")
  else

    resolveRound()
  end

end

function calculateAttackRoll(isAttacker)

  if isAttacker then
    data = attackerData
    pokemonData = attackerPokemon
  else
    data = defenderData
    pokemonData = defenderPokemon
  end

  -- Add dice values into a table
  local attackRoll = 0
  local roll = {}
  local die
  for i=1, #data.dice do
    die = getObjectFromGUID(data.dice[i])
    table.insert(roll, die.getValue())
  end

  if data.diceMod ~= 0 then
    table.sort(roll)
    if diceMod > 0 then -- Remove lowest X rolls
      for i=1, diceMod do
        table.remove(roll, 1)
      end
    elseif diceMod < 0 then -- Remove highest X rolls
      for i=math.abs(diceMod), 1, -1 do
        table.remove(roll, #roll)
      end
    end
  end

  for i=1, #roll do
    attackRoll = attackRoll + roll[i]
  end

  -- If the attack roll is odd, add the move's strength to the opponent's move's strength
  if pokemonData.status ~= nil and pokemonData.status == "Confuse" then
    if attackRoll%2 ~= 0 then
      if isAttacker then
        defenderData.attackValue.movePower = defenderData.attackValue.movePower + attackerData.attackValue.movePower
      else
        attackerData.attackValue.movePower = attackerData.attackValue.movePower + defenderData.attackValue.movePower
      end
    end
  end

  data.attackValue.attackRoll = attackRoll
end

function calculateFinalAttack(isAttacker)
  if isAttacker then
    data = attackerData
    pokemonData = attackerPokemon
  else
    data = defenderData
    pokemonData = defenderPokemon
  end

  local attackValue = data.attackValue
  local totalAttack = attackValue.attackRoll + attackValue.level + attackValue.movePower + attackValue.effectiveness + attackValue.item
  attackValue.total = totalAttack

  -- printToAll(pokemonData.name .. " hits for " .. totalAttack .. " Attack!")
  -- local calcString = attackValue.attackRoll .. " + " .. attackValue.level .. " (lvl) + " .. attackValue.movePower .. " (move)"

  -- if attackValue.effectiveness ~= 0 then
  --   if attackValue.effectiveness > 0 then
  --     calcString = calcString .. " + " .. attackValue.effectiveness .. " (effective)"
  --   else
  --     local abs = math.abs(attackValue.effectiveness)
  --     calcString = calcString .. " - " .. abs .. " (weak)"
  --   end
  -- end
  -- if attackValue.item ~= 0 then
  --     calcString = calcString .. " + " .. attackValue.item  .. " (item)"
  -- end

  -- printToAll(calcString)

  updateAttackValue(isAttacker)
end


function resolveRound()

  setBattleState(RESOLVE)

  -- Clear the text fields.
  clearMoveText(ATTACKER)
  clearMoveText(DEFENDER)

  local attackerWon = attackerData.attackValue.total > defenderData.attackValue.total

  if attackerWon then
    if attackerData.type == PLAYER then
      playerWon(ATTACKER)
    elseif attackerData.type == TRAINER then
      trainerWon()
    end
    if defenderData.type == GYM then
      gymLost()
    elseif defenderData.type == WILD then
      wildPokemonLost()
    elseif defenderData.type == PLAYER then
      playerLost(DEFENDER)
    end
  else
    if defenderData.type == PLAYER then
      playerWon(DEFENDER)
    elseif defenderData.type == GYM then
      gymWon()
    elseif defenderData.type == WILD then
      wildPokemonWon()
    end
    if attackerData.type == PLAYER then
      playerLost(ATTACKER)
    elseif attackerData.type == TRAINER then
      trainerLost()
    end
  end

  resetTrainerData(ATTACKER)
  resetTrainerData(DEFENDER)

  clearDice(ATTACKER)
  clearDice(DEFENDER)

  if battleState ~= NO_BATTLE then
    setBattleState(SELECT_POKEMON)
    if attackerData.type == PLAYER then
      showConfirmButton(ATTACKER, "CONFIRM")
    end
    if defenderData.type == PLAYER then
      showConfirmButton(DEFENDER, "CONFIRM")
    end
  end
end


function playerWon(isAttacker)

  if isAttacker then
    data = attackerData
    pokemonData = attackerPokemon
  else
    data = defenderData
    pokemonData = defenderPokemon
  end

  showMoveButtons(isAttacker)

  local pokemonFainted = false
  local effects = pokemonData.effects
  for i=1, #effects do
    if effects[i] == "KO" then
      printToAll(pokemonData.name .. " faints from Recoil")
      pokemonFaint(isAttacker, pokemonData)
      pokemonFainted = true
    end
  end
  if pokemonFainted == false then
    updateStatus(isAttacker, pokemonData.status)
  end
end

function playerLost(isAttacker)

  if isAttacker then
    data = attackerPokemon
  else
    data = defenderPokemon
  end

  printToAll(data.name .. " fainted!")
  pokemonFaint(isAttacker, data)
end


function gymWon()

  showMoveButtons(DEFENDER)

  local pokemonFainted = false
  for i=1, #defenderPokemon.effects do
    if defenderPokemon.effects[i] == "KO" then
      printToAll(defenderPokemon.name .. " faints from Recoil")
      gymLost()
      pokemonFainted = true
    end
  end
  if pokemonFainted == false then

    updateStatus(DEFENDER, defenderData.status)
  end

end

function gymLost()

  if defenderPokemon.name == defenderData.pokemon[2].name then
    printToAll(Player[attackerData.playerColor].steam_name .. " defeated " .. defenderData.trainerName)
    local gym = getObjectFromGUID(defenderData.gymGUID)
    gym.call("recall");
  else
    defenderPokemon = defenderData.pokemon[2]
    local gymCard = getObjectFromGUID(defenderData.guid)
    gymCard.flip()
    defenderData.attackValue.level = defenderPokemon.baseLevel

    updateMoves(DEFENDER, defenderPokemon)
  end
end


function trainerWon()

  showMoveButtons(ATTACKER)

  local pokemonFainted = false
  for i=1, #attackerPokemon.effects do
    if attackerPokemon.effects[i] == "KO" then
      printToAll(attackerPokemon.name .. " faints from Recoil")
      trainerLost()
      pokemonFainted = true
    end
  end
  if pokemonFainted == false then

    updateStatus(ATTACKER, attackerData.status)
  end
end

function trainerLost()

  printToAll(Player[defendPlayer.playerColor].steam_name .. " defeated Trainer")
  local pokeball = getObjectFromGUID(attackerData.pokeballGUID)
  pokeball.call("recall")
end


function wildPokemonWon()

  for i=1, #defenderPokemon.effects do
    if defenderPokemon.effects[i] == "KO" then
      printToAll(defenderPokemon.name .. " faints from Recoil")
      wildPokemonLost()
      return
    end
  end

  showMoveButtons(DEFENDER)
  updateStatus(DEFENDER, defenderData.status)
end

function wildPokemonLost()

  attackerData.wildPokemonGUID = nil
  clearPokemonData(DEFENDER)
  endBattle()

end

function pokemonFaint(isAttacker, data)

  -- Flip token
  local pokemon = getObjectFromGUID(data.pokemonGUID)
  local rotation = pokemon.getRotation()
  pokemon.setRotation({rotation.x, rotation.y, 180})

  -- Remove status
  if data.status ~= nil then
    local card = getObjectFromGUID(data.statusGUID)
    destroyObject(card)
    data.status = nil
  end

  -- Remove status counters
  local castParam = {}
  if isAttacker then
    castParam.origin = {attackerPos.statusCounters[1], 2, attackerPos.statusCounters[2]}
  else
    castParam.origin = {defenderPos.statusCounters[1], 2, defenderPos.statusCounters[2]}
  end

  castParam.direction = {0,-1,0}
  castParam.type = 1
  castParam.max_distance = 2
  castParam.debug = debug
  local hits = Physics.cast(castParam)
  if #hits ~= 0 then
    local counters = hits[1].hit_object
    if counters.hasTag("Status Counter") then
      counters.destruct()
    end
  end

  --recallArena({player = player, arenaAttack = isAttacker, zPos = -0.1})
end

function noPokemonInArena()
    print("There is no Pokémon in the Arena")
end

function attackMove1()
  selectMove(1, ATTACKER)
end

function attackMove2()
  selectMove(2, ATTACKER)
end

function attackMove3()
  selectMove(3, ATTACKER)
end

function defenceMove1()
  selectMove(1, DEFENDER)
end

function defenceMove2()
  selectMove(2, DEFENDER)
end

function defenceMove3()
  selectMove(3, DEFENDER)
end

function selectMove(index, isAttacker, isRandom)
  -- For safety, sanitize the isRandom parameter.
  if isRandom == nil then
    isRandom = false
  end

  local pokemon = nil
  local pokemonData = nil
  local moveData = nil
  local text = nil
  if isAttacker then
    pokemon = attackerPokemon
    pokemonData = attackerData
    moveData = attackerPokemon.movesData[index]
    attackerData.selectedMoveIndex = index
    text = getObjectFromGUID(atkText)
  else
    pokemon = defenderPokemon
    pokemonData = defenderData
    moveData = defenderPokemon.movesData[index]
    defenderData.selectedMoveIndex = index
    text = getObjectFromGUID(defText)
  end

  if moveData.status == DISABLED then
    return
  end

  -- Update the appropriate value counter.
  -- NOTE: could also leverage pokemonData.attackValue.attackRoll + pokemonData.attackValue.item here.
  pokemonData.attackValue.movePower = moveData.power

  -- Stab. If the pokemon is the same type then add 1 to the attack power.
  if type(pokemonData.attackValue.movePower) == "string" then pokemonData.attackValue.movePower = 0 end
  if (moveData.type == pokemon.types[1] or moveData.type == pokemon.types[2]) and pokemonData.attackValue.movePower > 0 and moveData.STAB then 
    pokemonData.attackValue.movePower = pokemonData.attackValue.movePower + 1 
  end

  -- Initialize the item value.
  pokemonData.attackValue.item = 0

  -- Check for a few different attach cards.
  if pokemon.vitamin then
    -- Vitamin. Tasty.
    pokemonData.attackValue.item = 1
  elseif pokemon.alpha then
    -- Alpha boy. Shudders.
    if pokemonData.attackValue.movePower > 3 then
      pokemonData.attackValue.item = 0
    elseif pokemonData.attackValue.movePower == 3 then
      pokemonData.attackValue.item = 1
    else
      pokemonData.attackValue.item = 2
    end
  elseif pokemon.type_booster == moveData.type and pokemonData.attackValue.movePower > 0 then
    -- Valid type booster.
    pokemonData.attackValue.item = 1
  end

  -- Calculate effectiveness.
  pokemonData.attackValue.effectiveness = DEFAULT
  local oppenent_data = isAttacker and defenderPokemon or attackerPokemon

  -- Get the opponent types.
  local opponent_types = { "N/A" }
  if oppenent_data ~= nil and oppenent_data.types ~= nil then
    opponent_types[1] = oppenent_data.types[1]
    if oppenent_data.types[2] ~= nil then
      opponent_types[2] = oppenent_data.types[2]
    else
      opponent_types[2] = "N/A"
    end
  end
  
  -- Get the typeData
  local typeData = Global.call("GetTypeDataByName", moveData.type)

  -- Detrermine if we are doing dual type effectiveness.
  local type_length = 1
  if Global.call("getDualTypeEffectiveness") then
    type_length = 2
  end
  
  -- Calculate the effectiveness of this move.
  for j=1, #typeData.effective do
    for type_index = 1, type_length do
      if typeData.effective[j] == opponent_types[type_index] then
        pokemonData.attackValue.effectiveness = pokemonData.attackValue.effectiveness + 2
      end
    end
  end
  for j=1, #typeData.weak do
    for type_index = 1, type_length do
      if typeData.weak[j] == opponent_types[type_index] then
        pokemonData.attackValue.effectiveness = pokemonData.attackValue.effectiveness - 2
      end
    end
  end

  -- When teratyping into the secondary type, it can cause Super-Effective/Weak. We don't want that.
  if Global.call("getDualTypeEffectiveness") and opponent_types[1] == opponent_types[2] then
    if pokemonData.attackValue.effectiveness == 4 then
      pokemonData.attackValue.effectiveness = 2
    elseif pokemonData.attackValue.effectiveness == -4 then
      pokemonData.attackValue.effectiveness = -2
    end
  end

  -- Super-Effective and Super-Weak are are +3/-3 respectively. So do a simple conversion.
  if pokemonData.attackValue.effectiveness == 4 then
    pokemonData.attackValue.effectiveness = 3
  elseif pokemonData.attackValue.effectiveness == -4 then
    pokemonData.attackValue.effectiveness = -3
  end

  -- Update the counter.
  calculateFinalAttack(isAttacker)

  -- Update the move text tool.
  local moveName = moveData.name
  text.TextTool.setValue(moveName)

  -- Get the active model GUID. This prevents calling animations for the wrong model.
  local model_guid = nil
  local pokemonData = isAttacker and attackerPokemon or defenderPokemon
  if pokemonData ~= nil then
    local chip_guid = isAttacker and attackerPokemon.pokemonGUID or defenderPokemon.pokemonGUID
    model_guid = Global.call("get_model_guid", chip_guid)
    if model_guid == nil then
      model_guid = pokemonData.model_GUID
    end
  end

  -- Call animations.
  if model_guid ~= nil and Global.call("get_models_enabled") then
    local model = getObjectFromGUID(model_guid)
    if model ~= nil then
      local triggerList = model.AssetBundle.getTriggerEffects()
      if triggerList ~= nil then
        local triggerListLength = #triggerList
        -- If triggerListLength is greater than x, we need to prevent choosing all the rubbish animations.
        -- 109, 110 and 111 are the attack indexes.
        if triggerListLength == 1 then
          local animationName = triggerList[1].name
          Global.call("try_activate_effect", {model=model, effectName=animationName or "Physical Attack"})
        elseif triggerListLength == 3 or triggerListLength == 4 then
          -- Stupid, slow motion Gen 9 models.
          local animationName = triggerList[1].name
          Global.call("try_activate_effect", {model=model, effectName=animationName})
        elseif triggerListLength < 100 then
          local animationName = triggerList[math.random(triggerListLength - 1)].name
          Global.call("try_activate_effect", {model=model, effectName=animationName or "Physical Attack"})
        else
          local animationName = triggerList[math.random(109, 111)].name
          Global.call("try_activate_effect", {model=model, effectName=animationName or "Physical Attack"})
        end
      end
    end
  end

  if battleState ~= SELECT_MOVE then
    local pokemonName = isAttacker and attackerPokemon.name or defenderPokemon.name
    if isRandom then
      printToAll(pokemonName .. " randomly used " .. moveName .. "!")
    else
      printToAll(pokemonName .. " used " .. moveName .. "!")
    end
    return
  end

  hideArenaMoveButtons(isAttacker)

  if isAttacker then
    attackerConfirmed = true
  else
    defenderConfirmed = true
  end

  if attackerConfirmed and defenderConfirmed then
    activateMoves()
  elseif attackerConfirmed and defenderData.type == GYM then
    if aiDifficulty == 2 then
      local randomMove = math.random(1,3)
      selectMove(randomMove, DEFENDER, true)
    end
  end
end

function activateMoves()

  -- Hide move buttons for pokemon that can't select a move
  hideArenaMoveButtons(ATTACKER)
  hideArenaMoveButtons(DEFENDER)

  setMoveData(ATTACKER)
  setMoveData(DEFENDER)

  if attackerData.selectedMoveData.effects ~= nil or defenderData.selectedMoveData.effects~= nil then
    activateEffects()
  end

  if battleState ~= ROLL_EFFECTS then

    setBattleState(ROLL_ATTACK)

    spawnDice(attackerData.selectedMoveData, ATTACKER, attackerPokemon.effects)
    spawnDice(defenderData.selectedMoveData, DEFENDER, defenderPokemon.effects)

    showConfirmButton(ATTACKER, "CONFIRM")
    showConfirmButton(DEFENDER, "CONFIRM")
  end
end

function setMoveData(isAttacker)

  if isAttacker then
    data = attackerData
    pokemonData = attackerPokemon
  else
    data = defenderData
    pokemonData = defenderPokemon
  end

  move = data.selectedMoveData
  moves = pokemonData.movesData
  moveIndex = data.selectedMoveIndex

  if move == nil then
    printToAll("setting move data")
    move = copyTable(moves[moveIndex])
    local moveName = move.name
    if moveName == "Mirror Move" then
      if isAttacker then
        move = copyTable(defenderMoves[defenderSelectedMove])
      else
        move = copyTable(attackerMoves[attackerSelectedMove])
      end
    end
  end

  local moveName = move.name
  local moveType = move.type

  -- Calculate Power
  local movePower
  if move.power == "Self" then
    movePower = math.floor((trainerData.level/2)+0.5)
  elseif move.power == "Enemy" then
    local oppData = isAttacker and defenderData or attackerData
    movePower = math.floor((oppData.level/2)+0.5)
  else
    movePower = move.power
  end
  if move.STAB == true then
    local types = pokemonData.types
    for i=1, #types do
      if types[1] == moveType then
        movePower = movePower + 1
        break
      end
    end
  end

  -- Calculate Effectiveness
  local effectiveness = 0
  if move.status == EFFECTIVE then
    effectiveness = effectiveness + 2
  elseif move.status == WEAK then
    effectiveness = effectiveness - 2
  end

  if isAttacker then
    attackerData.selectedMoveData = move
  else
    defenderData.selectedMoveData = move
  end

  data.attackValue.movePower = movePower
  data.attackValue.effectiveness = effectiveness

  updateAttackValue(isAttacker)
end


function activateEffects()

  local rollEffectsAttacker = requiresEffectDice(ATTACKER, attackerData.selectedMoveData.effects)
  local rollEffectsDefender = requiresEffectDice(DEFENDER, defenderData.selectedMoveData.effects)

  if rollEffectsAttacker or rollEffectsDefender then
    setBattleState(ROLL_EFFECTS)
  else
    triggerPlayerEffects()
  end
end

function requiresEffectDice(isAttacker, effects)

  if effects == nil then
    return false
  end

  local rollEffects = false
  for i = 1, #effects do
    effect = effects[i]
    if effect.chance ~= nil then
      if effectCanTrigger(isAttacker, effect.name) then
        spawnEffectDice(isAttacker)
        rollEffects = true
        showConfirmButton(isAttacker, "CONFIRM")
      end
    end
  end
  return rollEffects
end

function resolveEffects()

    triggerPlayerEffects()

    setBattleState(ROLL_ATTACK)

    updateStatus(ATTACKER, attackerData.status)
    updateStatus(DEFENDER, defenderData.status)

    clearDice(ATTACKER)
    clearDice(DEFENDER)

    spawnDice(attackerData.selectedMoveData, ATTACKER, attackerPokemon.effects)
    spawnDice(defenderData.selectedMoveData, DEFENDER, defenderPokemon.effects)

    showConfirmButton(ATTACKER, "CONFIRM")
    showConfirmButton(DEFENDER, "CONFIRM")
end


function triggerPlayerEffects()

  if attackerData.selectedMoveData.effects ~= nil then
    checkChance = #attackerData.dice > 0
    calculateEffects(ATTACKER, attackerData.selectedMoveData, checkChance)
  end
  if defenderData.selectedMoveData.effects ~= nil then
    checkChance = #defenderData.dice > 0
    calculateEffects(DEFENDER, defenderData.selectedMoveData, checkChance)
  end

end


function calculateEffects(isAttacker, move, checkChance)

  local diceValue = 0
  if checkChance then
    local dice = isAttacker and attackerData.dice[1] or defenderData.dice[1]
    diceValue = getObjectFromGUID(dice).getValue()
    clearDice(isAttacker)
  end

  local effects = move.effects
  local effect
  for i=1, #effects do
    local effect = effects[i]
    if effect.chance ~= nil then
      if diceValue >= effect.chance then
        triggerEffect(isAttacker, effect)
      end
    elseif effect.condition ~= nil then
      local oppAtkValue = isAttacker and attackerData.attackValue or defenderData.attackValue
      if effect.condition == "Power" and oppAtkValue.movePower > 0 then
        triggerEffect(isAttacker, effect)
      end
    else
      triggerEffect(isAttacker, effect)
    end
  end
end

function triggerEffect(isAttacker, effect)

  local effectName = effect.name
  if isStatus(effectName) then
    addStatus(not isAttacker, effectName)
  elseif effect.target == "Self" then
    addEffect(isAttacker, effectName)
  else
    addEffect(not isAttacker, effectName)
  end
end

function isStatus(effectName)
  if effectName == "Burn" or effectName == "Poison" or effectName == "Paralyse" or effectName == "Sleep" or effectName == "Confuse" or effectName == "Freeze" then
    return true
  else
    return false
  end
end

function addEffect(isAttacker, effect)

  if isAttacker then
    table.insert(attackerPokemon.effects, effect)
  else
    table.insert(defenderPokemon.effects, effect)
  end

end

function addStatus(isAttacker, status)

  local pos
  local data
  if isAttacker then
    pos = attackerPos
    data = attackerPokemon
  else
    pos = defenderPos
    data = defenderPokemon
  end

  if data.status ~= nil then
    printToAll("Pokémon already has a status.")
    return
  end

  local obj
  local resolveStatus = false
  if status == "Burn" then
    obj = getObjectFromGUID(statusGUID.burned)
  elseif status == "Paralyse" then
    obj = getObjectFromGUID(statusGUID.paralysed)
    resolveStatus = true
  elseif status == "Poison" then
    obj = getObjectFromGUID(statusGUID.poisoned)
  elseif status == "Sleep" then
    obj = getObjectFromGUID(statusGUID.sleep)
    resolveStatus = true
  elseif status == "Freeze" then
    obj = getObjectFromGUID(statusGUID.frozen)
  elseif status == "Confuse" then
    obj = getObjectFromGUID(statusGUID.confused)
  end
  local card = obj.takeObject()
  card.setPosition({pos.status[1], 1, pos.status[2]})

  if resolveStatus then
    setBattleState(RESOLVE_STATUS)
    showConfirmButton(isAttacker, "CONFIRM")
    spawnStatusDice(isAttacker)
  end

  data.status = status
  data.statusCardGUID = card.getGUID()
end

function effectCanTrigger(isAttacker, effect)

  local data = isAttacker and defenderData or attackerData

  if isStatus(effect) and data.status ~= nil then
    return false
  else
    return true
  end
end



function updateStatus(isAttacker, status)

  if status == nil then
    return
  elseif status == "Burn" then
    updateBurnStatus(isAttacker)
  elseif status == "Poison" then
    updatePoisonStatus(isAttacker)
  elseif status == "Sleep" then
    updateSleepStatus(isAttacker)
  elseif status == "Paralyse" then
    updateParalyseStatus(isAttacker)
  elseif status == "Freeze" then
    updateFreezeStatus(isAttacker)
  end

  print(tostring(isAttacker) .. "," .. status)
end

function updateBurnStatus(isAttacker)

  if battleState == ROLL_ATTACK then -- Lower move's power by 1
    local attackValue = isAttacker and attackerAttackValue or defenderAttackValue
    if attackValue.movePower > 0 then
      attackValue.movePower = attackValue.movePower - 1
    end
  elseif battleState == RESOLVE then -- Add status counter
    if isAttacker then
      passParams = {player = attackPlayer, arenaAttack = true, zPos = -0.1}
      data = attackerPokemon
      player = attackPlayer
    else
      passParams = {player = defendPlayer, arenaAttack = false, zPos = -0.1}
      data = defenderPokemon
      player = defendPlayer
    end
    if data.statusCounters == 3 then
      local pokemonName = data.name
      printToAll(pokemonName .. " faints from Burn")
      pokemonFaint(isAttacker, data)
    else
      addStatusCounter(passParams)
    end
  end
end

function updatePoisonStatus(isAttacker)

  if battleState == RESOLVE then -- Add status counter
    if isAttacker then
      passParams = {player = attackPlayer, arenaAttack = true, zPos = -0.1}
    else
      passParams = {player = defendPlayer, arenaAttack = false, zPos = -0.1}
    end
    addStatusCounter(passParams)
  end
end

function updateSleepStatus(isAttacker)

  if isAttacker then
    move = attackerMove
    data = attackerData
  else
    move = defenderMove
    data = defenderData
  end
  if battleState == SELECT_POKEMON then -- Remove status counter
    local numCounters = removeStatusCounter(isAttacker)
    if numCounters == 0 then
      removeStatus(data)
    else
      clearMoveData(isAttacker, " is fast asleep!")
    end
  elseif battleState == ROLL_ATTACK then
    if data.statusCounters > 0 then
      clearMoveData(isAttacker, " is fast asleep!")
    end
  end
end

function updateParalyseStatus(isAttacker)

  if battleState == RESOLVE then
      local statusCard = getObjectFromGUID(data.statusGUID)
      if statusCard.getRotation().z == 180 then
        statusCard.flip()
      end
  end
end

function updateFreezeStatus(isAttacker)

  if battleState == ROLL_ATTACK then
    clearMoveData(isAttacker, " is frozen solid!")
  end
end

function addStatusCounters(isAttacker, numCounters)

  if isAttacker then
    passParams = {player = attackPlayer, arenaAttack = true, zPos = -0.1}
  else
    passParams = {player = defendPlayer, arenaAttack = false, zPos = -0.1}
  end
  for i=1, numCounters do
    addStatusCounter(passParams)
  end
end

function removeStatus(data)
  data.status = nil
  local statusCard = getObjectFromGUID(data.statusGUID)
  statusCard.destruct()
  data.statusGUID = nil
end

function spawnEffectDice(isAttacker)

  local diceTable = isAttacker and attackerData.dice or defenderData.dice
  local pos = isAttacker and attackerPos or defenderPos
  diceBag = getObjectFromGUID(effectDice)
  dice = diceBag.takeObject()
  dice.setPosition({pos.moveDice[1], 2, pos.moveDice[2]})
  table.insert(diceTable, dice.guid)

  if isAITrainer(isAttacker) then
    dice.randomize()
  end
end

function spawnStatusDice(isAttacker)

  local diceTable = isAttacker and attackerDice or defenderDice
  local pos = isAttacker and attackerPos or defenderPos
  diceBag = getObjectFromGUID("7c6144")
  dice = diceBag.takeObject()
  dice.setPosition({pos.moveDice[1], 2, pos.moveDice[2]})
  table.insert(diceTable, dice.guid)

  if isAITrainer(isAttacker) then
    dice.randomize()
  end
end


function autoRollDice()

end

function spawnDice(move, isAttacker, effects)

  local diceTable = isAttacker and attackerData.dice or defenderData.dice
  local pos = isAttacker and attackerPos or defenderPos
  local diceBag
  local dice

  local numExtraDice = 0
  local diceMod = 0
  local effect
  for i=1, #effects do
    effect = effects[i]
    if effect == "ExtraDice" then
      numExtraDice = numExtraDice + 1
    elseif effect == "AttackUp" then
      diceMod = diceMod + 1
    elseif effect == "AttackUp2" then
      diceMod = diceMod + 2
    elseif effect == "AttackDown" then
      diceMod = diceMod - 1
    elseif effect == "AttackDown2" then
      diceMod = diceMod - 2
    end
  end

  local numDice = 1 + numExtraDice + math.abs(diceMod)

  if isAttacker then
    attackerDiceMod = diceMod
  else
    defenderDiceMod = diceMod
  end

  local diceBagGUID
  if move.dice == 6 then
    diceBagGUID = d6Dice
  elseif move.dice == 4 then
    diceBagGUID = d4Dice
  elseif move.dice == 8 then
    diceBagGUID = critDice
  end

  diceBag = getObjectFromGUID(diceBagGUID)
  local zPos = atkMoveZPos
  local diceWidth = (numDice-1) * 1.5
  local diceXPos = pos.moveDice[1] - (diceWidth * 0.5)

  for i=1, numDice do
    dice = diceBag.takeObject()
    dice.setPosition({diceXPos + ((i-1) * 1.5), 2, pos.moveDice[2]})
    table.insert(diceTable, dice.guid)
  end
end


function increaseAtkArena(obj, player_clicker_color)
    local playerColour = player_clicker_color
    if playerColour == attackerData.playerColor then
        passParams = {player = playerColour, arenaAttack = true, zPos = -0.1, modifier = 1}
        increaseArena(passParams)
    end
end

function decreaseAtkArena(obj, player_clicker_color)
    local playerColour = player_clicker_color
    if playerColour == attackerData.playerColor then
        passParams = {player = playerColour, arenaAttack = true, zPos = -0.1, modifier = -1}
        decreaseArena(passParams)
    end
end

function increaseDefArena(obj, player_clicker_color)
    local playerColour = player_clicker_color
    if playerColour == defenderData.playerColor then
        passParams = {player = playerColour, arenaAttack = false, zPos = -0.1, modifier = 1}
        increaseArena(passParams)
    end
end

function decreaseDefArena(obj, player_clicker_color)
    local playerColour = player_clicker_color
    if playerColour == defenderData.playerColor then
        passParams = {player = playerColour, arenaAttack = false, zPos = -0.1, modifier = -1}
        decreaseArena(passParams)
    end
end

function evolveAtk(obj, player_clicker_color)
    local playerColour = player_clicker_color
    if playerColour == attackerData.playerColor then
        passParams = {player = playerColour, arenaAttack = true, zPos = -0.1}
        evolve(passParams)
    end
end

function evolveTwoAtk(obj, player_clicker_color)
    local playerColour = player_clicker_color
    if playerColour == attackerData.playerColor then
        passParams = {player = playerColour, arenaAttack = true, zPos = -0.1}
        evolveTwo(passParams)
    end
end

function evolveDef(obj, player_clicker_color)
    local playerColour = player_clicker_color
    if playerColour == defenderData.playerColor then
        passParams = {player = playerColour, arenaAttack = false, zPos = -0.1}
        evolve(passParams)
    end
end

function evolveTwoDef(obj, player_clicker_color)
    local playerColour = player_clicker_color
    if playerColour == defenderData.playerColor then
        passParams = {player = playerColour, arenaAttack = false, zPos = -0.1}
        evolveTwo(passParams)
    end
end

function recallAtkArena(obj, player_clicker_color)
    local playerColour = player_clicker_color
    if playerColour == attackerData.playerColor then
        passParams = {player = playerColour, arenaAttack = true, zPos = -0.1}
        recallArena(passParams)
    end
end

function recallDefArena(obj, player_clicker_color)
    local playerColour = player_clicker_color
    if playerColour == defenderData.playerColor then
        passParams = {player = playerColour, arenaAttack = false, zPos = -0.1}
        recallArena(passParams)
    end
end

function addAtkStatus(obj, player_clicker_color)
    local playerColour = player_clicker_color
    if playerColour == attackerData.playerColor then
        passParams = {player = playerColour, arenaAttack = true, zPos = -0.1}
        addStatusCounter(passParams)
    end
end

function removeAtkStatus(obj, player_clicker_color)
    local playerColour = player_clicker_color
    if playerColour == attackerData.playerColor then
        passParams = {player = playerColour, arenaAttack = true, zPos = -0.1}
        removeStatusCounter(ATTACKER)
    end
end

function addDefStatus(obj, player_clicker_color)
    local playerColour = player_clicker_color
    if playerColour == defenderData.playerColor then
        passParams = {player = playerColour, arenaAttack = false, zPos = -0.1}
        addStatusCounter(passParams)
    end
end

function removeDefStatus(obj, player_clicker_color)
    local playerColour = player_clicker_color
    if playerColour == defenderData.playerColor then
        passParams = {player = playerColour, arenaAttack = false, zPos = -0.1}
        removeStatusCounter(DEFENDER)
    end
end

function evolve(params)
  local playerColour = params.player
  local attDefParams = {arenaAttack = params.arenaAttack, zPos = params.zPos}

  if playerColour == "Blue" then
    getObjectFromGUID(blueRack).call("evolveArena", attDefParams)
  elseif playerColour == "Green" then
    getObjectFromGUID(greenRack).call("evolveArena", attDefParams)
  elseif playerColour == "Orange" then
    getObjectFromGUID(orangeRack).call("evolveArena", attDefParams)
  elseif playerColour == "Purple" then
    getObjectFromGUID(purpleRack).call("evolveArena", attDefParams)
  elseif playerColour == "Red" then
    getObjectFromGUID(redRack).call("evolveArena", attDefParams)
  elseif playerColour == "Yellow" then
    getObjectFromGUID(yellowRack).call("evolveArena", attDefParams)
  end

  attDefParams = nil
end

function evolveTwo(passParams)
    local playerColour = passParams.player
    attDefParams = {arenaAttack = passParams.arenaAttack, zPos = passParams.zPos}

    if playerColour == "Blue" then
        getObjectFromGUID(blueRack).call("evolveTwoArena", attDefParams)
    elseif playerColour == "Green" then
        getObjectFromGUID(greenRack).call("evolveTwoArena", attDefParams)
    elseif playerColour == "Orange" then
        getObjectFromGUID(orangeRack).call("evolveTwoArena", attDefParams)
    elseif playerColour == "Purple" then
        getObjectFromGUID(purpleRack).call("evolveTwoArena", attDefParams)
    elseif playerColour == "Red" then
        getObjectFromGUID(redRack).call("evolveTwoArena", attDefParams)
    elseif playerColour == "Yellow" then
        getObjectFromGUID(yellowRack).call("evolveTwoArena", attDefParams)
    end

    attDefParams = nil
end

function recallArena(passParams)
  local playerColour = passParams.player
  attDefParams = {arenaAttack = passParams.arenaAttack, zPos = passParams.zPos}

  if playerColour == "Blue" then
    getObjectFromGUID(blueRack).call("rackRecall", attDefParams)
  elseif playerColour == "Green" then
    getObjectFromGUID(greenRack).call("rackRecall", attDefParams)
  elseif playerColour == "Orange" then
    getObjectFromGUID(orangeRack).call("rackRecall", attDefParams)
  elseif playerColour == "Purple" then
    getObjectFromGUID(purpleRack).call("rackRecall", attDefParams)
  elseif playerColour == "Red" then
    getObjectFromGUID(redRack).call("rackRecall")
  elseif playerColour == "Yellow" then
    getObjectFromGUID(yellowRack).call("rackRecall", attDefParams)
  end
end

function increaseArena(passParams)
  local playerColour = passParams.player
  mParams = {modifier = passParams.modifier, arenaAttack = passParams.arenaAttack}

  if playerColour == "Blue" then
    getObjectFromGUID(blueRack).call("increase", mParams)
  elseif playerColour == "Green" then
    getObjectFromGUID(greenRack).call("increase", mParams)
  elseif playerColour == "Orange" then
    getObjectFromGUID(orangeRack).call("increase", mParams)
  elseif playerColour == "Purple" then
    getObjectFromGUID(purpleRack).call("increase", mParams)
  elseif playerColour == "Red" then
    getObjectFromGUID(redRack).call("increase", mParams)
  elseif playerColour == "Yellow" then
    getObjectFromGUID(yellowRack).call("increase", mParams)
  end
end

function decreaseArena(passParams)
  local playerColour = passParams.player
  mParams = {modifier = passParams.modifier, arenaAttack = passParams.arenaAttack}

  if playerColour == "Blue" then
    getObjectFromGUID(blueRack).call("decrease", mParams)
  elseif playerColour == "Green" then
    getObjectFromGUID(greenRack).call("decrease", mParams)
  elseif playerColour == "Orange" then
    getObjectFromGUID(orangeRack).call("decrease", mParams)
  elseif playerColour == "Purple" then
    getObjectFromGUID(purpleRack).call("decrease", mParams)
  elseif playerColour == "Red" then
    getObjectFromGUID(redRack).call("decrease", mParams)
  elseif playerColour == "Yellow" then
    getObjectFromGUID(yellowRack).call("decrease", mParams)
  end
end

-- Move Camera Buttons

function seeAttackerRack(obj, player_clicker_color)
    viewTeam(obj, player_clicker_color, attackerData.playerColor)
end

function seeDefenderRack(obj, player_clicker_color)
    viewTeam(obj, player_clicker_color, defenderData.playerColor)
end

function viewTeam(obj, playerClicker, team)
  if team == "Blue" then
      showPosition = {x=-65,y=0.96,z=21.5}
      camYaw = 90
  elseif team == "Green" then
      showPosition = {x=-65,y=0.96,z=-21.5}
      camYaw = 90
  elseif team == "Orange" then
      showPosition = {x=65,y=0.96,z=21.5}
      camYaw = 270
  elseif team == "Purple" then
      showPosition = {x=65,y=0.96,z=-21.5}
      camYaw = 270
  elseif team == "Red" then
      showPosition = {x=21.50,y=0.14,z=-48}
      camYaw = 0
  elseif team == "Yellow" then
      showPosition = {x=-21.50,y=0.14,z=-48}
      camYaw = 0
  end

  Player[playerClicker].lookAt({
      position = showPosition,
      pitch    = 60,
      yaw      = camYaw,
      distance = 25
  })
end

function showArena(passParams)
    local playerColour = passParams.player_clicker_color
    Player[playerColour].lookAt({
        position = {x=-34.89,y=0.96,z=0},
        pitch    = 90,
        yaw      = 0,
        distance = 22
    })
end

function seeMoveRules(obj, player_clicker_color)
    local playerColour = player_clicker_color
    local showPosition

    if playerColour == "Yellow" then
        showPosition = {x=0.02,y=0.24,z=-55.5}
    elseif playerColour == "Green" then
        showPosition = {x=-72,y=0.14,z=0.75}
    elseif playerColour == "Orange" then
        showPosition = {x=72,y=0.14,z=0.88}
    elseif playerColour == "Purple" then
        showPosition = {x=72,y=0.14,z=0.88}
    elseif playerColour == "Red" then
        showPosition = {x=0.02,y=0.24,z=-55.5}
    elseif playerColour == "Blue" then
        showPosition = {x=-72,y=0.14,z=0.75}
    end

    Player[playerColour].lookAt({
        position = showPosition,
        pitch    = 90,
        yaw      = 0,
        distance = 22.5
    })
end

function sendToArenaGym(params)
  if defenderData.type ~= nil then
    print("There is already a Pokémon in the arena")
    return false
  elseif attackerData.type ~= nil and attackerData.type ~= PLAYER then
    return false
  end

  setTrainerType(DEFENDER, GYM, params)

  -- The model fields don't get passed in via params here because the gyms don't save it. Modifying all of
  -- files would make me very sad.
  local gymData = Global.call("GetGymDataByGUID", {guid=params.trainerGUID})

  -- Update pokemon info.
  local pokemonData = params.pokemon  -- This is a table with two pokemon.
  defenderPokemon = {}
  setNewPokemon(defenderPokemon, pokemonData[1], params.trainerGUID)
  defenderPokemon.model_GUID = gymData.pokemon[1].model_GUID
  defenderPokemon.pokemonGUID = params.trainerGUID
  defenderPokemon.pokemon2 = pokemonData[2]
  defenderPokemon.pokemon2.pokemonGUID = params.trainerGUID
  defenderPokemon.pokemon2.model_GUID = gymData.pokemon[2].model_GUID
  updateMoves(DEFENDER, defenderPokemon)

  -- Update the defender value counter.
  defenderData.attackValue.level = pokemonData[1].baseLevel
  updateAttackValue(DEFENDER)

  -- Gym Leader
  local takeParams = {guid = defenderData.trainerGUID, position = {defenderPos.item[1], 1.5, defenderPos.item[2]}, rotation={0,180,0}}
  local gym = getObjectFromGUID(params.gymGUID)
  local gymLeaderCard = gym.takeObject(takeParams)

  if params.isGymLeader then
    -- Take Badge
    takeParams = {position = {defenderPos.pokemon[1], 1.5, defenderPos.pokemon[2]}, rotation={0,180,0}}
    gym.takeObject(takeParams)

    Global.call("PlayGymBattleMusic",{})
  elseif params.isSilphCo then
    Global.call("PlaySilphCoBattleMusic",{})

    -- Take Masterball
    takeParams = {position = {defenderPos.pokemon[1], 1.5, defenderPos.pokemon[2]}, rotation={0,180,0}}
    gym.takeObject(takeParams)
  elseif params.isElite4 then
    Global.call("PlayFinalBattleMusic",{})
  elseif params.isRival then
    Global.call("PlayRivalMusic",{})
  else
    print("ERROR: uncertain which battle music to play")
    Global.call("PlayGymBattleMusic",{})
  end

  printToAll(defenderData.trainerName .. " wants to fight!", {r=246/255,g=192/255,b=15/255})

  inBattle = true

  -- Check if we can provide a recall button in the arena.
  -- gyms tiers: 1-8
  -- elite4    : 9
  -- champion  : 10
  -- TR        : 11
  if gymData.gymTier and gymData.gymTier >= 1 and gymData.gymTier <= 11 then
    -- Save off the relevent data.
    gymLeaderGuid = gymData.guid

    -- Move the button.
    self.editButton({index=15, position={recallDefPos.x, 0.4, recallDefPos.z}, click_function="recallGymLeader", label="RECALL", tooltip="Recall Gym Leader"})
  end

  if Global.call("get_models_enabled") then
    -- Reformat the data so that the model code can use it. (Sorry, I know this is hideous.) This is extra gross because
    -- I didn't feel like figuring out to fake allllll of the initialization process for RivalData models that may 
    -- never ever get seen for a game. Also it is extra complicated because we need two models per token.
    local pokemonModelData = {
      chip_GUID = params.trainerGUID,
      base = {
        name = defenderPokemon.name,
        created_before = false,
        in_creation = false,
        persistent_state = true,
        picked_up = false,
        despawn_time = 1.0,
        model_GUID = defenderPokemon.model_GUID,
        custom_rotation = {gymLeaderCard.getRotation().x, gymLeaderCard.getRotation().y, gymLeaderCard.getRotation().z}
      },
      picked_up = false,
      in_creation = false,
      scale_set = {},
      isTwoFaced = true
    }
    pokemonModelData.chip = params.trainerGUID

    -- Copy the base to a state.
    pokemonModelData.state = pokemonModelData.base

    -- Check if the params have field overrides.
    if gymData.pokemon[1].offset == nil then pokemonModelData.base.offset = {x=0, y=0, z=-0.17} else pokemonModelData.base.offset = gymData.pokemon[1].offset end
    if gymData.pokemon[1].custom_scale == nil then pokemonModelData.base.custom_scale = 1 else pokemonModelData.base.custom_scale = gymData.pokemon[1].custom_scale end
    if gymData.pokemon[1].idle_effect == nil then pokemonModelData.base.idle_effect = "Idle" else pokemonModelData.base.idle_effect = gymData.pokemon[1].idle_effect end
    if gymData.pokemon[1].spawn_effect == nil then pokemonModelData.base.spawn_effect = "Special Attack" else pokemonModelData.base.spawn_effect = gymData.pokemon[1].spawn_effect end
    if gymData.pokemon[1].run_effect == nil then pokemonModelData.base.run_effect = "Run" else pokemonModelData.base.run_effect = gymData.pokemon[1].run_effect end
    if gymData.pokemon[1].faint_effect == nil then pokemonModelData.base.faint_effect = "Faint" else pokemonModelData.base.faint_effect = gymData.pokemon[1].faint_effect end

    -- Add it to the active chips.
    local model_already_created = Global.call("add_to_active_chips_by_GUID", {guid=params.trainerGUID, data=pokemonModelData})
    pokemonModelData.base.created_before = model_already_created

    -- Wait until the gym leader card is idle.
    Wait.condition(
      function() -- Conditional function.
        -- Spawn in the model with the above arguments.
        Global.call("check_for_spawn_or_despawn", pokemonModelData)
      end,
      function() -- Condition function
        return gymLeaderCard ~= nil and gymLeaderCard.resting
      end,
      2,
      function() -- Timeout function.
        -- Spawn in the model with the above arguments. But this time the card is still moving, darn.
        Global.call("check_for_spawn_or_despawn", pokemonModelData)
      end
    )
    
    -- Sometimes the model gets placed upside down (I have no idea why lol). Detect it and fix it if needed.
    -- Sometimes models also get placed tilted backwards. Bah.
    Wait.condition(
      function() -- Conditional function.
        -- Get a handle to the model.
        local model_guid = Global.call("get_model_guid", params.trainerGUID)
        if model_guid == nil then return end
        local model = getObjectFromGUID(model_guid)
        if model ~= nil then
          local model_rotation = model.getRotation()
          if math.abs(model_rotation.z-180) < 1 or math.abs(model_rotation.x-0) then
            model.setRotation({0, model_rotation.y, 0})
          end
        end
      end,
      function() -- Condition function
        return Global.call("get_model_guid", params.trainerGUID) ~= nil
      end,
      2
    )
  end

  -- Lock the gym leader card in place.
  Wait.condition(
    function()
      -- Lock the gym leader card in place.
      gymLeaderCard.lock()
    end,
    function() -- Condition function
      return gymLeaderCard ~= nil and gymLeaderCard.resting
    end,
    2
  )

  -- Check if we spawn a secondary type token.
  if Global.call("getDualTypeEffectiveness") then
    -- Reformat the data so that the secondary type token code can use it.
    local secondary_token_data = {
      chip_GUID = params.trainerGUID,
      base = {
        name = defenderPokemon.name,
        created_before = false,
        in_creation = false,
        persistent_state = true,
        picked_up = false,
        types = defenderPokemon.types
      },
      picked_up = false,
      in_creation = false,
      isTwoFaced = true
    }
    secondary_token_data.chip = params.trainerGUID
    secondary_token_data.base.token_offset = {x=-0.1, y=0, z=1.0}

    -- Copy the base to a state.
    secondary_token_data.state = secondary_token_data.base

    Global.call("check_for_spawn_or_despawn_secondary_type_token", secondary_token_data)
  end

  if scriptingEnabled then
    defenderData.attackValue.level = defenderPokemon.baseLevel
    updateAttackValue(DEFENDER)

    aiDifficulty = Global.call("GetAIDifficulty")

    defenderConfirmed = true
    if attackerConfirmed then
      startBattle()
    end
  else
    showFlipGymButton(true)
    showConfirmButton(DEFENDER, "RANDOM MOVE")
  end

  return true
end

function recallGymLeader()
  -- Confirm we at least have a Gym Leader GUID.
  if not gymLeaderGuid then return end

  -- Get the data for this gym.
  local gymData = Global.call("GetGymDataByGUID", {guid=gymLeaderGuid})

  -- Remove the button.
  self.editButton({index=15, position={recallDefPos.x, 1000, recallDefPos.z}, click_function="recallDefArena", label="RECALL", tooltip="Recall Pokémon"})

  -- Confirm we have a gym tier.
  if not gymData or not gymData.gymTier then
    print("Unknown tier for this gym leader. You need to recall it conventionally. :(")
    return
  end

  -- Check if there is a secondary type token to despawn.
  if Global.call("getDualTypeEffectiveness") then
    local token_guid = Global.call("get_secondary_type_token_guid", gymLeaderGuid)
    if token_guid then
      Global.call("despawn_secondary_type_token", {pokemon=defenderPokemon, secondary_type_token=token_guid})
    end
  end

  -- Get a handle on the appropriate gym.
  local gym = getObjectFromGUID(gyms[gymData.gymTier])
  if not gym then
    print("Failed to get gym handle to allow a Gym Leader to recall. WHAT DID YOU DO?")
    return
  end

  -- Reset the Gym Leader GUID.
  gymLeaderGuid = nil

  -- Recall the Gym Leader.
  gym.call("recall")
end

function sendToArenaTrainer(params)
  if attackerData.type ~= nil then
    print("There is already a Pokémon in the arena")
    return false
  elseif defenderData.type ~= nil and defenderData.type ~= PLAYER then
    return false
  end

  -- Update attacker data.
  setTrainerType(ATTACKER, TRAINER, params)

  -- Update the buttons for the trainer battle. If this is second trainer fight, there is no need for a NEXT button. However, if users mix the two
  -- recall buttons then this button can get out of sync.
  self.editButton({index=2, position={recallAtkPos.x, 0.4, recallAtkPos.z}, click_function="recallTrainerHook", label="RECALL", tooltip="Recall Trainer"})
  if not isSecondTrainer then
    self.editButton({index=40, position={rivalFipButtonPos.x, 0.4, rivalFipButtonPos.z}, click_function="nextTrainerBattle", label="NEXT", tooltip="Next Trainer Fight"})
  end

  -- Trainer Pokemon.
  local takeParams = {position = {attackerPos.pokemon[1], 1.5, attackerPos.pokemon[2]}, rotation={0,180,0}}

  local pokeball = getObjectFromGUID(params.pokeballGUID)
  pokeball.shuffle()
  local pokemon = pokeball.takeObject(takeParams)
  local pokemonGUID = pokemon.getGUID()
  local pokemonData = Global.call("GetPokemonDataByGUID",{guid=pokemonGUID})
  attackerPokemon = {}
  setNewPokemon(attackerPokemon, pokemonData, pokemonGUID)

  inBattle = true
  Global.call("PlayTrainerBattleMusic",{})
  printToAll("Trainer wants to fight!", {r=246/255,g=192/255,b=15/255})

  updateMoves(ATTACKER, attackerPokemon)

  -- Update the attacker value counter.
  attackerData.attackValue.level = attackerPokemon.baseLevel
  updateAttackValue(ATTACKER)

   if scriptingEnabled then
      attackerData.attackValue.level = attackerPokemon.baseLevel
      updateAttackValue(ATTACKER)

      aiDifficulty = Global.call("GetAIDifficulty")

      attackerConfirmed = true
      if defenderConfirmed then
        startBattle()
      end
  else
    local numMoves = #attackerPokemon.moves
    if numMoves > 1 then
      showConfirmButton(ATTACKER, "RANDOM MOVE")
    end
  end

  if Global.call("get_models_enabled") then
    -- Since the trainers use normal tokens we can relay on normal model logic except that it will be 
    -- rotated 180 degrees from what we want.
    Wait.condition(
      function() -- Conditional function.
        -- Get a handle to the model.
        local model_guid = Global.call("get_model_guid", pokemonGUID)
        if model_guid == nil then return end
        local model = getObjectFromGUID(model_guid)
        local model_rotation = model.getRotation()
        if model ~= nil then
          model.setRotation({model_rotation.x, 0, model_rotation.z})
        end
      end,
      function() -- Condition function
        return Global.call("get_model_guid", pokemonGUID) ~= nil
      end,
      2
    )
  end

  -- Check if we spawn a secondary type token.
  if Global.call("getDualTypeEffectiveness") then
    -- Reformat the data so that the secondary type token code can use it.
    local secondary_token_data = {
      chip_GUID = pokemonGUID,
      base = {
        name = attackerPokemon.name,
        created_before = false,
        in_creation = false,
        persistent_state = true,
        picked_up = false,
        types = attackerPokemon.types
      },
      picked_up = false,
      in_creation = false,
      isTwoFaced = true
    }
    secondary_token_data.chip = pokemonGUID

    -- Copy the base to a state.
    secondary_token_data.state = secondary_token_data.base

    Global.call("check_for_spawn_or_despawn_secondary_type_token", secondary_token_data)
  end

  return true
end

function sendToArenaRival(params)
  if attackerData.type ~= nil then
    print("There is already a Pokémon in the arena")
    return false
  elseif defenderData.type ~= nil and defenderData.type ~= PLAYER then
    return false
  end

  setTrainerType(ATTACKER, RIVAL, params)

  -- Get the rival token.
  local takeParams = {guid = params.pokemonGUID, position = {attackerPos.pokemon[1], 0.96, attackerPos.pokemon[2]}, rotation={0,180,0}}
  local pokeball = getObjectFromGUID(params.pokeballGUID)
  local rivalToken = pokeball.takeObject(takeParams)
  
  -- Wait until the rival token is resting.
  Wait.condition(
    function()
      -- Do nothing.
    end,
    function() -- Condition function
      return rivalToken ~= nil and rivalToken.resting
    end,
    2
  )

  -- Do a sanity check.
  -- TODO: Becaise of how Wait.condition() works, this is likely pointless.
  if rivalToken == nil then
    print("Failed to fetch rival " .. params.trainerName)
  end

  -- Update battle state.
  inBattle = true
  Global.call("PlayTrainerBattleMusic",{})
  printToAll("Rival " .. params.trainerName .. " wants to fight!", {r=246/255, g=192/255, b=15/255})

  -- Move the button.
  self.editButton({index=2, position={recallAtkPos.x, 0.4, recallAtkPos.z}, click_function="recallRivalHook", label="RECALL", tooltip="Recall Rival"})
  
  -- Update pokemon info.
  local pokemonData = params.pokemonData  -- This is a table with two pokemon.
  attackerPokemon = {}
  setNewPokemon(attackerPokemon, pokemonData[1], params.pokemonGUID)
  attackerPokemon.pokemonGUID = params.pokemonGUID
  attackerPokemon.pokemon2 = pokemonData[2]
  attackerPokemon.pokemon2.pokemonGUID = params.pokemonGUID
  updateMoves(ATTACKER, attackerPokemon)

  -- Update the attacker value counter.
  attackerData.attackValue.level = attackerPokemon.baseLevel
  updateAttackValue(ATTACKER)
  
  if Global.call("get_models_enabled") then
    -- Reformat the data so that the model code can use it. (Sorry, I know this is hideous.) This is extra gross because
    -- I didn't feel like figuring out to fake allllll of the initialization process for RivalData models that may 
    -- never ever get seen for a game. Also it is extra complicated because we need two models per token.
    local pokemonModelData = {
      chip_GUID = params.pokemonGUID,
      base = {
        name = params.pokemonData[1].name,
        created_before = false,
        in_creation = false,
        persistent_state = true,
        picked_up = false,
        despawn_time = 1.0,
        model_GUID = attackerPokemon.model_GUID,
        custom_rotation = {rivalToken.getRotation().x, rivalToken.getRotation().y + 180.0, rivalToken.getRotation().z}
      },
      picked_up = false,
      in_creation = false,
      scale_set = {},
      isTwoFaced = true
    }
    pokemonModelData.chip = attackerPokemon.pokemonGUID

    -- Copy the base to a state.
    pokemonModelData.state = pokemonModelData.base

    -- Check if the params have field overrides.
    if params.offset == nil then pokemonModelData.base.offset = {x=0, y=0, z=-0.17} else pokemonModelData.base.offset = params.offset end
    if params.custom_scale == nil then pokemonModelData.base.custom_scale = 1 else pokemonModelData.base.custom_scale = params.custom_scale end
    if params.idle_effect == nil then pokemonModelData.base.idle_effect = "Idle" else pokemonModelData.base.idle_effect = params.idle_effect end
    if params.spawn_effect == nil then pokemonModelData.base.spawn_effect = "Special Attack" else pokemonModelData.base.spawn_effect = params.spawn_effect end
    if params.run_effect == nil then pokemonModelData.base.run_effect = "Run" else pokemonModelData.base.run_effect = params.run_effect end
    if params.faint_effect == nil then pokemonModelData.base.faint_effect = "Faint" else pokemonModelData.base.faint_effect = params.faint_effect end

    -- Add it to the active chips.
    local model_already_created = Global.call("add_to_active_chips_by_GUID", {guid=params.pokemonGUID, data=pokemonModelData})

    -- Spawn in the model with the above arguments.
    pokemonModelData.base.created_before = model_already_created
    Global.call("check_for_spawn_or_despawn", pokemonModelData)
  end

  -- Check if we spawn a secondary type token.
  if Global.call("getDualTypeEffectiveness") then
    -- Reformat the data so that the secondary type token code can use it.
    local secondary_token_data = {
      chip_GUID = params.pokemonGUID,
      base = {
        name = params.pokemonData[1].name,
        created_before = false,
        in_creation = false,
        persistent_state = true,
        picked_up = false,
        types = params.pokemonData[1].types
      },
      picked_up = false,
      in_creation = false,
      isTwoFaced = true
    }
    secondary_token_data.chip = params.pokemonGUID
    secondary_token_data.base.token_offset = {x=0.1, y=0, z=0.7}

    -- Copy the base to a state.
    secondary_token_data.state = secondary_token_data.base

    Global.call("check_for_spawn_or_despawn_secondary_type_token", secondary_token_data)
  end

  -- Lock the rival in place.
  Wait.condition(
    function()
      -- Unlock the rival in place.
      rivalToken.lock()
    end,
    function() -- Condition function
      return rivalToken ~= nil and rivalToken.resting
    end,
    2
  )

  -- Update a few buttons.
  showFlipRivalButton(true)
  showConfirmButton(ATTACKER, "RANDOM MOVE")

  return true
end

function recallTrainer(params)
  -- Remove both buttons.
  self.editButton({index=2, position={recallAtkPos.x, 1000, recallAtkPos.z}, click_function="recallAtkArena", label="RECALL", tooltip=""})
  self.editButton({index=40, position={rivalFipButtonPos.x, 1000, rivalFipButtonPos.z}, click_function="flipRivalPokemon", tooltip=""})

  local trainerPokemon = getObjectFromGUID(attackerPokemon.pokemonGUID)

  -- Check if there is a secondary type token to despawn.
  if Global.call("getDualTypeEffectiveness") then
    local token_guid = Global.call("get_secondary_type_token_guid", attackerPokemon.pokemonGUID)
    if token_guid then
      Global.call("despawn_secondary_type_token", {pokemon=attackerPokemon, secondary_type_token=token_guid})
    end
  end

  local pokeball = getObjectFromGUID(attackerData.pokeballGUID)
  pokeball.putObject(trainerPokemon)
  pokeball.shuffle()

  text = getObjectFromGUID(atkText)
  text.setValue(" ")

  if scriptingEnabled == false then
    hideConfirmButton(ATTACKER)
  end

  showAttackerTeraButton(false)
  clearPokemonData(ATTACKER)
  clearTrainerData(ATTACKER)
end

function recallGym()
  -- Reformat the data so that the model code can use it. (Sorry, I know this is hideous.) This is extra gross because
  -- I didn't feel like figuring out to fake allllll of the initialization process for RivalData models that may 
  -- never ever get seen for a game. Also it is extra complicated because we need two models per token.
  if Global.call("get_models_enabled") then
    -- Get the active model GUID. This prevents despawning the wrong model.
    local model_guid = Global.call("get_model_guid", defenderPokemon.pokemonGUID)
    if model_guid == nil then
      model_guid = defenderPokemon.model_GUID
    end

    -- Generate the despawn data.
    local despawn_data = {
      chip = defenderPokemon.pokemonGUID,
      state = defenderPokemon,
      base = defenderPokemon,
      model = model_guid
    }

    -- Despawn the (hopefully) correct model via its GUID.
    Global.call("despawn_now", despawn_data)
  end

  -- Get a handle of the gym and gym leader.
  local gymLeader = getObjectFromGUID(defenderData.trainerGUID)
  gymLeader.unlock()

  -- If we were flipped, flip it back. This prevents the model from spawning in upside down next time.
  if not Global.call("isFaceUp", gymLeader) then
    gymLeader.flip()
  end

  -- Remove this chip from the active list.
  Global.call("remove_from_active_chips_by_GUID", defenderPokemon.pokemonGUID)

  -- Check if there is a secondary type token to despawn.
  if Global.call("getDualTypeEffectiveness") then
    local token_guid = Global.call("get_secondary_type_token_guid", defenderPokemon.pokemonGUID)
    if token_guid then
      Global.call("despawn_secondary_type_token", {pokemon=defenderPokemon, secondary_type_token=token_guid})
    end
  end

  local gym = getObjectFromGUID(defenderData.gymGUID)
  Wait.condition(
    function()
      -- Put the gym leader back in its gym.
       gym.putObject(gymLeader)
    end,
    function() -- Condition function
      return gymLeader.resting
    end,
    3,
    -- Timeout function.
    function()
     -- Put the gym leader back in its gym.
      local gym = getObjectFromGUID(defenderData.gymGUID)
      if gym then
        gym.putObject(gymLeader)
      end
    end
  )

  -- Collect Badge if it hasn't been taken
  local param = {}
  param.direction = {0,-1,0}
  param.type = 1
  param.max_distance = 1
  param.debug = debug
  param.origin = {defenderPos.pokemon[1], 1.1, defenderPos.pokemon[2]}
  hits = Physics.cast(param)
  if #hits ~= 0 then
    local badge = hits[1].hit_object
    if badge.hasTag("Badge") then
      gym.putObject(badge)
    end
  end

  if scriptingEnabled == false then
    showFlipGymButton(false)
    hideConfirmButton(DEFENDER)
  end

  clearPokemonData(DEFENDER)
  clearTrainerData(DEFENDER)

  -- Clear the texts.
  clearMoveText(ATTACKER)
  clearMoveText(DEFENDER)
end

function recallRival()
  -- Get the active model GUID. This prevents despawning the wrong model.
  local model_guid = Global.call("get_model_guid", attackerPokemon.pokemonGUID)
  if model_guid == nil then
    model_guid = attackerPokemon.model_GUID
  end

  -- Reformat the data so that the model code can use it. (Sorry, I know this is hideous.) This is extra gross because
  -- I didn't feel like figuring out to fake allllll of the initialization process for RivalData models that may 
  -- never ever get seen for a game. Also it is extra complicated because we need two models per token.
  if Global.call("get_models_enabled") then
    local despawn_data = {
      chip = attackerPokemon.pokemonGUID,
      state = attackerPokemon,
      base = attackerPokemon,
      model = model_guid
    }

    Global.call("despawn_now", despawn_data)
  end

  -- Check if there is a secondary type token to despawn.
  if Global.call("getDualTypeEffectiveness") then
    local token_guid = Global.call("get_secondary_type_token_guid", attackerPokemon.pokemonGUID)
    if token_guid then
      Global.call("despawn_secondary_type_token", {pokemon=attackerPokemon, secondary_type_token=token_guid})
    end
  end

  -- Get the rival token object and unlock it in place.
  local rivalToken = getObjectFromGUID(attackerPokemon.pokemonGUID)
  rivalToken.unlock()

  -- If we were flipped, flip it back. This prevents the model from spawning in upside down next time.
  if not Global.call("isFaceUp", rivalToken) then
    rivalToken.flip()
  end

  -- Remove this chip from the active list.
  Global.call("remove_from_active_chips_by_GUID", attackerPokemon.pokemonGUID)

  -- Save the pokeball GUID.
  local pokeballGUID = attackerData.pokeballGUID

  Wait.condition(
    function()
      -- Put the rival token back in its pokeball.
      local pokeball = getObjectFromGUID(pokeballGUID)
      pokeball.putObject(rivalToken)
    end,
    function() -- Condition function
      return rivalToken.resting
    end,
    2,
    -- Timeout function.
    function()
      -- Put the rival token back in its pokeball.
      local pokeball = getObjectFromGUID(pokeballGUID)
      pokeball.putObject(rivalToken)
    end
  )

  -- Clear the texts.
  clearMoveText(ATTACKER)
  clearMoveText(DEFENDER)

  if scriptingEnabled == false then
    hideConfirmButton(ATTACKER)
  end

  clearPokemonData(ATTACKER)
  clearTrainerData(ATTACKER)
  showFlipRivalButton(false)
end

-- Basic helper function that hooks into the Rival Pokeball and calls its recall function.
-- The Rival Pokeball recall function then calls recallRival(). :D
function recallRivalHook()
  -- Get a handle on the rival event pokeball.
  local rivalEventPokeball = getObjectFromGUID("432e69")
  if not rivalEventPokeball then
    print("Failed to get Pokéball handle to allow a Rival Event to recall. WHAT DID YOU DO?")
    return
  end

  -- Remove the button.
  self.editButton({index=2, position={recallAtkPos.x, 1000, recallAtkPos.z}, click_function="recallAtkArena", label="RECALL", tooltip=""})

  -- Recall the Gym Leader.
  rivalEventPokeball.call("recall")
end

-- Basic helper function that hooks into the appropriate Pokeball and calls its recall function.
-- The Pokeball recall function then calls recallTrainer(). :D
function recallTrainerHook()
  -- Remove both buttons.
  self.editButton({index=2, position={recallAtkPos.x, 1000, recallAtkPos.z}, click_function="recallAtkArena", label="RECALL", tooltip=""})
  self.editButton({index=40, position={rivalFipButtonPos.x, 1000, rivalFipButtonPos.z}, click_function="flipRivalPokemon", tooltip=""})

  -- Update the isSecondTrainer flag.
  isSecondTrainer = false

  -- Check if we at least have a pokeball GUID.
  if not attackerData or not attackerData.pokeballGUID then
    print("Unknown home for this Pokémon. You need to recall it conventionally. :(")
    return
  end

  -- Get a handle on the appropriate pokeball.
  local pokeball = getObjectFromGUID(attackerData.pokeballGUID)
  if not pokeball then
    print("Failed to get Pokéball handle to allow a trainer to recall. WHAT DID YOU DO?")
    return
  end

  -- Recall this Pokemon.
  pokeball.call("recall")
end

-- Basic helper function that allows a trainer to send in one more pokemon for the double trainer
-- battles.
function nextTrainerBattle()
  -- Hide this button, since there is only ever a Trainer Battle (2) at most.
  self.editButton({index=40, position={rivalFipButtonPos.x, 1000, rivalFipButtonPos.z}, click_function="flipRivalPokemon", tooltip=""})

  -- Update the isSecondTrainer flag.
  isSecondTrainer = true

  -- Check if we at least have a pokeball GUID.
  if not attackerData or not attackerData.pokeballGUID then
    -- Failed to recall like this. Remove the button and have the user recall normally.
    self.editButton({index=2, position={recallAtkPos.x, 1000, recallAtkPos.z}, click_function="recallAtkArena", label="RECALL", tooltip=""})

    print("Unknown home for this Pokémon. You need to recall it conventionally. :(")
    return
  end

  -- Get a handle on the appropriate pokeball.
  local pokeball = getObjectFromGUID(attackerData.pokeballGUID)
  if not pokeball then
    print("Failed to get Pokéball handle to allow a trainer to send another Pokémon. WHAT DID YOU DO?")
    return
  end

  -- Check if there is a secondary type token to despawn.
  if Global.call("getDualTypeEffectiveness") then
    local token_guid = Global.call("get_secondary_type_token_guid", attackerPokemon.pokemonGUID)
    if token_guid then
      Global.call("despawn_secondary_type_token", {pokemon=attackerPokemon, secondary_type_token=token_guid})
    end
  end

  -- Recall this Pokemon.
  pokeball.call("recall")

  -- Send another Pokemon to battle.
  Wait.time(function() pokeball.call("battle") end, 0.3)
end

function sendToArena(params)
    local isAttacker = params.isAttacker
    local arenaData = isAttacker and attackerPokemon or defenderPokemon
    local pokemonData = params.slotData
    local rack = getObjectFromGUID(params.rackGUID)

    -- Get pokemon. The model may not be present here.
    local pokemon = getObjectFromGUID(pokemonData.pokemonGUID)

    if not Global.call("isFaceUp", pokemon) then
      print("Cannot send a fainted Pokémon to the arena")
      return
    elseif attackerPokemon ~= nil and isAttacker or defenderPokemon ~= nil and not isAttacker then
      print("There is already a Pokémon in the arena")
      return
    end

    -- Auto-pan the camera if selected.
    if params.autoCamera then
      Player[params.playerColour].lookAt({position = {x=-34.89,y=0.96,z=0.8}, pitch = 90, yaw = 0, distance = 22})
    end

    -- Send the Pokemon to the arena.
    local arenaPos = isAttacker and attackerPos or defenderPos
    pokemon.setPosition({arenaPos.pokemon[1], 0.96, arenaPos.pokemon[2]})
    pokemon.setRotation({pokemon.getRotation().x + params.xRotSend, pokemon.getRotation().y + params.yRotSend, pokemon.getRotation().z + params.zRotSend})
    pokemon.setLock(true)

    -- Get the active model GUID. This prevents despawning the wrong model.
    local model_guid = Global.call("get_model_guid", pokemonData.pokemonGUID)
    if model_guid == nil then
      model_guid = pokemonData.model_GUID
    end

    -- Assign the chip to the GUID.
    pokemonData.chip = pokemonData.pokemonGUID

    -- Send the pokemon model to the arena, if present.
    local pokemonModel = getObjectFromGUID(model_guid)
    if pokemonModel ~= nil and Global.call("get_models_enabled") then
      -- Reformat the data so that the model code can use it. (Sorry, I know this is hideous.)
      pokemonData.base = {offset = pokemonData.offset}
      pokemonModel.setPosition(Global.call("model_position", pokemonData))
      local modelYRotSend = params.yRotSend
      if isAttacker then
        modelYRotSend = modelYRotSend - 180.0
      end
      pokemonModel.setRotation({pokemonModel.getRotation().x + params.xRotSend, pokemonModel.getRotation().y + modelYRotSend, pokemonModel.getRotation().z + params.zRotSend})
      pokemonModel.setLock(true)
    end

    -- Check if we need to send out secondary type tokens.
    Global.call("move_secondary_type_token", pokemonData)

    -- Level Die
    local diceLevel = 0
    if pokemonData.levelDiceGUID ~= nil then
        local dice = getObjectFromGUID(pokemonData.levelDiceGUID)
        dice.setPosition({arenaPos.dice[1], 1.37, arenaPos.dice[2]})
        dice.setRotation({dice.getRotation().x + params.xRotSend, dice.getRotation().y + params.yRotSend, dice.getRotation().z + params.zRotSend})
        diceLevel = dice.getValue()
    end

    local castParams = {}
    castParams.direction = {0,-1,0}
    castParams.type = 1
    castParams.max_distance = 1
    castParams.debug = debug
    castParams.max_distance = 0.74

    -- Status
    local origin = {params.pokemonXPos[params.index], 0.95, params.statusZPos}
    castParams.origin = rack.positionToWorld(origin)
    local statusHits = Physics.cast(castParams)
    if #statusHits ~= 0 then
        local status = getObjectFromGUID(statusHits[1].hit_object.guid)
        status.setPosition({arenaPos.status[1], 1.03, arenaPos.status[2]})
        status.setRotation({0, 180, 0})
    end

    -- Status Counters
    origin = {params.pokemonXPos[params.index] + 0.21, 0.95, params.pokemonZPos - 0.137}
    castParams.origin = rack.positionToWorld(origin)

    local tokenHits = Physics.cast(castParams)
    if #tokenHits ~= 0 then
        local statusCounters = getObjectFromGUID(tokenHits[1].hit_object.guid)
        statusCounters.setPosition({arenaPos.statusCounters[1], 1.03, arenaPos.statusCounters[2]})
        statusCounters.setRotation({0, 180, 0})
    end

    -- Initialize tmCard and zCrystalCard variables.
    pokemonData.tmCard = false
    pokemonData.zCrystalCard = false

    -- Item
    local pokemonMoves = pokemonData.moves
    origin = {params.pokemonXPos[params.index], 0.95, params.itemZPos}
    castParams.origin = rack.positionToWorld(origin)
    local itemHits = Physics.cast(castParams)
    local hasTMCard = false
    local cardMoveData = nil
    local teraType = nil
    if #itemHits ~= 0 then
      local itemCard = getObjectFromGUID(itemHits[1].hit_object.guid)
      if itemCard.hasTag("Item") then
        pokemonData.itemCardGUID = itemCard.getGUID()
        itemCard.setPosition({arenaPos.item[1], 1.03, arenaPos.item[2]})
        itemCard.setRotation({0, 180, 0})

        if itemCard.hasTag("TM") then
          pokemonData.tmCard = true
          local tmData = Global.call("GetTmDataByGUID", itemCard.getGUID())
          if tmData ~= nil then
            cardMoveData = copyTable(Global.call("GetMoveDataByName", tmData.move))
          end
        elseif itemCard.hasTag("ZCrystal") then
          pokemonData.zCrystalCard = true
          local zCrystalData = Global.call("GetZCrystalDataByGUID", {zCrystalGuid=itemCard.getGUID(), pokemonGuid=pokemonData.pokemonGUID})
          if zCrystalData ~= nil then
            cardMoveData = copyTable(Global.call("GetMoveDataByName", zCrystalData.move))
            cardMoveData.name = zCrystalData.displayName
          end
        elseif itemCard.hasTag("TeraType") then
          pokemonData.teraType = true
          local teraData = Global.call("GetTeraDataByGUID", itemCard.getGUID())
          if teraData ~= nil then
            if isAttacker then
              teraType = teraData.type
              showAttackerTeraButton(true, pokemonData.types[1])
            else
              teraType = teraData.type
              showDefenderTeraButton(true, pokemonData.types[1])
            end
          end
        elseif itemCard and itemCard.getName() == "Vitamin" then
          pokemonData.vitamin = true
        elseif itemCard and itemCard.getName() == "Alpha" then
          pokemonData.alpha = true
        elseif itemCard and itemCard.getName() then
          pokemonData.type_booster = typeBoosterLookupTable[itemCard.getName()]
        end
      end
    end

    if hasTMCard == false and pokemonMoves[1].isTM then
      table.remove(pokemonMoves,1)
    end

    -- Announce the trainer sending their Pokemon.
    if Player[params.playerColour].steam_name ~= nil then
      if not pokemonData.alpha then
        printToAll(Player[params.playerColour].steam_name .. " sent out " .. pokemonData.name, stringColorToRGB(params.playerColour))
      else
        printToAll(Player[params.playerColour].steam_name .. " sent out Alpha " .. pokemonData.name, stringColorToRGB(params.playerColour))
      end
    else
      if not pokemonData.alpha then
        printToAll("This Player sent out " .. pokemonData.name, stringColorToRGB(params.playerColour))
      else
        printToAll("This Player sent out Alpha " .. pokemonData.name, stringColorToRGB(params.playerColour))
      end
    end

    local buttonParams = {
        index = params.index,
        yLoc = params.yLoc,
        zLoc = params.zLoc,
        pokemonXPos = params.pokemonXPos,
        pokemonZPos = params.pokemonZPos,
        rackGUID = params.rackGUID
    }

    -- Hide all rack buttons apart from the recall button
    hideAllRackButtons(buttonParams)
    local recallIndex = 4 + (params.index * 8) - 3
    rack.editButton({index=recallIndex, position={-1.47 + ((params.index - 1) * 0.59), 0.21, params.zLoc}, rotation={0,0,0}, click_function="rackRecall", tooltip="Recall Pokémon"})

    if isAttacker then
        showAtkButtons(true)
        attackerPokemon = pokemonData
        attackerPokemon.teraType = teraType
    else
        showDefButtons(true)
        defenderPokemon = pokemonData
        defenderPokemon.teraType = teraType
    end
    setTrainerType(isAttacker, PLAYER, {playerColor=params.playerColour})

    updateEvolveButtons(params, pokemonData, diceLevel)

    updateMoves(params.isAttacker, pokemonData, cardMoveData)

    -- Update the appropriate value counter.
    if isAttacker then
      attackerData.attackValue.level = pokemonData.baseLevel + pokemonData.diceLevel
    else
      defenderData.attackValue.level = pokemonData.baseLevel + pokemonData.diceLevel
    end
    updateAttackValue(params.isAttacker)

    if scriptingEnabled then
      showConfirmButton(params.isAttacker, "CONFIRM")
    elseif attackerPokemon ~= nil and defenderPokemon ~= nil and inBattle == false then
      inBattle = true
      Global.call("PlayTrainerBattleMusic",{})
    end
end

function setTrainerType(isAttacker, type, params)

  clearTrainerData(isAttacker)
  local data = isAttacker and attackerData or defenderData
  data.type = type
  if type == PLAYER then
    data.playerColor = params.playerColor
  elseif type == TRAINER then
    data.pokeballGUID = params.pokeballGUID
  elseif type == GYM then
    data.trainerName = params.trainerName
    data.gymGUID = params.gymGUID
    data.pokemon = params.pokemon
    data.trainerGUID = params.trainerGUID
  elseif type == RIVAL then
    data.trainerName = params.trainerName
    data.pokeballGUID = params.pokeballGUID
    data.pokemon = params.pokemonData
    data.pokemonGUID = params.pokemonGuid
  end
end

function resetTrainerData(isAttacker)

  if isAttacker then
    data = attackerData
  else
    data = defenderData
  end

  data.dice = {}
  data.previousMove = {}
  data.canSelectMove = true
  data.selectedMove = -1
  data.moveData = {}
  data.diceMod = 0
  data.attackValue = {level=0, movePower=0, effectiveness=0, attackRoll=0, item=0, total=0}
end

function clearTrainerData(isAttacker)

  if isAttacker then
    attackerData = {}
  else
    defenderData = {}
  end

  resetTrainerData(isAttacker)
end


function recall(params)
    if scriptingEnabled and battleState ~= SELECT_POKEMON and battleState ~= NO_BATTLE then
      printToAll("Cannot recall pokemon in the middle of a battle")
      return
    end

    local isAttacker = params.isAttacker
    local rack = getObjectFromGUID(params.rackGUID)
    local pokemonData = isAttacker and attackerPokemon or defenderPokemon
    local arenaPos = isAttacker and attackerPos or defenderPos

    text = getObjectFromGUID(isAttacker and atkText or defText)
    text.setValue(" ")

    if params.autoCamera then
      Player[params.playerColour].lookAt({position = params.rackPosition, pitch = 60, yaw = 360 + params.yRotRecall, distance = 25})
    end

    -- Pokemon token recall.
    local pokemon = getObjectFromGUID(pokemonData.pokemonGUID)
    local position = rack.positionToWorld({params.pokemonXPos[params.index], 0.5, params.pokemonZPos})
    pokemon.setPosition(position)
    pokemon.setRotation({pokemon.getRotation().x + params.xRotRecall, pokemon.getRotation().y + params.yRotRecall, pokemon.getRotation().z + params.zRotRecall})
    pokemon.setLock(false)

    -- Get the active model GUID. This prevents despawning the wrong model.
    local model_guid = Global.call("get_model_guid", pokemonData.pokemonGUID)
    if model_guid == nil then
      model_guid = pokemonData.model_GUID
    end

    -- Assign the chip to the GUID.
    pokemonData.chip = pokemonData.pokemonGUID

    -- Move the model back to the rack. Since the token moved first, we can just copy its position and rotation.
    local pokemonModel = getObjectFromGUID(model_guid)
    if pokemonModel ~= nil and Global.call("get_models_enabled") then
      -- Reformat the data so that the model code can use it. (Sorry, I know this is hideous.)
      pokemonData.base = {offset = pokemonData.offset}

      Wait.condition(
        function() -- Conditional function.
          -- Move the model.
          pokemonModel.setPosition(Global.call("model_position", pokemonData))
          pokemonModel.setRotation({pokemon.getRotation().x, pokemon.getRotation().y, pokemon.getRotation().z})
          pokemonModel.setLock(true)
        end,
        function() -- Condition function
          return pokemon ~= nil and pokemon.resting
        end,
        2,
        function() -- Timeout function.
          -- Move the model. But the token is still moving, darn.
          pokemonModel.setPosition(Global.call("model_position", pokemonData))
          pokemonModel.setRotation({pokemon.getRotation().x, pokemon.getRotation().y, pokemon.getRotation().z})
          pokemonModel.setLock(true)
        end
      )
    end

    -- Check if we need to send out secondary type tokens.
    Global.call("move_secondary_type_token", pokemonData)

    -- Level Die
    if pokemonData.levelDiceGUID ~= nil then
      local dice = getObjectFromGUID(pokemonData.levelDiceGUID)
      position = {params.pokemonXPos[params.index] - levelDiceXOffset, 1, params.pokemonZPos - levelDiceZOffset}
      dice.setPosition(rack.positionToWorld(position))
      dice.setRotation({dice.getRotation().x + params.xRotRecall, dice.getRotation().y + params.yRotRecall, dice.getRotation().z + params.zRotRecall})
      dice.setLock(false)
    end

    local castParams = {}
    castParams.direction = {0,-1,0}
    castParams.type = 1
    castParams.max_distance = 1
    castParams.debug = debug

    -- Status
    castParams.origin = {arenaPos.status[1], 1, arenaPos.status[2]}
    local statusHits = Physics.cast(castParams)
    if #statusHits ~= 0 then
        local hit = statusHits[1].hit_object
        if hit.name ~= "Table_Custom" and hit.hasTag("Status") then
          local status = getObjectFromGUID(hit.guid)
          position = {params.pokemonXPos[params.index], 0.5, params.statusZPos}
          status.setPosition(rack.positionToWorld(position))
          status.setRotation({status.getRotation().x + params.xRotRecall, status.getRotation().y + params.yRotRecall, status.getRotation().z + params.zRotRecall})
        end
    end

    -- Status Tokens
    castParams.origin = {arenaPos.statusCounters[1], 2, arenaPos.statusCounters[2]}
    local tokenHits = Physics.cast(castParams)
    if #tokenHits ~= 0 then
        obj = getObjectFromGUID(tokenHits[1].hit_object.guid)
        position = {params.pokemonXPos[params.index] + 0.206, 0.5, params.pokemonZPos - 0.137}
        obj.setPosition(rack.positionToWorld(position))
        obj.setRotation({obj.getRotation().x + params.xRotRecall, obj.getRotation().y + params.yRotRecall, obj.getRotation().z + params.zRotRecall})
    end

    -- Item
    castParams.origin = {arenaPos.item[1], 1, arenaPos.item[2]}
    local itemHits = Physics.cast(castParams)
    if #itemHits ~= 0 then
        local hit = itemHits[1].hit_object
        if hit.name ~= "Table_Custom" and hit.hasTag("Item") then
          local item = getObjectFromGUID(hit.guid)
          position = {params.pokemonXPos[params.index], 0.5, params.itemZPos}
          item.setPosition(rack.positionToWorld(position))
          item.setRotation({item.getRotation().x + params.xRotRecall, item.getRotation().y + params.yRotRecall, item.getRotation().z + params.zRotRecall})
          item.setLock(false)
        end
    end

    local buttonParams = {
        index = params.index,
        yLoc = params.yLoc,
        zLoc = params.zLoc,
        pokemonXPos = params.pokemonXPos,
        pokemonZPos = params.pokemonZPos,
        xPos = -1.6 + ( 0.59 * (params.index - 1)),
        originGUID = params.originGUID
    }

    local recallIndex = 4 + (params.index * 8) - 3
    rack.editButton({index=recallIndex, position={-1.47 + ((buttonParams.index - 1) * 0.59), 1000, buttonParams.zLoc}, rotation={0,0,0}, click_function="nothing", tooltip="" })

    clearPokemonData(isAttacker)

    if isAttacker then
      showAttackerTeraButton(false)
    else
      showDefenderTeraButton(false)
    end

    if battleState ~= NO_BATTLE then
      showConfirmButton(isAttacker, "FORFEIT")
    else
      hideConfirmButton(isAttacker)
    end

    rack.call("rackRefreshPokemon")
end


function clearPokemonData(isAttacker)

  if isAttacker then
      showAtkButtons(false)
      attackerPokemon = nil
  else
      showDefButtons(false)
      defenderPokemon = nil
  end

  if attackerPokemon == nil and defenderPokemon == nil then
    endBattle()
  end

  hideArenaEffectiness(not isAttacker)

  -- Clear the attack counter even without scripting.
  clearAttackCounter(isAttacker)

  if scriptingEnabled then
    clearDice(isAttacker)

    if battleState ~= NO_BATTLE then
      setBattleState(SELECT_POKEMON)
    end
  end
end

function endBattle()
  if battleState == NO_BATTLE and scriptingEnabled then
    return
  end

  showAttackerTeraButton(false)
  showDefenderTeraButton(false)

  clearTrainerData(ATTACKER)
  clearTrainerData(DEFENDER)

  setRound(0)
  setBattleState(NO_BATTLE)

  if inBattle then
    Global.call("PlayRouteMusic")
    inBattle = false
  end
end

function setRound(round)

  currRound = round
  local roundTextfield = getObjectFromGUID(roundText)
  if round == 0 then
    roundTextfield.TextTool.setValue(" ")
  else
    roundTextfield.TextTool.setValue(tostring(round))
  end
end

function clearDice(isAttacker)

  local diceTable = isAttacker and attackerData.dice or defenderData.dice

  for i=#diceTable, 1, -1 do
    local dice = getObjectFromGUID(diceTable[i])
    dice.destruct()
    table.remove(diceTable, i)
  end
end

function updateMoves(isAttacker, data, cardMoveData)

  showMoveButtons(isAttacker, cardMoveData)
  updateTypeEffectiveness()

end


function updateTypeEffectiveness()

  if attackerPokemon == nil or defenderPokemon == nil then
    return
  end

  -- Attacker
  calculateEffectiveness(ATTACKER, attackerPokemon.movesData, defenderPokemon.types)

  -- Defender
  calculateEffectiveness(DEFENDER, defenderPokemon.movesData, attackerPokemon.types)
end


function calculateEffectiveness(isAttacker, moves, opponent_types)

  if isAttacker then
    moveText = atkMoveText
    textZPos = -8.65
    canUseMoves = attackerData.canSelectMove
  else
    moveText = defMoveText
    textZPos = 8.43
    canUseMoves = defenderData.canSelectMove
  end
  local numMoves = #moves
  local buttonWidths = (numMoves*3.2) + ((numMoves-1) + 0.5)

  for i=1, 3 do

    local moveText = getObjectFromGUID(moveText[i])
    moveText.TextTool.setValue(" ")

    if moves[i] ~= nil then

      local moveData = moves[i]
      local xPos = -33.99 - (buttonWidths * 0.5)
      moveText.setPosition({xPos + (3.7*(i-1)), 1, textZPos})
      moveData.status = DEFAULT

      if canUseMoves == false then
        moveText.TextTool.setValue("Disabled")
        moveData.status = DISABLED
      else
        -- If move had NEUTRAL effect, don't calculate Effectiveness
        local calculateEffectiveness = true
        if moveData.effects ~= nil then
          for i=1, #moveData.effects do
              if moveData.effects[i].name == "Neutral" then
                calculateEffectiveness = false
                break
              end
          end
        end

        if calculateEffectiveness then
          -- Get the type data.
          local typeData = Global.call("GetTypeDataByName", moveData.type)

          -- Detrermine if we are doing dual type effectiveness.
          local type_length = 1
          if Global.call("getDualTypeEffectiveness") then
            type_length = 2
          end

          -- Intitialize the effectiveness score.
          local effectiveness_score = 0

          for j=1, #typeData.effective do
            for type_index = 1, type_length do
              if typeData.effective[j] == opponent_types[type_index] then
                effectiveness_score = effectiveness_score + 2
              end
            end
          end

          for j=1, #typeData.weak do
            for type_index = 1, type_length do
              if typeData.weak[j] == opponent_types[type_index] then
                effectiveness_score = effectiveness_score - 2
              end
            end
          end

          -- When teratyping into the secondary type, it can cause Super-Effective/Weak. We don't want that.
          if Global.call("getDualTypeEffectiveness") and opponent_types[1] == opponent_types[2] then
            if effectiveness_score == 4 then
              effectiveness_score = 2
            elseif effectiveness_score == -4 then
              effectiveness_score = -2
            end
          end

          -- Use the effectiveness score.
          if effectiveness_score == 4 then 
            moveText.TextTool.setValue("Super-Effective")
            moveData.status = SUPER_EFFECTIVE
          elseif effectiveness_score == 2 then 
            moveText.TextTool.setValue("Effective")
            moveData.status = EFFECTIVE
          elseif effectiveness_score == -2 then 
            moveText.TextTool.setValue("Weak")
            moveData.status = WEAK
          elseif effectiveness_score == -4 then 
            moveText.TextTool.setValue("Super-Weak")
            moveData.status = SUPER_WEAK
          end

        end
      end
    end
  end
end

function isAITrainer(isAttacker)

  local type = isAttacker and attackerType or defenderType
  if aiDifficulty > 0 and type == GYM then
    return true
  elseif aiDifficulty > 0 and type == TRAINER then
    return true
  else
    return false
  end
end

function copyTable (original)
  local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = copyTable(v)
		end
		copy[k] = v
	end
	return copy
end

function updateAttackValue(isAttacker)
  local atkVal = nil
  local counterGUID = nil
  if isAttacker then
    counterGUID = atkCounter
    atkVal = attackerData.attackValue
  else
    counterGUID = defCounter
    atkVal = defenderData.attackValue
  end

  local totalAttack = atkVal.level + atkVal.movePower + atkVal.effectiveness + atkVal.attackRoll + atkVal.item
  local counter = getObjectFromGUID(counterGUID)
  counter.Counter.setValue(totalAttack)
end

function clearAttackCounter(isAttacker)
  local counterGUID = isAttacker and atkCounter or defCounter
  local counter = getObjectFromGUID(counterGUID)
  counter.Counter.setValue(0)
end

function setLevel(params)

  local slotData = params.slotData

  if params.modifier == 0 then
      return slotData
  end

  -- Get current Level from the dice
  local diceLevel = 0
  local newDiceLevel = 0
  local levelDice
  if slotData.levelDiceGUID ~= nil then
      levelDice = getObjectFromGUID(slotData.levelDiceGUID)
      if levelDice ~= nil then
        diceLevel = levelDice.getValue()
      end
  end

  newDiceLevel = diceLevel + params.modifier

  if newDiceLevel < 0 then
      return slotData
  elseif diceLevel == 6 and params.modifier > 0 then
    print("Pokémon at maximum level")
    return slotData
  end

  -- Update Level Dice
  -- We have already got the dice info when calculating the current level
  slotData.levelDiceGUID = updateLevelDice(diceLevel, newDiceLevel, params, levelDice)
  slotData.diceLevel = newDiceLevel

  -- Update Evolve Buttons
  if multiEvolving then
    hideEvoButtons(params)
  else
    updateEvolveButtons(params, slotData, newDiceLevel)
  end

  local level = slotData.baseLevel + slotData.diceLevel
  if params.modifier > 0 then
      if Player[params.playerColour].steam_name ~= nil then
          printToAll(Player[params.playerColour].steam_name .. "'s " .. slotData.name .. " grew to level " .. level .. "!", stringColorToRGB(params.playerColour))
      else
          printToAll("This Player's " .. slotData.name .. " grew to level " .. level .. "!", stringColorToRGB(params.playerColour))
      end
  end

  if params.inArena then
    if params.isAttacker then
      slotData.itemGUID = attackerPokemon.itemGUID
      attackerPokemon.levelDiceGUID = slotData.levelDiceGUID
      attackerPokemon.diceLevel = slotData.diceLevel
      attackerData.attackValue.level = level
    else
      slotData.itemGUID = defenderPokemon.itemGUID
      defenderPokemon.levelDiceGUID = slotData.levelDiceGUID
      defenderPokemon.diceLevel = slotData.diceLevel
      defenderData.attackValue.level = level
    end
    updateAttackValue(params.isAttacker)
  end

  return slotData
end

function updateEvolveButtons(params, slotData, level)
  -- Check if we have even started the game yet. <.<
  local starterPokeball = getObjectFromGUID("ec1e4b")
  if starterPokeball ~= nil then
    return false
  end

  local buttonParams = {
    inArena = params.inArena,
    isAttacker = params.isAttacker,
    index = params.index,
    yLoc = params.yLoc,
    pokemonXPos = params.pokemonXPos,
    pokemonZPos = params.pokemonZPos,
    rackGUID = params.rackGUID
  }

  local selectedGens = Global.call("GetSelectedGens")
  local evoData = slotData.evoData

  local evoList = {}
  if evoData ~= nil then
    for i=1, #evoData do
      local evolution = evoData[i]
      -- If the ball is 8, this is a fossil pokemon so we always allow it to evolve. Or evolution gen is lower than first gen selected
      if selectedGens[evolution.gen] or evolution.ball == 8 or evolution.gen < Global.call("GetFirstGenSelected") then
        if type(evolution.cost) == "string" then
          for _, evoGuid in ipairs(evolution.guids) do
            local evoData = Global.call("GetAnyPokemonDataByGUID",{guid=evoGuid})
            if evoData == nil then
              break
            end

            -- Insert evo option into the table.
            table.insert(evoList, evolution)

            -- Print the correct evolution instructions.
            if evolution.cost == "Mega" then
              printToAll("Mega Bracelet required and Mega Stone must be attached to evolve into " .. evoData.name)
            elseif evolution.cost == "GMax" then
              printToAll("Dynamax Band required to evolve into " .. evoData.name)
            else
              printToAll(evolution.cost .. " required to be played or attached to evolve into " .. evoData.name)
            end
            break
          end
        elseif evolution.cost <= level then
          table.insert(evoList, evolution)
        end
      else
        for _, evoGuid in ipairs(evolution.guids) do
          local unallowedPokemon = Global.call("GetAnyPokemonDataByGUID",{guid=evoGuid})
          printToAll("Evolving to " .. tostring(unallowedPokemon.name) .. " not available due to gen " .. tostring(evolution.gen) .. " not being enabled")
          break
        end
      end
    end
  end
  local numEvos = #evoList
  if numEvos > 0 then
    buttonParams.numEvos = numEvos
    if numEvos == 2 then
      for i=1, #evoList do
        local evoPokemon = Global.call("GetPokemonDataByGUID", {guid=evoList[i].guids[1]})
        if i == 1 then
          buttonParams.evoName = evoPokemon.name
        else
          buttonParams.evoNameTwo = evoPokemon.name
        end
      end
    else
      local evoPokemon = Global.call("GetPokemonDataByGUID", {guid=evoList[1].guids[1]})
      buttonParams.pokemonName = slotData.name
      buttonParams.evoName = evoPokemon.name
    end
    hideEvoButtons(buttonParams)
    updateEvoButtons(buttonParams)
  else
    hideEvoButtons(buttonParams)
  end
end

function evolvePoke(params)
    -- Check if we have even started the game yet. <.<
    local starterPokeball = getObjectFromGUID("ec1e4b")
    if starterPokeball ~= nil then
      printToAll("You need to start the game before evolving Pokémon")
      return false
    end

    -- Init some params.
    local pokemonData = params.slotData
    local selectedGens = Global.call("GetSelectedGens")
    local rack = getObjectFromGUID(params.rackGUID)
    local evolvedPokemon
    local evolvedPokemonGUID
    local evolvedPokemonData
    local diceLevel = pokemonData.diceLevel

    -- Put away the old token.
    local evolvingPokemon = getObjectFromGUID(pokemonData.pokemonGUID)
    local evolvedPokeball = getObjectFromGUID(evolvedPokeballGUID)
    evolvedPokeball.putObject(evolvingPokemon)

    local evoList = {}
    for i=1, #pokemonData.evoData do
      local evolution = pokemonData.evoData[i]
      if type(evolution.cost) == "string" then
        for _, evoGuid in ipairs(evolution.guids) do
          table.insert(evoList, evolution)
          break
        end
      elseif evolution.cost <= diceLevel then
        -- If the ball is 8, this is a fossil pokemon so we always allow it to evolve. Or evolution gen is lower than first gen selected
        if selectedGens[evolution.gen] or evolution.ball == 8 or evolution.gen < Global.call("GetFirstGenSelected") then
          table.insert(evoList, evolution)
        else
          for _, evoGuid in ipairs(evolution.guids) do
            local unallowedPokemon = Global.call("GetAnyPokemonDataByGUID",{guid=evoGuid})
            printToAll("Evolving to " .. tostring(unallowedPokemon.name) .. " not available due to gen " .. tostring(evolution.gen) .. " not being enabled")
            break
          end
        end
      end
    end
    -- Check if there is a secondary type token to despawn.
    if Global.call("getDualTypeEffectiveness") then
      local token_guid = Global.call("get_secondary_type_token_guid", pokemonData.pokemonGUID)
      if token_guid then
        Global.call("despawn_secondary_type_token", {pokemon=pokemonData, secondary_type_token=token_guid})
      end
    end

    if #evoList > 2 then -- More than 2 evos available so we need to spread them out
      -- Use this to keep track of the evos already retrieved, by name.
      local evosRetreivedTable = {}

      local numEvos = #evoList
      local evoNum = 0
      local tokensWidth = ((numEvos * 2.8) + ((numEvos-1) * 0.2) )
      for i=1, #evoList do
        local evoGUIDS = evoList[i].guids
        local pokeball = getObjectFromGUID(evolvePokeballGUID[evoList[i].ball])
        local pokemonInPokeball = pokeball.getObjects()
        for j=1, #pokemonInPokeball do
          local pokeObj = pokemonInPokeball[j]
          for k=1, #evoGUIDS do
            if pokeObj.guid == evoGUIDS[k] then
              local evoPokeData = Global.call("GetPokemonDataByGUID",{guid=pokeObj.guid})

              -- Check if we even need to retrieve this pokemon.
              local continueCheck = true
              for collectedEvoIndex=1, #evosRetreivedTable do
                if evosRetreivedTable[collectedEvoIndex] == evoPokeData.name then
                  continueCheck = false
                  break
                end
              end
              if continueCheck then
                local xPos = 1.4 + (evoNum * 3) - (tokensWidth * 0.5)
                evolvedPokemon = pokeball.takeObject({guid=pokeObj.guid, position={xPos, 1, -28}})
                if evolvedPokemon.guid ~= nil then
                  evoNum = evoNum + 1
                  --table.insert(multiEvoData, evoData)

                  -- Insert this pokemon into the table of retrieved pokemon.
                  table.insert(evosRetreivedTable, evoPokeData.name)
                  break
                end
              end
            end
          end
        end
        if evoList[i].cycle ~= nil and evoList[i].cycle and evoNum < numEvos then
          local extraPokeball = getObjectFromGUID(evolvedPokeballGUID)
          local pokemonInPokeball = extraPokeball.getObjects()
          for j=1, #pokemonInPokeball do
            local pokeObj = pokemonInPokeball[j]
            for k=1, #evoGUIDS do
              if pokeObj.guid == evoGUIDS[k] then
                local evoPokeData = Global.call("GetPokemonDataByGUID",{guid=pokeObj.guid})
                
                -- Check if we even need to retrieve this pokemon.
                local continueCheck = true
                for collectedEvoIndex=1, #evosRetreivedTable do
                  if evosRetreivedTable[collectedEvoIndex] == evoPokeData.name then
                    continueCheck = false
                    break
                  end
                end
                if continueCheck then
                  local xPos = 1.4 + (evoNum * 3) - (tokensWidth * 0.5)
                  local position = {xPos, 1, -28}
                  evolvedPokemon = extraPokeball.takeObject({guid=pokeObj.guid, position=position})
                  if evolvedPokemon.guid ~= nil then
                    evoNum = evoNum + 1
                    --table.insert(multiEvoData, evoData)

                    -- Insert this pokemon into the table of retrieved pokemon.
                    table.insert(evosRetreivedTable, evoPokeData.name)
                    break
                  end
                end
              end
            end
          end
        end
      end

      multiEvolving = true
      multiEvoData.params = params
      multiEvoData.pokemonData = evoList
      showMultiEvoButtons(multiEvoData.pokemonData)

      return nil

    else

      local evoData = evoList[params.oneOrTwo]
      local evoGUIDS = evoData.guids

      -- If the cycle field is present, that indicates that the pokemon may not be in the standard evo pokeball.
      -- The is relevant in scenarios where:
      --    pokemon evolve cyclically (Morpeko & GMax/Mega)
      if evoData.cycle ~= nil and evoData.cycle then
        local overriddenPokeball = getObjectFromGUID(evolvedPokeballGUID)
        local pokemonInSpecialPokeball = overriddenPokeball.getObjects()

        for i=1, #pokemonInSpecialPokeball do
          pokeObj = pokemonInSpecialPokeball[i]
          local pokeGUID = pokeObj.guid
          for j=1, #evoGUIDS do
            if pokeGUID == evoGUIDS[j] then
              evolvedPokemonData = Global.call("GetPokemonDataByGUID",{guid=pokeGUID})
              evolvedPokemon = overriddenPokeball.takeObject({guid=pokeGUID})
              evolvedPokemonGUID = pokeGUID
              break
            end
          end

          if evolvedPokemon ~= nil then
            break
          end
        end
      end

      if evolvedPokemon == nil then
        local pokeball = getObjectFromGUID(evolvePokeballGUID[evoData.ball])
        local pokemonInPokeball = pokeball.getObjects()
        for i=1, #pokemonInPokeball do
            pokeObj = pokemonInPokeball[i]
            local pokeGUID = pokeObj.guid
            for j=1, #evoGUIDS do
              if pokeGUID == evoGUIDS[j] then
                evolvedPokemonData = Global.call("GetPokemonDataByGUID",{guid=pokeGUID})
                evolvedPokemon = pokeball.takeObject({guid=pokeGUID})
                evolvedPokemonGUID = pokeGUID
                break
              end
            end

            if evolvedPokemon ~= nil then
              break
            end
        end
      end
      
      -- Update the pokemon data.
      setNewPokemon(pokemonData, evolvedPokemonData, evolvedPokemonGUID)

      if params.inArena then
        -- Pokemon is in the arena.

        -- Clear the appropriate move selected text.
        clearMoveText(params.isAttacker)

        -- Save off the arena data for potential tera info.
        local arenaData = params.isAttacker and attackerPokemon or defenderPokemon

        -- Get the position and set the evo pokemon.
        local tokenPosition = params.isAttacker and attackerPos or defenderPos
        local data = params.isAttacker and attackerPokemon or defenderPokemon
        setNewPokemon(data, evolvedPokemonData, evolvedPokemonGUID)
        local position = {tokenPosition.pokemon[1], 2, tokenPosition.pokemon[2]}
        evolvedPokemon.setPosition(position)

        -- Check if there is an attach card present.
        local cardMoveData = nil
        if arenaData.itemCardGUID ~= nil then
          -- Get a reference to the item card.
          local item_card = getObjectFromGUID(arenaData.itemCardGUID)

          -- Check if the attached card is a TM card.
          if arenaData.tmCard then
            local moveData = Global.call("GetTmDataByGUID", arenaData.itemCardGUID)
            if moveData ~= nil then
              cardMoveData = copyTable(Global.call("GetMoveDataByName", moveData.move))
            end
          -- Check if the attached card is a Z-Crystal card.
          elseif arenaData.zCrystalCard then
            local moveData = Global.call("GetZCrystalDataByGUID", {zCrystalGuid=arenaData.itemCardGUID, pokemonGuid=nil})
            if moveData ~= nil then
              cardMoveData = copyTable(Global.call("GetMoveDataByName", moveData.move))
              cardMoveData.name = moveData.displayName
            end
          elseif arenaData.teraType then
            local teraData = Global.call("GetTeraDataByGUID", arenaData.itemCardGUID)
            if teraData ~= nil then
              -- NOTE: If we ever do dual-type effectiveness this gets much more complicated.
              if params.isAttacker then
                arenaData.teraType = teraData.type
                showAttackerTeraButton(false)
                showAttackerTeraButton(true, attackerPokemon.types[1])
              else
                arenaData.teraType = teraData.type
                showDefenderTeraButton(false)
                showDefenderTeraButton(true, defenderPokemon.types[1])
              end
            end
          elseif item_card and item_card.getName() == "Vitamin" then
            arenaData.vitamin = true
          elseif item_card and item_card.getName() == "Alpha" then
            arenaData.alpha = true
          elseif item_card and item_card.getName() then
            arenaData.type_booster = typeBoosterLookupTable[item_card.getName()]
          end
        end

        updateMoves(params.isAttacker, pokemonData, cardMoveData)

        -- Check if we are expecting a model.
        if pokemonData.model_GUID ~= nil then
          -- Get the spawn delay.
          local spawn_delay = Global.call("get_spawn_delay")

          -- This function will just give the model spawn delay + 1 seconds to spawn in.
          Wait.condition(
            function()
              -- Handle the model, if present.
              local pokemonModel = getObjectFromGUID(pokemonData.model_GUID)
              if pokemonModel ~= nil then
                local modelYRotSend = 0
                if params.isAttacker then
                  modelYRotSend = 180.0
                end
                -- Reformat the data so that the model code can use it. (Sorry, I know this is hideous.)
                evolvedPokemonData.chip = evolvedPokemonGUID
                evolvedPokemonData.base = {offset = evolvedPokemonData.offset}
                pokemonModel.setPosition(Global.call("model_position", evolvedPokemonData))
                pokemonModel.setRotation({pokemonModel.getRotation().x, pokemonModel.getRotation().y + modelYRotSend, pokemonModel.getRotation().z})
                pokemonModel.setLock(true)
              end
            end,
            function() -- Condition function
              return getObjectFromGUID(pokemonData.model_GUID) ~= nil
            end,
            spawn_delay + 1 -- timeout
          )
        end
      else
        -- Pokemon is not in the arena.

        -- Get the position and set the evo pokemon.
        local position = {params.pokemonXPos[params.index], 1, params.pokemonZPos}
        local rotation = {0, 0 + params.evolveRotation, 0}
        evolvedPokemon.setPosition(rack.positionToWorld(position))
        evolvedPokemon.setRotation(rotation)

        -- Rotate the model rotation.
        local pokemonModel = getObjectFromGUID(pokemonData.model_GUID)
        if pokemonModel ~= nil then
          pokemonModel.setRotation(rotation)
        end
      end

      -- Update the evo buttons.
      local evolveButtonParams = {
        inArena = params.inArena,
        isAttacker = params.isAttacker,
        index = params.index,
        yLoc = 0.21,
        pokemonXPos = params.pokemonXPos,
        pokemonZPos = params.pokemonZPos,
        rackGUID = params.rackGUID
      }
      updateEvolveButtons(evolveButtonParams, evolvedPokemonData, diceLevel)

      return pokemonData
    end
end

function refreshPokemon(params)
    local xPos
    local startIndex = 0
    local hits
    local updatedRackData = {}
    local rack = getObjectFromGUID(params.rackGUID)

    local xPositions = params.pokemonXPos
    local buttonParams = {
        yLoc = params.yLoc,
        zLoc = params.zLoc,
        pokemonXPos = xPositions,
        pokemonZPos = params.pokemonZPos,
        rackGUID = params.rackGUID
    }

    local castParams = {}
    castParams.direction = {0,-1,0}
    castParams.type = 1
    castParams.max_distance = 0.7
    castParams.debug = debug

    -- Check Each Slot to see if it contains a Pokémon
    for i=1, #xPositions do
        local newSlotData = params.rackData[i]

        xPos = -1.6 + ( 0.59 * (i - 1))
        buttonParams.xPos = xPos
        buttonParams.index = i

        local origin = {xPositions[i], 0.94, params.pokemonZPos}
        castParams.origin = rack.positionToWorld(origin)
        hits = Physics.cast(castParams)

        if #hits ~= 0 then
          -- Show slot buttons
          showRackSlotButtons(buttonParams)

          -- Get the pokemon token data.
          local pokemonGUID = hits[1].hit_object.guid
          local data = Global.call("GetPokemonDataByGUID",{guid=pokemonGUID})

          -- If we didn't find pokemon data, it might be bacause models are enabled and the first item detected was a model.
          if data == nil then
            if Global.call("get_models_enabled") and #hits >= 2 then
              pokemonGUID = hits[2].hit_object.guid
              data = Global.call("GetPokemonDataByGUID",{guid=pokemonGUID})
            end
          end

          if data ~= nil then
            setNewPokemon(newSlotData, data, pokemonGUID)
            newSlotData.numStatusCounters = 0
            newSlotData.roundEffects = {}
            newSlotData.battleEffects = {}
            newSlotData.modifiers = {}
          else
            -- TODO: add this print out to each call to GetPokemonDataByGUID.
            print("No Pokémon Data Found for GUID: " .. tostring(pokemonGUID))
          end

          local origin = {xPositions[i] - levelDiceXOffset, 1.5, params.pokemonZPos - levelDiceZOffset}
          castParams.origin = rack.positionToWorld(origin)
          hits = Physics.cast(castParams)

          -- Calculate level + Show Evolve Button
          if #hits ~= 0 then
              newSlotData.levelDiceGUID = hits[1].hit_object.guid
              local levelDice = hits[1].hit_object
              local diceValue = levelDice.getValue()
              newSlotData.diceLevel = diceValue

              params.index = i
              params.inArena = false
              updateEvolveButtons(params, newSlotData, diceValue)
          else
              newSlotData.levelDiceGUID = nil
              newSlotData.diceLevel = 0

              params.index = i
              params.inArena = false
              updateEvolveButtons(params, newSlotData, 0)
          end
        elseif #hits == 0 then -- Empty Slot

            hideRackEvoButtons(buttonParams)
            hideRackSlotButtons(buttonParams)

            if newSlotData.levelDiceGUID ~= nil then
              --local levelDice = getObjectFromGUID(newSlotData.levelDiceGUID)
              --levelDice.destruct()
            end
            newSlotData = {}
        end

        updatedRackData[i] = newSlotData
    end

    return updatedRackData
end

function setNewPokemon(data, newPokemonData, pokemonGUID)
  data.name = newPokemonData.name
  data.types = copyTable(newPokemonData.types)
  data.baseLevel = newPokemonData.level
  data.effects = {}

  -- Model info.
  data.model_GUID = newPokemonData.model_GUID
  data.created_before = newPokemonData.created_before
  data.custom_scale = newPokemonData.custom_scale
  data.in_creation = newPokemonData.in_creation
  data.idle_effect = newPokemonData.idle_effect
  data.run_effect = newPokemonData.run_effect
  data.spawn_effect = newPokemonData.spawn_effect
  data.despawn_time = newPokemonData.despawn_time
  data.offset = newPokemonData.offset
  data.persistent_state = newPokemonData.persistent_state

  data.moves = copyTable(newPokemonData.moves)
  local movesData = {}
  for i=1, #data.moves do
    moveData = copyTable(Global.call("GetMoveDataByName", data.moves[i]))
    moveData.status = DEFAULT
    moveData.isTM = false
    table.insert(movesData, moveData)
  end
  data.movesData = movesData

  data.pokemonGUID = pokemonGUID
  if newPokemonData.evoData ~= nil then
    data.evoData = copyTable(newPokemonData.evoData)
  else
    data.evoData = nil
  end
end

function clearMoveText(isAttacker)
  if isAttacker then
    -- Clear text.
    local attackerText = getObjectFromGUID(atkText)
    attackerText.TextTool.setValue(" ")
  else
    local defenderText = getObjectFromGUID(defText)
    defenderText.TextTool.setValue(" ")
  end
end

function calcPoints(params)

    if Player[params.rackColour].steam_name == nil then return end

    local badgePoints = 0
    local levelPoints = 0
    local rack = getObjectFromGUID(params.rackGUID)
    local castParams = {}
    castParams.direction = {0,-1,0}
    castParams.type = 1
    castParams.max_distance = 0.7
    castParams.debug = debug
    local origin

    for i=1, #params.badgesXPos do
        origin = {params.badgesXPos[i], 0.95, -0.85}
        castParams.origin = rack.positionToWorld(origin)
        hits = Physics.cast(castParams)
        if #hits ~= 0 then
            badgePoints = badgePoints + (i + 2)
        end
    end
    for i=1, #params.rackData do
        local slotData = params.rackData[i]
        if slotData.baseLevel ~= nil then
          levelPoints = levelPoints + (slotData.baseLevel + slotData.diceLevel)
        end
    end

    local points = badgePoints + levelPoints
    printToColor(Player[params.rackColour].steam_name .. " currently has " .. points .. " Points.", params.clickerColour)
    printToColor("(" .. badgePoints .. " Badge Points + " .. levelPoints .. " Level Points)", params.clickerColour)
end


function updateLevelDice(level, newLevel, params, levelDice)

  local yRotation = params.inArena and 0 or params.yRotRecall
  if level == 0 then -- Add level dice to board
    local diceBag = getObjectFromGUID(params.diceBagGUID)
    local dice = diceBag.takeObject()
    local dicePos

    if params.inArena then
      local arenaDicePos = params.isAttacker and attackerPos or defenderPos
      dicePos = {arenaDicePos.dice[1], 1.4, arenaDicePos.dice[2]}
    else
      local rack = getObjectFromGUID(params.rackGUID)
      dicePos = rack.positionToWorld({params.pokemonXPos[params.index] - levelDiceXOffset, 0.75, params.pokemonZPos - levelDiceZOffset})
    end
    dice.setPosition(dicePos)
    dice.setRotation({270,yRotation,0})
    return dice.getGUID()
  elseif levelDice ~= nil then -- Rotate level dice to correct level
    if newLevel == 0 then
        local destroyObj = function() levelDice.destruct() end
        Wait.time(destroyObj, 0.25)
        return nil
    else
      if newLevel == 1 then
        levelDice.setRotation({270,yRotation,0})
      elseif newLevel == 2 then
        levelDice.setRotation({0,yRotation,0})
      elseif newLevel == 3 then
        levelDice.setRotation({0,yRotation,270})
      elseif newLevel == 4 then
        levelDice.setRotation({0,yRotation,90})
      elseif newLevel == 5 then
        levelDice.setRotation({0,yRotation,180})
      elseif newLevel == 6 then
        levelDice.setRotation({90,yRotation,0})
      end
      return levelDice.getGUID()
    end
  end
end

function addStatusCounter(params)
    local counterParam = {}
    local counterPos = params.arenaAttack and attackerPos or defenderPos
    local data = params.arenaAttack and attackerPokemon or defenderPokemon

    counterParam.position = {counterPos.statusCounters[1], 2, counterPos.statusCounters[2]}
    counterParam.rotation = {0,180,0}

    local addCounter = getObjectFromGUID("3aad00").takeObject(counterParam)
    data.numStatusCounters = data.numStatusCounters + 1

    --table.insert(statusCounters, addCounter.getGUID())

end

function removeStatusCounter(isAttacker)

  local castParam = {}
  if isAttacker then
    castParam.origin = {attackerPos.statusCounters[1], 2, attackerPos.statusCounters[2]}
  else
    castParam.origin = {defenderPos.statusCounters[1], 2, defenderPos.statusCounters[2]}
  end

  castParam.direction = {0,-1,0}
  castParam.type = 1
  castParam.max_distance = 2
  castParam.debug = debug

  local hits = Physics.cast(castParam)
  if #hits ~= 0 then
    local counters = hits[1].hit_object
    if counters.hasTag("Status Counter") then
      local numInStack = counters.getQuantity()
      if numInStack > 1 then
        local counter = counters.takeObject()
        counter.destruct()
        return numInStack - 1
      else
        counters.destruct()
        return 0
      end
    end
  else
      return 0
  end
end

function onObjectEnterScriptingZone(zone, object)
  -- Check if the zone is of interest is the wildPokeZone.
  if zone.getGUID() == wildPokeZone and defenderData.type == nil then
    local pokeGUID = object.getGUID()
    local data = Global.call("GetPokemonDataByGUID", {guid=pokeGUID})
    if data ~= nil then
      showWildPokemonButton(true)
      wildPokemonGUID = pokeGUID
    end
  end
end

function onObjectLeaveScriptingZone(zone, object)
  if inBattle == false then
    showWildPokemonButton(false)
  end
end

--------------------------------------------------------------------------------
-- RACK BUTTONS
--------------------------------------------------------------------------------

function showRackSlotButtons(params)

    local rack = getObjectFromGUID(params.rackGUID)
    local buttonIndex = (params.index * 8) - 3

    rack.editButton({index=buttonIndex, position={params.xPos, params.yLoc, params.zLoc}}) -- Attack Button
    rack.editButton({index=buttonIndex+1, position={params.xPos + 0.26, params.yLoc, params.zLoc}}) -- Defend Button
    rack.editButton({index=buttonIndex+2, position={params.xPos - 0.09, params.yLoc, 0.02}}) -- Level Down Button
    rack.editButton({index=buttonIndex+3, position={params.xPos + 0.34, params.yLoc, 0.02}}) -- Level Up Button
end

function hideRackSlotButtons(params)

    local rack = getObjectFromGUID(params.rackGUID)
    local buttonIndex = (params.index * 8) - 3

    rack.editButton({index=buttonIndex, position={params.xPos, 1000, params.zLoc}}) -- Attack Button
    rack.editButton({index=buttonIndex+1, position={params.xPos + 0.26, 1000, params.zLoc}}) -- Defend Button
    rack.editButton({index=buttonIndex+2, position={params.xPos - 0.09, 1000, 0.02}}) -- Level Down Button
    rack.editButton({index=buttonIndex+3, position={params.xPos + 0.34, 1000, 0.02}}) -- Level Up Button
end

function hideAllRackButtons(buttonParams)
    local rack = getObjectFromGUID(buttonParams.rackGUID)
    local buttonIndex = 5

    for i=1,6 do
        local xPos = -1.6 + ( 0.59 * (i-1))
        local yPos = 1000
        rack.editButton({index=buttonIndex + 7, position={buttonParams.pokemonXPos[7 - i] + 0.24, yPos, buttonParams.pokemonZPos + 0.025}})
        rack.editButton({index=buttonIndex + 6, position={buttonParams.pokemonXPos[7 - i] + 0.19, yPos, buttonParams.pokemonZPos + 0.025}})
        rack.editButton({index=buttonIndex + 5, position={buttonParams.pokemonXPos[7 - i] + 0.215, yPos, buttonParams.pokemonZPos + 0.025}})

        rack.editButton({index=buttonIndex + 4, position={-1.47 + ((i - 1) * 0.59), yPos, buttonParams.zLoc}})

        rack.editButton({index=buttonIndex, position={xPos, yPos, buttonParams.zLoc}})
        rack.editButton({index=buttonIndex + 1, position={xPos + 0.26, yPos, buttonParams.zLoc}})
        rack.editButton({index=buttonIndex + 2, position={xPos - 0.09, yPos, 0.02}})
        rack.editButton({index=buttonIndex + 3, position={xPos + 0.34, yPos, 0.02}})

      buttonIndex = buttonIndex + 8
    end
end

function multiEvo1()

  multiEvolve(1)

end

function multiEvo2()

  multiEvolve(2)
end

function multiEvo3()

  multiEvolve(3)
end

function multiEvo4()

  multiEvolve(4)
end

function multiEvo5()

  multiEvolve(5)
end

function multiEvo6()

  multiEvolve(6)
end

function multiEvo7()

  multiEvolve(7)
end

function multiEvo8()

  multiEvolve(8)
end

function multiEvo9()

  multiEvolve(9)
end

function multiEvolve(index)
  multiEvolving = false
  local params = multiEvoData.params
  local evoPokemon = multiEvoData.pokemonData
  local chosenEvoData = evoPokemon[index]
  local chosenEvoGuids = chosenEvoData.guids

  for i=1, #evoPokemon do
    local evoData = evoPokemon[i]
    local evoDataGuids = evoData.guids

    -- This check prevents us from putting away the wrong token.
    local removeThisToken = true
    for j = 1, #chosenEvoGuids do
      for k = 1, #evoDataGuids do
        if chosenEvoGuids[j] == evoDataGuids[k] then
          removeThisToken = false
          break
        end
      end
    end
    
    if removeThisToken then
      for m = 1, #evoDataGuids do
        -- Try to remove secondary type tokens.
        if Global.call("getDualTypeEffectiveness") then
          local token_guid = Global.call("get_secondary_type_token_guid", evoDataGuids[m])
          if token_guid then
            Global.call("despawn_secondary_type_token", {pokemon=evoData, secondary_type_token=token_guid})
          end
        end

        local status, pokemonToken = pcall(getObjectFromGUID, evoDataGuids[m])
        if pokemonToken ~= nil then
          local pokeball = getObjectFromGUID(evolvePokeballGUID[evoData.ball])
          pokeball.putObject(pokemonToken)
        end
      end
    end
  end

  hideMultiEvoButtons()
  local evolvedPokemon = nil
  local evolvedPokemonData = nil
  local evolvedPokemonGUID = nil
  local status = nil
  for n = 1, #chosenEvoGuids do
    if evolvedPokemon ~= nil then
      break
    end
    status, evolvedPokemon = pcall(getObjectFromGUID, chosenEvoGuids[n])
    if evolvedPokemon ~= nil then
      evolvedPokemonGUID = chosenEvoGuids[n]
      evolvedPokemonData = Global.call("GetPokemonDataByGUID",{guid=evolvedPokemonGUID})
      break
    end
  end
  local rack = getObjectFromGUID(params.rackGUID)

  if params.inArena then
    if params.isAttacker then
      position = {attackerPos.pokemon[1], 2, attackerPos.pokemon[2]}
      evolvedPokemon.setPosition(position)
      setNewPokemon(attackerPokemon, evolvedPokemonData, evolvedPokemonGUID)
      updateMoves(params.isAttacker, attackerPokemon)
    else
      position = {defenderPos.pokemon[1], 2, defenderPos.pokemon[2]}
      evolvedPokemon.setPosition(position)
      setNewPokemon(defenderPokemon, evolvedPokemonData, evolvedPokemonGUID)
      updateMoves(params.isAttacker, defenderData)
    end
    rack.call("updatePokemonData", {index=params.index, pokemonGUID=evolvedPokemonGUID})
  else
    rack.call("updatePokemonData", {index=params.index, pokemonGUID=evolvedPokemonGUID})
    local position = rack.positionToWorld({params.pokemonXPos[params.index], 1, params.pokemonZPos})
    local rotation = {0, 0 + params.evolveRotation, 0}

    -- Move the evolved Pokemon model.
    evolvedPokemon.setPosition(position)
    evolvedPokemon.setRotation(rotation)

    -- Move the model once the evolved pokemon model is resting.
    Wait.condition(
      function()
        -- Check if there is a model_GUID associated with this evo. Sparse array behavior prevents 
        -- us from using nil in place of a nil model. Check for 0 instead.
        if multiEvoGuids[index] ~= 0 and multiEvoGuids[index] ~= nil then
          -- Get the model by its GUID and move it to ontop of the pokemon token. Smooth movements used so that the
          -- token beats the model.
          local pokemonModel = getObjectFromGUID(multiEvoGuids[index])
          if pokemonModel ~= nil then
            -- Reformat the data so that the model code can use it. (Sorry, I know this is hideous.)
            evolvedPokemonData.chip = evolvedPokemonGUID
            evolvedPokemonData.base = {offset = evolvedPokemonData.offset}
            pokemonModel.setPosition(Global.call("model_position", evolvedPokemonData))
            pokemonModel.setRotation(rotation)
          end
        end

        -- Clear the multi evo GUID table.
        multiEvoGuids = {}
      end,
      function() -- Condition function
        return evolvedPokemon.resting
      end,
      2
    )
  end
end

--------------------------------------------------------------------------------
-- EVOLUTION BUTTONS
--------------------------------------------------------------------------------

function updateEvoButtons(params)
    if params.inArena then
      updateArenaEvoButtons(params, params.isAttacker)
    else
      updateRackEvoButtons(params)
    end
end

function hideEvoButtons(params)
    if params.inArena then
      hideArenaEvoButtons(params.isAttacker)
    else
      hideRackEvoButtons(params)
    end
end

-- Rack Evolution Buttons
function updateRackEvoButtons(params)
    local rack = getObjectFromGUID(params.rackGUID)
    local buttonTooltip
    local buttonIndex = 2 + (8 * params.index)
    if params.numEvos == 2 then
      local buttonTooltip2
      buttonTooltip = "Evolve into " .. params.evoName
      buttonTooltip2 = "Evolve into " .. params.evoNameTwo
      rack.editButton({index=buttonIndex+1, position={params.pokemonXPos[7 - params.index] + 0.19, params.yLoc, params.pokemonZPos + 0.025}, tooltip=buttonTooltip})
      rack.editButton({index=buttonIndex+2, position={params.pokemonXPos[7 - params.index] + 0.24, params.yLoc, params.pokemonZPos + 0.025}, tooltip=buttonTooltip2})
    else
      if params.numEvos == 1 then
          buttonTooltip = "Evolve into " .. params.evoName
      else
          buttonTooltip = "Evolve " .. params.pokemonName
      end
      rack.editButton({index=buttonIndex, position={params.pokemonXPos[7 - params.index] + 0.215, params.yLoc, params.pokemonZPos + 0.025}, tooltip=buttonTooltip})
    end
end

function hideRackEvoButtons(params)
    local rack = getObjectFromGUID(params.rackGUID)
    local buttonIndex = 2 + (8 * params.index)

    rack.editButton({index=buttonIndex, position={params.pokemonXPos[7 - params.index] + 0.215, 1000, params.pokemonZPos + 0.025}, tooltip=""})
    rack.editButton({index=buttonIndex+1, position={params.pokemonXPos[7 - params.index] + 0.19, 1000, params.pokemonZPos + 0.025}, tooltip=""})
    rack.editButton({index=buttonIndex+2, position={params.pokemonXPos[7 - params.index] + 0.24, 1000, params.pokemonZPos + 0.025}, tooltip=""})
end

function updateArenaEvoButtons(params, isAttacker)

  local position1
  local position2

  if isAttacker then
    buttonIndex = 7
    position1 = {x=atkEvolve1Pos.x, y=0.4, z=atkEvolve1Pos.z}
    position2 = {x=atkEvolve2Pos.x, y=0.4, z=atkEvolve2Pos.z}
  else
    buttonIndex = 20
    position1 = {x=defEvolve1Pos.x, y=0.4, z=defEvolve1Pos.z}
    position2 = {x=defEvolve2Pos.x, y=0.4, z=defEvolve2Pos.z}
  end

  if params.numEvos == 2 then
    local buttonTooltip2
    buttonTooltip = "Evolve into " .. params.evoName
    buttonTooltip2 = "Evolve into " .. params.evoNameTwo
    self.editButton({index=buttonIndex, position=position1, tooltip=buttonTooltip})
    self.editButton({index=buttonIndex+1, position=position2, tooltip=buttonTooltip2})
  else
    if params.numEvos == 1 then
        buttonTooltip = "Evolve into " .. params.evoName
    else
        buttonTooltip = "Evolve " .. params.pokemonName
    end
    self.editButton({index=buttonIndex, position=position1, tooltip=buttonTooltip})
  end
end

function hideArenaEvoButtons(isAttacker)

    if isAttacker then
      self.editButton({index=7, position={atkEvolve1Pos.x, 1000, atkEvolve1Pos.z}})
      self.editButton({index=8, position={atkEvolve2Pos.x, 1000, atkEvolve2Pos.z}})
    else
      self.editButton({index=20, position={defEvolve1Pos.x, 1000, defEvolve1Pos.z}})
      self.editButton({index=21, position={defEvolve2Pos.x, 1000, defEvolve2Pos.z}})
    end
end

--------------------------------------------------------------------------------
-- ARENA BUTTONS
--------------------------------------------------------------------------------

function showMoveButtons(isAttacker, cardMoveData)
  if isAttacker then
    buttonIndex = 8
    movesZPos = atkMoveZPos
    moves = attackerPokemon.movesData
  else
    buttonIndex = 21
    movesZPos = defMoveZPos
    moves = defenderPokemon.movesData
  end

  local numMoves = #moves
  if cardMoveData ~= nil then
    numMoves = numMoves + 1
    table.insert(moves, 1, cardMoveData)
  end
  local buttonWidths = (numMoves*3.2) + ((numMoves-1) + 0.5)
  local xPos = 9.38 - (buttonWidths * 0.5)

  for i=1, numMoves do
    local moveName = tostring(moves[i].name)
    self.editButton{index=buttonIndex+i, position={xPos + (3.7*(i-1)), 0.45, movesZPos}, label=moveName}
  end
end

function showConfirmButton(isAttacker, label)

  local buttonIndex
  local pos

  if isAttacker then
    buttonIndex = 12
    pos = {x=atkConfirmPos.x, y=0.4, z=atkConfirmPos.z}
    attackerConfirmed = false
  else
    buttonIndex = 26
    pos = {x=defConfirmPos.x, y=0.4, z=defConfirmPos.z}
    defenderConfirmed = false
  end

  self.editButton({index=buttonIndex, position=pos, label=label})
end

function hideConfirmButton(isAttacker)

  if isAttacker then
      self.editButton({index=12, position={atkConfirmPos.x, 1000, atkConfirmPos.z}})
  else
      self.editButton({index=26, position={defConfirmPos.x, 1000, defConfirmPos.z}})
  end
end


function showAtkButtons(visible)
    local yPos = visible and 0.4 or 1000
    self.editButton({index=0, position={teamAtkPos.x, yPos, teamAtkPos.z}, click_function="seeAttackerRack", label="TEAM", tooltip="See Team"})
    self.editButton({index=1, position={movesAtkPos.x, yPos, movesAtkPos.z}, click_function="seeMoveRules", label="MOVES", tooltip="Show Move Rules"})
    self.editButton({index=2, position={recallAtkPos.x, yPos, recallAtkPos.z}, click_function="recallAtkArena", label="RECALL"})
    self.editButton({index=3, position={incLevelAtkPos.x, yPos, incLevelAtkPos.z}})
    self.editButton({index=4, position={decLevelAtkPos.x, yPos, decLevelAtkPos.z}})
    self.editButton({index=5, position={incStatusAtkPos.x, yPos, incStatusAtkPos.z}})
    self.editButton({index=6, position={decStatusAtkPos.x, yPos, decStatusAtkPos.z}})

    if visible == false then
      hideArenaEvoButtons(true)
      hideArenaMoveButtons(true)
    end

end

function showDefButtons(visible)
    local yPos = visible and 0.4 or 1000
    self.editButton({index=13, position={teamDefPos.x, yPos, teamDefPos.z}, click_function="seeDefenderRack", label="TEAM", tooltip="See Team"})
    self.editButton({index=14, position={movesDefPos.x, yPos, movesDefPos.z}, click_function="seeMoveRules", label="MOVES", tooltip="Show Move Rules"})
    self.editButton({index=15, position={recallDefPos.x, yPos, recallDefPos.z}, click_function="recallDefArena", label="RECALL", tooltip="Recall Pokémon"})
    self.editButton({index=16, position={incLevelDefPos.x, yPos, incLevelDefPos.z}, click_function="increaseDefArena"})
    self.editButton({index=17, position={decLevelDefPos.x, yPos, decLevelDefPos.z}, click_function="decreaseDefArena"})
    self.editButton({index=18, position={incStatusDefPos.x, yPos, incStatusDefPos.z}, click_function="addDefStatus"})
    self.editButton({index=19, position={decStatusDefPos.x, yPos, decStatusDefPos.z}, click_function="removeDefStatus"})

    if visible == false then
      hideArenaEvoButtons(false)
      hideArenaMoveButtons(false)
    end
end

function hideArenaMoveButtons(isAttacker)

    if isAttacker then
      self.editButton({index=9, position={atkEvolve1Pos.x, 1000, atkEvolve1Pos.z}})
      self.editButton({index=10, position={atkEvolve2Pos.x, 1000, atkEvolve2Pos.z}})
      self.editButton({index=11, position={atkEvolve2Pos.x, 1000, atkEvolve2Pos.z}})
    else
      self.editButton({index=22, position={defEvolve1Pos.x, 1000, defEvolve1Pos.z}})
      self.editButton({index=23, position={defEvolve2Pos.x, 1000, defEvolve2Pos.z}})
      self.editButton({index=24, position={defEvolve2Pos.x, 1000, defEvolve2Pos.z}})
    end

    hideArenaEffectiness(isAttacker)
end

function hideArenaEffectiness(isAttacker)

  local moveText = isAttacker and atkMoveText or defMoveText
  for i=1, 3 do
    local textfield = getObjectFromGUID(moveText[i])
    textfield.TextTool.setValue(" ")
  end
end

function showWildPokemonButton(visible)

  local yPos = visible and 0.4 or 1000
  self.editButton({index=36, position={defConfirmPos.x, yPos, -6.2}})
end

function showMultiEvoButtons(evoData)
  for evoIndex = 1, #evoData do
    if evoData[evoIndex].model_GUID ~= nil then
      table.insert(multiEvoGuids, evoData[evoIndex].model_GUID)
    else
      table.insert(multiEvoGuids, 0)
    end
  end

  local buttonIndex = 26
  local numEvos = #evoData
  local tokensWidth = ((numEvos * 2.8) + ((numEvos-1) * 0.2) )

  for i=1, numEvos do
    local xPos = 1.4 + ((i-1) * 3) - (tokensWidth * 0.5)
    local worldPos = {xPos, 1, -30}
    local localPos = self.positionToLocal(worldPos)
    localPos.x = -localPos.x
    self.editButton({index=buttonIndex+i, position=localPos})
  end
end

function hideMultiEvoButtons()
  local buttonIndex = 26
  for i=1, 9 do
    self.editButton({index=buttonIndex+i, position={0, 1000, 0}})
  end
end

function showFlipGymButton(visible)

  local yPos = visible and 0.5 or 1000
  self.editButton({index=37, position={2.6, yPos, -0.6}})
end

function showFlipRivalButton(visible)

  local yPos = visible and 0.5 or 1000
  self.editButton({index=40, position={rivalFipButtonPos.x, yPos, rivalFipButtonPos.z}, click_function="flipRivalPokemon", tooltip=""})
end

function showAttackerTeraButton(visible, type)
  local yPos = visible and 0.5 or 1000
  if type == nil then
    type = ""
  end
  self.editButton({index=38, label="Current: " .. type, position={2.6, yPos, 0.6}})
end

function showDefenderTeraButton(visible, type)
  local yPos = visible and 0.5 or 1000
  if type == nil then
    type = ""
  end
  self.editButton({index=39, label="Current: " .. type, position={2.6, yPos, -0.6}})
end

-- Helper function to print a table.
function dump_table(o)
  if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. dump_table(v) .. ','
      end
      return s .. '} '
  else
      return tostring(o)
  end
end