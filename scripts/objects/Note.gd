class_name Note extends Node2D

#var quant_values = [
#	[4, Color8(249, 57, 63)],
#	[8, Color8(83, 107, 239)],
#	[12, Color8(194, 75, 153)],
#	[16, Color8(0, 229, 80)],
#	[20, Color8(96, 103, 137)],
#	[24, Color8(255, 122, 215)],
#	[32, Color8(255, 232, 61)],
#	[48, Color8(174, 54, 230)],
#	[64, Color8(15, 235, 255)],
#	[192, Color8(96, 103, 137)]
#]
var quant_values = [
	[4, Color8(255, 56, 112)],
	[8, Color8(0, 200, 255)],
	[12, Color8(192, 66, 255)],
	[16, Color8(0, 255, 123)],
	[20, Color8(196, 196, 196)],
	[24, Color8(255, 150, 234)],
	[32, Color8(255, 255, 82)],
	[48, Color8(170, 0, 255)],
	[64, Color8(0, 255, 255)],
	[192, Color8(196, 196, 196)]
]

@onready var note = $Note
@onready var hold_rect:Control = $HoldRect

var hit_time:float = 0
var lane_id:int = 0
var sustain_length:float = 0
var crochet:float = 0.5
var last_change:float = 0.0

func resize_sustain(length:float, speed:float, radian_offset:float):
	hold_rect.size.y = abs(45 * (length * speed * 15))
	hold_rect.rotation = (PI if speed > 0.0 else 0.0) - radian_offset

func _ready():
	var mes_time = crochet * 4
	var smallest_quant_index = quant_values.size() - 1
	var smallest_deviation = mes_time / quant_values[smallest_quant_index][0]
	
	for quant in quant_values:
		var quant_time = mes_time / quant[0]
		if fmod(hit_time - last_change + smallest_deviation, quant_time) < smallest_deviation * 2:
			modulate = quant[1]
			return
	modulate = quant_values[smallest_quant_index][1]
