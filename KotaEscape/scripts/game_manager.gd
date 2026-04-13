extends Node
## Global day loop, stats, progression. Autoload singleton.

signal stats_changed
signal day_changed(new_day: int)
signal morning_started(day: int)
signal phone_open_changed(is_open: bool)

const FOCUS_MIN := 0
const FOCUS_MAX := 100
const STRESS_MIN := 0
const STRESS_MAX := 100

var day: int = 1
var focus: int = 50
var stress: int = 20

## Cleared only on a real morning (sleep → new day, or first boot).
var went_to_class_today: bool = false
var attended_class_today: bool = false

## Set when player picks "Leave early" on Day 3; cleared at end of night.
var left_early_day3: bool = false

var pending_toast: String = ""

var phone_open: bool = false

var _hostel_after_sleep: bool = true
var _first_hostel_boot: bool = true


func _ready() -> void:
	stats_changed.emit()


func set_phone_open(open: bool) -> void:
	phone_open = open
	phone_open_changed.emit(open)


## True once after sleeping into hostel, or on first launch.
func consume_morning_reset() -> bool:
	if _hostel_after_sleep:
		_hostel_after_sleep = false
		return true
	if _first_hostel_boot:
		_first_hostel_boot = false
		return true
	return false


func start_morning() -> void:
	went_to_class_today = false
	attended_class_today = false
	morning_started.emit(day)


func add_focus(amount: int) -> void:
	focus = clampi(focus + amount, FOCUS_MIN, FOCUS_MAX)
	stats_changed.emit()


func add_stress(amount: int) -> void:
	stress = clampi(stress + amount, STRESS_MIN, STRESS_MAX)
	stats_changed.emit()


func class_pay_attention() -> void:
	add_focus(10)
	add_stress(8)
	attended_class_today = true


func class_disengage() -> void:
	add_focus(-6)
	add_stress(5)
	attended_class_today = true


func class_half_listen() -> void:
	add_focus(6)
	add_stress(5)
	attended_class_today = true


func class_skip_penalty() -> void:
	add_focus(-15)
	add_stress(-2)


func phone_scroll_reels() -> void:
	add_stress(-5)
	add_focus(-3)
	stats_changed.emit()


func enter_classroom() -> void:
	went_to_class_today = true


func mark_left_early() -> void:
	left_early_day3 = true
	pending_toast = "You did something different today."


func end_day() -> void:
	if not went_to_class_today:
		class_skip_penalty()

	left_early_day3 = false
	day += 1
	day_changed.emit(day)

	if day > 3:
		get_tree().change_scene_to_file("res://scenes/ending.tscn")
	else:
		_hostel_after_sleep = true
		get_tree().call_deferred("change_scene_to_file", "res://scenes/hostel_room.tscn")
