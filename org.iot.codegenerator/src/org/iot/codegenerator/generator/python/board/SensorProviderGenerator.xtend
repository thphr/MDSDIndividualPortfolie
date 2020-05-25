package org.iot.codegenerator.generator.python.board

import com.google.inject.Inject
import java.util.Arrays
import org.iot.codegenerator.codeGenerator.BaseBoard
import org.iot.codegenerator.codeGenerator.OnbSensor
import org.iot.codegenerator.codeGenerator.Sensor
import org.iot.codegenerator.generator.python.GeneratorEnvironment
import org.iot.codegenerator.util.CommonLibrary

class SensorProviderGenerator { 
	@Inject extension CommonLibrary
	
	def compile(BaseBoard board) {
		val env = new GeneratorEnvironment()
		
		'''
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
        «FOR sensor : board.allSensors»
        «IF sensor instanceof OnbSensor»

		class «sensor.sensortype»_wrapper(default_wrapper):
		
			def __init(self):
				«sensor.getInitDriver(env)»
			
			def read_data(self):
				«sensor.getReadDriver(env)»
		«ENDIF»
        «ENDFOR»
		'''
	}
	
	private def String getInitDriver(Sensor sensor, GeneratorEnvironment env){
		if (!Arrays.asList("thermometer", "lux", "moption").contains(sensor.name)) {
			return '''
			# TODO: not yet supported
			pass'''
		} else if (sensor.name == "thermometer") {
			return '''
			from hts221 import HTS221
			self.driver = HTS221(i2c)'''
		} else if (sensor.name == "lux") {
			return '''
			from bh1750 import BH1750
			self.driver = BH1750(i2c)'''
		} else if (sensor.name == "motion") {
			return '''
			from mpu6050 import MPU6050
			self.driver = MPU6050(i2c)'''
		} 
	}
	
	private def String getReadDriver(Sensor sensor, GeneratorEnvironment env){
		if (!Arrays.asList("thermometer", "lux", "moption").contains(sensor.name)) {
			return '''
			# TODO: not yet supported
			return -1'''
		} else if(sensor.name == "thermometer") {
			return ''' 
			# returns tuple
			return (self.driver.read_temp(), self.driver.read_humi())'''
		} else if (sensor.name == "lux") {
			return '''return self.driver.luminance(0x10)'''
		} else if (sensor.name == "motion") {
			return '''
			# return a dictionary with 7 keys
			return self.driver.get_values()'''
		} 
	}
	
}