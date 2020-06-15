from pipeline import Interceptor
try:
    import utime
except ModuleNotFoundError:
    import time as utime
import thread

class Thermistor:
	
	def __init__(self, sensor):
		self.sensor = sensor
		self.variables = {}
		self.thread = thread.Thread(self.__timer, "ThreadThermistor")
		self.thread.start()
		
	def __timer(self, thread: thread.Thread):
		while thread.active:
			utime.sleep(10)
			# TODO: Unsupported
			pass
	
	def signal(self, command: str):
		if command == "kill":
			self.thread.interrupt()
	
	def add_pipeline(self, identifier: str, pipeline):
		if not identifier in self.variables:
			self.variables[identifier] = [pipeline]
		else:
			self.variables[identifier].append(pipeline)
		
	def get_pipeline(self, identifier: str, index: int):
		return self.variables[identifier][index]
	

class InterceptorFilter1(Interceptor):
	def handle(self, _x):
		print("Filter")
		_should_continue = 5 > 100
		if _should_continue:
			self.next.handle(_x)

class InterceptorWindow1(Interceptor):
	def __init__(self, next: Interceptor):
		super().__init__(next)
		self._buffer = []
	
	def handle(self, _x):
		print("Window")
		self._buffer.append(_x)
		if len(self._buffer) == 20:
			_result = None # TODO: Unsupported
			self._buffer = []
			self.next.handle(_result)

class InterceptorMap1(Interceptor):
	def handle(self, _x):
		print("Map")
		_newValue = 5
		self.next.handle(_newValue)

