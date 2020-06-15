import thread

class Esp32:
	
	def __init__(self):
		self._sensors = {}
		self._output_channels = []
		self._input_channel = None
		self._in_thread = thread.Thread(self._input_loop, "ThreadInput")
	
	def add_sensor(self, identifier: str, sensor):
		self._sensors[identifier] = sensor
	
	def add_output_channel(self, channel):
		self._output_channels.append(channel)
	
	def set_input_channel(self, channel):
		self._input_channel = channel
	
	def _input_loop(self, thread: thread.Thread):
		while thread.active:
			command = self._input_channel.receive().decode("utf-8")
			print("Received: " + command)
			elements = command.split(":")
			sensor = self._sensors[elements[0]]
			sensor.signal(elements[1])
	
	def run(self):
		self._in_thread.start()
		
		thread.join([
			self._in_thread,
			self._sensors["thermistor"].thread
			# TODO: Join on threads from output channels
		])
