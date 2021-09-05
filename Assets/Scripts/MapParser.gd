extends Node

var img:Image
var size

var plates = []

var thread

signal hint(info)


func read(path = "res://US.png"):
	img = Image.new()
	thread = Thread.new()
	plates.clear()
	if img.load(path) != 0:
		emit_signal("hint","Wrong path")
		return false
	elif img.get_format() != Image.FORMAT_RGBA8:
		img.convert(Image.FORMAT_RGBA8)
	size = img.get_size()
	return true


func parse(arg):
	img.lock()
	for i in range(size.x):
		for j in range(size.y):
			var color = img.get_pixel(i,j).to_html()
			if color.substr(0,2) != "00":
				if is_legal(Vector2(i,j),color.substr(2)):
					get_edge(Vector2(i,j),color.substr(2))
					plates.back().size = mark_completed(Vector2(i,j),color.substr(2))
					emit_signal("hint","completed")
	img.unlock()
	emit_signal("hint","completed all")


func save(path = "res://default.mp"):
	autocode()
	var save_game = File.new()
	save_game.open(path,File.WRITE)
	for p in plates:
		var data = p.get_data()
		save_game.store_line(to_json(data))
	save_game.close()


func autocode():
	var used = []
	var checked = []
	for p in plates:
		if p.user_set_code:
			if not used.has(p.code):
				used.append(p.code)
				checked.append(p)
	var cnt = 0
	for p in plates:
		if not checked.has(p):
			while used.has(String(cnt)):
				cnt += 1
			p.change_code(String(cnt),false)
			cnt += 1


func reset_code():
	for p in plates:
		p.change_code("",false)


func get_edge(point:Vector2,color):
	var plate = Plate.new()
	plate.color = color
	var start = find_first(point,color)
	var pre = point
	if start == null:
		return null
	plate.add_point(start)
	for p in plate.edge_points:
		if p == Vector2(0,73):
			pass
		var _temp = find_next(p,pre,color)
		if _temp == null:
			break
		elif _temp == start:
			break
		pre = p
		plate.add_point(_temp)
	plate.complete()
	plates.append(plate)


func mark_completed(point:Vector2,color):
	var arr = []
	var c = Color(0)
	arr.append(point)
	img.set_pixelv(point,c)
	for p in arr:
		if not out_of_bound(p+Vector2(-1,0),color):
			arr.append(p+Vector2(-1,0))
			img.set_pixelv(p+Vector2(-1,0),c)

		if not out_of_bound(p+Vector2(1,0),color):
			arr.append(p+Vector2(1,0))
			img.set_pixelv(p+Vector2(1,0),c)

		if not out_of_bound(p+Vector2(0,-1),color):
			arr.append(p+Vector2(0,-1))
			img.set_pixelv(p+Vector2(0,-1),c)

		if not out_of_bound(p+Vector2(0,1),color):
			arr.append(p+Vector2(0,1))
			img.set_pixelv(p+Vector2(0,1),c)
	return arr.size()


func find_first(point:Vector2,color):
	var p = Vector2(0,0)

	if out_of_bound(point+Vector2(0,-1),color):
		p = Vector2(0,-1)
	elif out_of_bound(point+Vector2(-1,0),color):
		p = Vector2(-1,0)
	elif out_of_bound(point+Vector2(0,1),color):
		p = Vector2(0,1)
	elif out_of_bound(point+Vector2(1,0),color):
		p = Vector2(1,0)

	if p == Vector2(0,0):
		return null

	p = clock_rotation(p)
	if not out_of_bound(p + point,color) and img.get_pixelv(p + point).a > 0.6:
		if is_edge(p + point,color) and is_legal(p + point,color):
			return p + point

	p = clock_rotation(p)
	if not out_of_bound(p + point,color) and img.get_pixelv(p + point).a > 0.6:
		if is_edge(p + point,color) and is_legal(p + point,color):
			return p + point

	p = clock_rotation(p)
	if not out_of_bound(p + point,color) and img.get_pixelv(p + point).a > 0.6:
		if is_edge(p + point,color) and is_legal(p + point,color):
			return p + point

	return null


func find_next(point:Vector2,pre:Vector2,color):
	var p = pre - point

	p = clock_rotation(p)
	if not out_of_bound(p + point,color) and img.get_pixelv(p + point).a > 0.6:
		if is_edge(p + point,color) and is_legal(p + point,color):
			return p + point

	p = clock_rotation(p)
	if not out_of_bound(p + point,color) and img.get_pixelv(p + point).a > 0.6:
		if is_edge(p + point,color) and is_legal(p + point,color):
			return p + point

	p = clock_rotation(p)
	if not out_of_bound(p + point,color) and img.get_pixelv(p + point).a > 0.6:
		if is_edge(p + point,color) and is_legal(p + point,color):
			return p + point

	return null


func clock_rotation(v:Vector2):
	return Vector2(v.y,-v.x)


func anticlock_rotation(v:Vector2):
	return Vector2(-v.y,v.x)


func is_legal(point,color):
	var f1 = out_of_bound(point+Vector2(0,-1),color)
	var f2 = out_of_bound(point+Vector2(0,1),color)
	var f3 = out_of_bound(point+Vector2(-1,0),color)
	var f4 = out_of_bound(point+Vector2(1,0),color)

	if f1 and f2:
		img.set_pixelv(point,Color(0))
		return false

	if f3 and f4:
		img.set_pixelv(point,Color(0))
		return false

	if out_of_bound(point+Vector2(1,1),color) and out_of_bound(point+Vector2(-1,-1),color):
		if not(f1 or f2 or f3 or f4):
			img.set_pixelv(point,Color(0))
			return false
	
	if out_of_bound(point+Vector2(1,-1),color) and out_of_bound(point+Vector2(-1,1),color):
		if not(f1 or f2 or f3 or f4):
			img.set_pixelv(point,Color(0))
			return false
	
	return true


func is_edge(point:Vector2,color):
	var p1 = point+Vector2(0,-1)
	if out_of_bound(p1,color):
		return true

	var p2 = point+Vector2(1,-1)
	if out_of_bound(p2,color):
		return true

	var p3 = point+Vector2(1,0)
	if out_of_bound(p3,color):
		return true

	var p4 = point+Vector2(1,1)
	if out_of_bound(p4,color):
		return true

	var p5 = point+Vector2(0,1)
	if out_of_bound(p5,color):
		return true

	var p6 = point+Vector2(-1,1)
	if out_of_bound(p6,color):
		return true

	var p7 = point+Vector2(-1,0)
	if out_of_bound(p7,color):
		return true

	var p8 = point+Vector2(-1,-1)
	if out_of_bound(p8,color):
		return true

	return false


func out_of_bound(point:Vector2,color):
	if point.x < 0 or point.y < 0 or point.x >= size.x or point.y >= size.y:
		return true
	if img.get_pixelv(point).to_html(false) != color:
		return true
	return false
