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

class thermometer_wrapper(default_wrapper):

	def __init(self):
		from hts221 import HTS221
		self.driver = HTS221(i2c)
	
	def read_data(self):
		# returns tuple
		return (self.driver.read_temp(), self.driver.read_humi())
