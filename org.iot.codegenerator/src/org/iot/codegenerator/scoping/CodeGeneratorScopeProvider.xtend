/*
 * generated by Xtext 2.20.0
 */
package org.iot.codegenerator.scoping

import java.util.ArrayList
import java.util.Collections
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.iot.codegenerator.codeGenerator.AbstractSensor
import org.iot.codegenerator.codeGenerator.BaseBoard
import org.iot.codegenerator.codeGenerator.BaseSensor
import org.iot.codegenerator.codeGenerator.Board
import org.iot.codegenerator.codeGenerator.Cloud
import org.iot.codegenerator.codeGenerator.CodeGeneratorPackage
import org.iot.codegenerator.codeGenerator.Data
import org.iot.codegenerator.codeGenerator.DeviceConf
import org.iot.codegenerator.codeGenerator.Fog
import org.iot.codegenerator.codeGenerator.Map
import org.iot.codegenerator.codeGenerator.OverrideSensor
import org.iot.codegenerator.codeGenerator.Pipeline
import org.iot.codegenerator.codeGenerator.Provider
import org.iot.codegenerator.codeGenerator.Sensor
import org.iot.codegenerator.codeGenerator.Transformation

import static extension org.eclipse.emf.ecore.util.EcoreUtil.*
import static extension org.eclipse.xtext.EcoreUtil2.*
import org.iot.codegenerator.codeGenerator.Variables

/**
 * This class contains custom scoping description.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#scoping
 * on how and when to use it.
 */
class CodeGeneratorScopeProvider extends AbstractCodeGeneratorScopeProvider {

	override getScope(EObject context, EReference reference) {
		val codeGen = CodeGeneratorPackage.eINSTANCE
		switch (reference) {
			case codeGen.baseBoard_Supertypes:
				context.extendableBoards
			case codeGen.overrideSensor_Sensor:
				context.overriableSensors
			case codeGen.reference_Variable:
				context.variableScope
			case codeGen.transformationOut_Source,
			case codeGen.channelOut_Source:
				context.variablesScope
			case codeGen.transformation_Provider:
				context.transInIdScope
			default:
				super.getScope(context, reference)
		}
	}

	/**
	 * get all types of board that is defined before current context and
	 * it is not possible to extend boards defined after the current board.
	 */
	def private IScope getExtendableBoards(EObject context) {
		val deviceConf = context.getContainerOfType(DeviceConf)
		Scopes.scopeFor(
			deviceConf.board.takeWhile[it != context]
		)
	}

	/**
	 * gets all the possible sensors from the supertypes
	 * to know which is possible to override.
	 */
	def private IScope getOverriableSensors(EObject context) {
		val currentboard = context.getContainerOfType(BaseBoard)
		val supertypes = currentboard.supertypes
		var list = new ArrayList<Sensor>()
		if (supertypes.length > 0) {
			for (supertype : supertypes) {
				val sensors = supertype.sensors
				for (sensor : sensors) {
					list.add(sensor)
				}
			}
		}
		Scopes.scopeFor(list,QualifiedName.wrapper[name],IScope.NULLSCOPE)
	}
	
	def static String getName(Sensor sensor){
		switch(sensor){
			OverrideSensor:
				sensor.sensor.name
			AbstractSensor:
				sensor.sensortype
			BaseSensor:
				sensor.name 
		}
	}

	def private IScope getVariableScope(EObject context) {
		val mapContainer = context.getContainerOfType(Pipeline)?.eContainer()?.getContainerOfType(Map)
		if (mapContainer !== null) {
			Scopes.scopeFor((Collections.singleton(mapContainer.output)))
		} else {
			val providerContainer = context.eContainer.getContainerOfType(Provider)
			Scopes.scopeFor(providerContainer.variablesOnProvider.ids)
		}
	}
	
	//switch on different provider type. Not "case" when switching on objects.
	def static Variables getVariablesOnProvider(Provider provider){
		switch(provider){
			OverrideSensor:
				provider.variables
			BaseSensor:
				provider.variables
			Transformation:
				provider.variables
		}
	}

	def private IScope getVariablesScope(EObject context) {
		Scopes.scopeFor(Collections.singleton(context.getContainerOfType(Provider).variablesOnProvider))
	}

	def private IScope getTransInIdScope(EObject context) {
		var scope = context.eContainer.getContainerOfType(Cloud)?.getOutputDefinitionsFrom(Board, Fog)
		if (scope === null) {
			scope = context.eContainer.getContainerOfType(Fog)?.getOutputDefinitionsFrom(Board)
			if (scope === null) {
				return IScope.NULLSCOPE
			}
			return Scopes.scopeFor(scope)
		}
		return Scopes.scopeFor(scope)
	}

	def private Iterable<Data> getOutputDefinitionsFrom(EObject context, Class<? extends EObject>... types) {
		types.flatMap [
			context.getSiblingsOfType(it).allContents.filter(Data).toIterable
		]
	}
}
