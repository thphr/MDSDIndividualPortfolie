from pipeline import Interceptor

class Thermometer:
	
	def __init__(self, sensor):
		self.sensor = sensor
		self.variables = {}
		
	def signal(self, command: str):
		if command == "signal":
			# TODO: Unsupported
			pass
	
	def add_pipeline(self, identifier: str, pipeline):
		if not identifier in self.variables:
			self.variables[identifier] = [pipeline]
		else:
			self.variables[identifier].append(pipeline)
		
	def get_pipeline(self, identifier: str, index: int):
		return self.variables[identifier][index]
	

class InterceptorMap1(Interceptor):
	def handle(self, _x):
		print("Map")
		_newValue = False
		self.next.handle(_newValue)

class InterceptorMap2(Interceptor):
	def handle(self, _x):
		print("Map")
		_newValue = 1 + " : " + 0
		self.next.handle(_newValue)

