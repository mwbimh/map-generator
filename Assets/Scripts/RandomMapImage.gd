extends Reference

class_name RandomMapGenerator

var img


func prepare(width = 1280,height = 720):
	img = Image.new()
	img.create(width,height,true,Image.FORMAT_RGBA8)
	img.fill(Color.white)
	img.save_png("res://test.png")
