package org.iot.codegenerator.generator.python

import org.iot.codegenerator.codeGenerator.BaseSensor
import org.iot.codegenerator.codeGenerator.Filter
import org.iot.codegenerator.codeGenerator.FrequencySampler
import org.iot.codegenerator.codeGenerator.Map
import org.iot.codegenerator.codeGenerator.Pipeline
import org.iot.codegenerator.codeGenerator.Sensor
import org.iot.codegenerator.codeGenerator.SensorData
import org.iot.codegenerator.codeGenerator.SignalSampler
import org.iot.codegenerator.codeGenerator.Window

import static extension org.eclipse.xtext.EcoreUtil2.*
import org.iot.codegenerator.codeGenerator.OverrideSensor
import org.iot.codegenerator.codeGenerator.AbstractSensor

class GeneratorUtil {

	static def String asInstance(String name) {
		'''_«name»'''
	}
	
	static def String asModule(String name) {
		name.toLowerCase
	}

	static def String asClass(String name) {
		name.toFirstUpper
	}

	static def boolean isFrequency(Sensor sensor) {
		switch (sensor) {
			case sensor instanceof BaseSensor: {
				(sensor as BaseSensor).sampler instanceof FrequencySampler
			}
			case sensor instanceof OverrideSensor: {
				(sensor as OverrideSensor).sampler instanceof FrequencySampler
			}
			case sensor instanceof AbstractSensor: {
				false
			}
			default: {
				false
			}
		}
	}

	static def boolean isSignal(Sensor sensor) {
		switch (sensor) {
			case sensor instanceof BaseSensor: {
				(sensor as BaseSensor).sampler instanceof SignalSampler
			}
			case sensor instanceof OverrideSensor: {
				(sensor as OverrideSensor).sampler instanceof SignalSampler
			}
			case sensor instanceof AbstractSensor: {
				false
			}
			default: {
				false
			}
		}
	}

	static def Iterable<SensorData> sensorDatas(Sensor sensor) {
		return sensor.eAllOfType(SensorData)
	}
	
	static def String interceptorName(Pipeline pipeline) {
		val type = switch (pipeline) {
			Filter: "Filter"
			Map: "Map"
			Window: "Window"
		}

		val sensor = pipeline.getContainerOfType(Sensor)
		val index = sensor.eAllContents.filter [
			it.class == pipeline.class
		].takeWhile [
			it != pipeline
		].size + 1

		'''Interceptor«type»«index»'''
	}
}