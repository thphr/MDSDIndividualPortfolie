package org.iot.codegenerator.util

import java.util.ArrayList
import org.iot.codegenerator.codeGenerator.AbstractSensor
import org.iot.codegenerator.codeGenerator.BaseBoard
import org.iot.codegenerator.codeGenerator.BaseSensor
import org.iot.codegenerator.codeGenerator.OverrideSensor
import org.iot.codegenerator.codeGenerator.Provider
import org.iot.codegenerator.codeGenerator.Sampler
import org.iot.codegenerator.codeGenerator.Sensor
import org.iot.codegenerator.codeGenerator.SignalSampler
import org.iot.codegenerator.codeGenerator.Transformation
import org.iot.codegenerator.codeGenerator.Variables

class CommonLibrary {
	//switch on different provider type. Not "case" when switching on objects.
	def Variables getVariablesOnProvider(Provider provider){
		switch(provider){
			OverrideSensor:
				provider.variables
			BaseSensor:
				provider.variables
			Transformation:
				provider.variables
		}
	}
	
	//Switch on sensor names, since name can be either name or sensortype.
	def String getName(Sensor sensor){
		switch(sensor){
			OverrideSensor:
				sensor.sensor.name
			AbstractSensor:
				sensor.sensortype
			BaseSensor:
				sensor.sensortype
		}
	}
	
	/**
	 * Gets all the sensors that are implemented on the boards and
	 * the ones that are inherited from the extended boards.
	 */
	def ArrayList<Sensor> getAllSensors(BaseBoard board){
		val ArrayList<Sensor> implementedSensors = new ArrayList
		val ArrayList<Sensor> supertypeSensors = new ArrayList
		implementedSensors.addAll(board.sensors)
		val sensorKeys = implementedSensors.groupBy[it.name]
		board.supertypes.forEach[
			supertypeSensors.addAll(it.sensors)
		]
		val inheritedSensors = supertypeSensors.filter[!sensorKeys.containsKey(it.name)]
		implementedSensors.addAll(inheritedSensors)	
		implementedSensors
	}
	
	
	def Sampler getSampler(Sensor sensor) {
		switch (sensor) {
			case sensor instanceof BaseSensor: {
				(sensor as BaseSensor).sampler
			}
			case sensor instanceof OverrideSensor: {
				(sensor as OverrideSensor).sampler 
			}
			case sensor instanceof AbstractSensor: {
				null
			}
			default: {
				null
			}
		}
	}
}