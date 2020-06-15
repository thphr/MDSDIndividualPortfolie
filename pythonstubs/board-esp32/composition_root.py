from pipeline import Pipeline
from esp32 import Esp32
from sensor_provider import default_wrapper
from communication import Serial, Wifi
import struct
import motion
import thermometer
import thermistor
try:
    import ujson
except ModuleNotFoundError:
    import json as ujson

class CompositionRoot:
	
	def __init__(self):
		self._outserial = None
		self._endpoint1 = None
		self._inserial = None
		
		with open("conf-filled.json", "r") as _conf_file:
			self.configuration = ujson.loads("".join(_conf_file.readlines()))
	
	def provide_esp32(self):
		_esp32 = Esp32()
		_esp32.add_sensor("thermometer", self.provide_sensor_thermometer())
		_esp32.add_sensor("motion", self.provide_sensor_motion())
		_esp32.add_sensor("thermistor", self.provide_sensor_thermistor())
		_esp32.set_input_channel(self.provide_channel_inserial())
		_esp32.add_output_channel(self.provide_channel_outserial())
		_esp32.add_output_channel(self.provide_channel_endpoint1())
		return _esp32
	def provide_sensor_thermometer(self):
		_thermometer = thermometer.Thermometer(self.provide_driver_default())
		_thermometer.add_pipeline("temperature", self.provide_pipeline_thermometer_temperature_1())
		return _thermometer
	
	def provide_sensor_motion(self):
		_motion = motion.Motion(self.provide_driver_default())
		_motion.add_pipeline("movement", self.provide_pipeline_motion_movement_1())
		return _motion
	
	def provide_sensor_thermistor(self):
		_thermistor = thermistor.Thermistor(self.provide_driver_default())
		_thermistor.add_pipeline("voltage", self.provide_pipeline_thermistor_voltage_1())
		_thermistor.add_pipeline("voltage", self.provide_pipeline_thermistor_voltage_2())
		return _thermistor
	
	def provide_pipeline_thermometer_temperature_1(self):
		_endpoint1 = self.provide_channel_endpoint1()
		return Pipeline(
			thermometer.InterceptorMap1(
				type('Sink', (object,), {
					"handle": lambda data: _endpoint1.send(struct.pack("i", data)),
					"next": None
				})
			)
		)
	
	def provide_pipeline_motion_movement_1(self):
		_endpoint1 = self.provide_channel_endpoint1()
		return Pipeline(
			motion.InterceptorMap1(
				type('Sink', (object,), {
					"handle": lambda data: _endpoint1.send(struct.pack("i", data)),
					"next": None
				})
			)
		)
	
	def provide_pipeline_thermistor_voltage_1(self):
		_endpoint1 = self.provide_channel_endpoint1()
		return Pipeline(
			thermistor.InterceptorFilter1(
				thermistor.InterceptorWindow1(
					type('Sink', (object,), {
						"handle": lambda data: _endpoint1.send(struct.pack("i", data)),
						"next": None
					})
				)
			)
		)
	
	def provide_pipeline_thermistor_voltage_2(self):
		_outserial = self.provide_channel_outserial()
		return Pipeline(
			thermistor.InterceptorMap1(
				type('Sink', (object,), {
					"handle": lambda data: _outserial.send(struct.pack("i", data)),
					"next": None
				})
			)
		)
	
	def provide_channel_outserial(self):
		if not self._outserial:
			self._outserial = self.make_channel("outserial")
		return self._outserial
	
	def provide_channel_endpoint1(self):
		if not self._endpoint1:
			self._endpoint1 = self.make_channel("endpoint1")
		return self._endpoint1
	
	def provide_channel_inserial(self):
		if not self._inserial:
			self._inserial = self.make_channel("inserial")
		return self._inserial
	
	def make_channel(self, identifier: str):
		if self.configuration[identifier]["type"] == "serial":
			return Serial(self.configuration["serial"]["baud"],
						  self.configuration["serial"]["databits"],
						  self.configuration["serial"]["paritybits"],
						  self.configuration["serial"]["stopbit"])
		
		elif self.configuration[identifier]["type"] == "wifi":
			return Wifi(self.configuration[identifier]["lane"], 
						self.configuration["wifi"]["ssid"],
						self.configuration["wifi"]["password"])
	
	def provide_driver_default(self):
		return default_wrapper()
