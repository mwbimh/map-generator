extends Reference

class_name Plate

var code = ""
var user_set_code = false

var color
var size = 0
var position = Vector2(0,0)
var center = Vector2(0,0)
var edge_points = []

var shape


func add_point(point:Vector2):
	edge_points.append(point)
	center += point
#	if position == Vector2(-1,-1):
#		position = point
#	else:
#		if point.x < position.x:
#			position.x = point.x
#		if point.y < position.y:
#			position.y = point.y


func complete():
	if edge_points.size() == 0:
		return 0
	center /= edge_points.size()
	center = Vector2(round(center.x),round(center.y))
	return 1


func change_code(code,user_set = true):
	self.code = code
	self.user_set_code = user_set
	shape.change_code(code)


func change_size(size):
	self.size = size


func change_color(color):
	self.color = color
	shape.change_color(color)


func change_center(center):
	self.center = center
	shape.change_center(center)


func get_data():
	var _temp = []
	for p in edge_points:
		_temp.append([p.x,p.y])
	var data = {
		"code":code,
		"size":size,
		"color":color,
		"position":[position.x,position.y],
		"center":[center.x,center.y],
		"points":_temp,
	}
	return data
