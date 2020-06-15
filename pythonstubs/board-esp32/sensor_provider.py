from machine import Pin, I2C
i2c = I2C(-1, Pin(26, Pin.IN), Pin(25, Pin.OUT))
 
class default_wrapper:
	# TODO: implement your external sensor
	
	# init your library
	def __init__(self):
		pass
	
	# returns data value(s)
	def read_data(self):
		return -1
