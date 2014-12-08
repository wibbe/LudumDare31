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
const ENERGY_TRANSFER = 0.5
const SEND_ENERGY_THRESHOLD = 10.0

const AI_TICK_RATE = 0.4
const AT_TICK_RATE_VARIATION = 0.3