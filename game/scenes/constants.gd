extends Node2D

const HUMAN_PLAYER  = 1
const AI_PLAYER = 2

const PLAY_FIELD_TILE = 1
const PLAYER_START_TILE = 2
const AI_START_TILE = 3

const START_ENERGY = 1000
const CELL_SCALE = 0.5
const GAME_SPEED = 0.1

const MAX_ENERGY = 100.0
const INITIAL_ENERGY = 5.0
const COLONIZE_ENERGY_COST = 10.0
const ENERGY_DRAIN = 0.1
const ENERGY_TRANSFER = 2.0
const SEND_ENERGY_THRESHOLD = 10.0
const ATTACK_ENERGY = 2.0

const AI_TICK_RATE = 1.5
const AT_TICK_RATE_VARIATION = 1.5

const FUNGUS_ARM_ANIMATION_FRAME_TIME = 0.02

# Potential field values
const HOTSPOT_ENEMY_CELL_VALUE = -40
const HOTSPOT_ATTACKED_CELL_VALUE = 40
const HOTSPOT_FOOD_VALUE = 20
const HOTSPOT_ENEMY_CELL_DECAY = 40
const HOTSPOT_ATTACKED_CELL_DECAY = 2
const HOTSPOT_FOOD_DECAY = 10
const OWN_CELL_SCORE = 200
