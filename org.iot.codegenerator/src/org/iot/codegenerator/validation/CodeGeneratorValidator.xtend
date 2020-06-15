/*
 * generated by Xtext 2.20.0
 */
package org.iot.codegenerator.validation

import com.google.common.collect.Sets
import com.google.inject.Inject
import java.util.ArrayList
import java.util.Arrays
import java.util.HashMap
import java.util.List
import java.util.Set
import java.util.stream.Collectors
import java.util.stream.Stream
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.validation.Check
import org.eclipse.xtext.validation.CheckType
import org.iot.codegenerator.codeGenerator.AbstractBoard
import org.iot.codegenerator.codeGenerator.And
import org.iot.codegenerator.codeGenerator.BaseBoard
import org.iot.codegenerator.codeGenerator.BaseSensor
import org.iot.codegenerator.codeGenerator.Board
import org.iot.codegenerator.codeGenerator.ChannelOut
import org.iot.codegenerator.codeGenerator.CodeGeneratorPackage
import org.iot.codegenerator.codeGenerator.Conditional
import org.iot.codegenerator.codeGenerator.Data
import org.iot.codegenerator.codeGenerator.DeviceConf
import org.iot.codegenerator.codeGenerator.Div
import org.iot.codegenerator.codeGenerator.Equal
import org.iot.codegenerator.codeGenerator.Exponent
import org.iot.codegenerator.codeGenerator.ExtSensor
import org.iot.codegenerator.codeGenerator.Filter
import org.iot.codegenerator.codeGenerator.GreaterThan
import org.iot.codegenerator.codeGenerator.GreaterThanEqual
import org.iot.codegenerator.codeGenerator.Language
import org.iot.codegenerator.codeGenerator.LessThan
import org.iot.codegenerator.codeGenerator.LessThanEqual
import org.iot.codegenerator.codeGenerator.Minus
import org.iot.codegenerator.codeGenerator.Mul
import org.iot.codegenerator.codeGenerator.Negation
import org.iot.codegenerator.codeGenerator.Not
import org.iot.codegenerator.codeGenerator.OnbSensor
import org.iot.codegenerator.codeGenerator.Or
import org.iot.codegenerator.codeGenerator.Pipeline
import org.iot.codegenerator.codeGenerator.Plus
import org.iot.codegenerator.codeGenerator.Provider
import org.iot.codegenerator.codeGenerator.Sensor
import org.iot.codegenerator.codeGenerator.SensorData
import org.iot.codegenerator.codeGenerator.SensorDataOut
import org.iot.codegenerator.codeGenerator.Transformation
import org.iot.codegenerator.codeGenerator.TransformationData
import org.iot.codegenerator.codeGenerator.TransformationOut
import org.iot.codegenerator.codeGenerator.Unequal
import org.iot.codegenerator.codeGenerator.Variable
import org.iot.codegenerator.codeGenerator.Variables
import org.iot.codegenerator.codeGenerator.WindowPipeline
import org.iot.codegenerator.typing.TypeChecker

import static extension org.eclipse.xtext.EcoreUtil2.*
import org.iot.codegenerator.codeGenerator.AbstractSensor
import org.iot.codegenerator.codeGenerator.OverrideSensor
import org.iot.codegenerator.util.CommonLibrary
import java.util.HashSet

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class CodeGeneratorValidator extends AbstractCodeGeneratorValidator {

	public static val INCORRECT_INPUT_TYPE_PIN = "org.iot.codegenerator.IncorrectInputTypePin"
	public static val INCORRECT_INPUT_TYPE_I2C = "org.iot.codegenerator.IncorrectInputTypeI2c"
	public static val UNUSED_VARIABLE = "org.iot.codegenerator.UnusedVariable"

	@Inject
	extension TypeChecker

	@Inject extension CommonLibrary

	/**
	 * Checks for cyclic dependency on extended boards.
	 */
	@Check
	def checkCyclicDependency(BaseBoard board) {
		if (board.supertypes?.size == 0) {
			return
		}
		val checkedEntities = newHashSet(board)
		cyclicIteration(checkedEntities, board)
	}

	/**
	 * Recursive check on cyclic dependency.
	 */
	def cyclicIteration(HashSet<BaseBoard> checkedEntities, BaseBoard board) {
		if (board.supertypes?.size == 0) {
			return
		}
		for (currentBoard : board.supertypes) {
			if (currentBoard instanceof BaseBoard) {
				if (checkedEntities.contains(currentBoard)) {
					error('''Cyclic dependency: «currentBoard.name»''', board,
						CodeGeneratorPackage.eINSTANCE.board_Name)
				}
				checkedEntities.add(currentBoard)
				cyclicIteration(checkedEntities, currentBoard)
			}
		}
	}

	/**
	 * Checks that no duplicate base sensor are defined between 
	 * the baseboard and the inherited board.
	 */
	@Check
	def checkNoDuplicateSensorOnInheritance(BaseBoard board) {
		val supertypes = board.supertypes
		val baseSensors = board.sensors.filter[it instanceof BaseSensor]
		val allInheritedSensors = new ArrayList<Sensor>
		val allSensors = new ArrayList<Sensor>

		for (supertype : supertypes) {
			allInheritedSensors.addAll(supertype.sensors)
		}

		val baseInheritedSensors = allInheritedSensors.filter[it instanceof BaseSensor]

		allSensors.addAll(baseInheritedSensors)
		allSensors.addAll(baseSensors)

		val groupedSensors = allSensors.groupBy[it.name]
		groupedSensors.filter[sensorName, sensors|sensors.size > 1].forEach [ sensorName, sensors |
			{
				sensors.forEach [
					error('''Duplicate of sensor «sensorName». The sensor is already defined in the inherited board.''',
						it, CodeGeneratorPackage.eINSTANCE.baseSensor_Sensortype)
				]

			}
		]
	}

	/**
	 * Check if both extended boards has the same sensor name, if true
	 * throws an error on the extended board that it is illegal.
	 */
	@Check
	def checkMultipleInheritance(BaseBoard board) {
		val supertypes = board.supertypes
		val allInheritedSensors = new ArrayList<Sensor>

		for (supertype : supertypes) {
			allInheritedSensors.addAll(supertype.sensors)
		}
		val groupedSensors = allInheritedSensors.groupBy[it.name]
		groupedSensors.filter[sensorName, sensors|sensors.size > 1].forEach [ sensorName, sensors |
			{
				sensors.forEach [
					error('''Cannot inherit both boards at the same time. Duplicate of sensor «sensorName» on the extended boards.''',
						board, CodeGeneratorPackage.eINSTANCE.baseBoard_Supertypes)
				]

			}
		]
	}

	/**
	 * Check for duplicated sensor name on override sensors.
	 */
	@Check
	def checkDuplicateOverrideSensorName(BaseBoard board) {
		val overridesensors = board.listOfOverrideSensor
		val groupedSensors = overridesensors.groupBy[it.name]
		groupedSensors.filter[sensorName, sensors|sensors.size > 1].forEach [ sensorName, sensors |
			{
				sensors.forEach [
					error('''Duplicate of sensor «sensorName» on the board.''', it,
						CodeGeneratorPackage.eINSTANCE.overrideSensor_Sensor)
				]

			}
		]

	}

	/**
	 * Check for duplicated sensor name on base sensors.
	 */
	@Check
	def checkDuplicateBaseSensorName(BaseBoard board) {
		val baseSensors = board.sensors.filter[it instanceof BaseSensor]
		val groupedSensors = baseSensors.groupBy[it.name]
		groupedSensors.filter[sensorName, sensors|sensors.size > 1].forEach [ sensorName, sensors |
			{
				sensors.forEach [
					error('''Duplicate of sensor «sensorName» on the board''', it,
						CodeGeneratorPackage.eINSTANCE.baseSensor_Sensortype)
				]

			}
		]

	}

	/**
	 * Check if an onboard sensor is overriden with external sensor
	 * and the opposite. If the case, throw an error.
	 */
	@Check
	def checkOverrideMatchedOnbExtSensor(OverrideSensor sensor) {
		val board = sensor.getContainerOfType(BaseBoard)
		val supertypes = board.supertypes
		val allInheritedSensors = new ArrayList<Sensor>

		for (supertype : supertypes) {
			allInheritedSensors.addAll(supertype.sensors)
		}

		for (inheritedSensor : allInheritedSensors) {
			if (inheritedSensor.name == sensor.name) {
				if (inheritedSensor instanceof OnbSensor && sensor.pins.size > 0) {
					error('''An onboard sensor cannot be overriden by an external sensor''', sensor,
						CodeGeneratorPackage.eINSTANCE.overrideSensor_Sensor)
				}
				if (inheritedSensor instanceof ExtSensor && sensor.pins.size <= 0) {
					error('''An external sensor cannot be overriden by an onboard sensor''', sensor,
						CodeGeneratorPackage.eINSTANCE.overrideSensor_Sensor)
				}
			}
		}
	}

	/**
	 * Check Abstractboard only has abstract sensor
	 */
	@Check
	def checkAbstractSensorOnAbstractBoard(AbstractBoard board) {
		val sensors = board.sensors
		for (sensor : sensors) {
			if (!(sensor instanceof AbstractSensor)) {
				error('''The defined sensor must be an abstract sensor''', sensor,
					CodeGeneratorPackage.eINSTANCE.baseSensor_Sensortype)
			}
		}
	}

	/**
	 * Check whether an abstract sensor is overriden
	 * Abstract sensor must be overriden.
	 */
	@Check
	def checkIfAbstractSensorIsOverriden(AbstractBoard abstractboard) {
		val deviceconf = abstractboard.getContainerOfType(DeviceConf)
		val baseboards = deviceconf.listOfBaseboard
		for (board : baseboards) {
			val overridesensors = board.listOfOverrideSensor
			val supertypes = board.supertypes
			for (supertype : supertypes) {
				if (supertype instanceof AbstractBoard) {
					if (supertype.name == abstractboard.name) {
						val abstractsensors = supertype.listOfAbstractSensor

						val allNonOverridenSensors = abstractsensors.filter [ abstractsensor |
							!overridesensors.exists[overrideSensor|abstractsensor.name === overrideSensor.name]
						]
						allNonOverridenSensors.forEach [
							error('''The sensor «it.name» must be overriden''', board,
								CodeGeneratorPackage.eINSTANCE.baseBoard_Supertypes)
						]
					}
				}
			}
		}

	}

	def List<BaseBoard> getListOfBaseboard(DeviceConf deviceconf) {
		val baseboards = new ArrayList<BaseBoard>
		val boards = deviceconf.board
		for (board : boards) {
			if (board instanceof BaseBoard) {
				baseboards.add(board)
			}
		}

		return baseboards
	}

	def List<OverrideSensor> getListOfOverrideSensor(BaseBoard board) {
		val overridesensors = new ArrayList<OverrideSensor>
		val sensors = board.sensors
		for (sensor : sensors) {
			if (sensor instanceof OverrideSensor) {
				overridesensors.add(sensor)

			}
		}
		return overridesensors
	}

	def List<AbstractSensor> getListOfAbstractSensor(AbstractBoard board) {
		var abstractsensors = new ArrayList<AbstractSensor>
		val sensors = board.sensors
		for (sensor : sensors) {
			if (sensor instanceof AbstractSensor) {
				abstractsensors.add(sensor)
			}

		}

		return abstractsensors
	}

	@Check(CheckType.NORMAL)
	def checkDeviceConfiguration(DeviceConf configuration) {
		val boards = configuration.board

		if (boards.size() < 1) {
			error('''There must be a board definition''', CodeGeneratorPackage.eINSTANCE.deviceConf_Board)
			return
		}

//		else if (boards.size() > 1) {
//			error('''There must be exactly 1 board definition''', CodeGeneratorPackage.eINSTANCE.deviceConf_Board)
//			return
//		}
		val clouds = configuration.cloud

		if (clouds.size() < 1) {
			warning('''There should be a cloud definition''', CodeGeneratorPackage.eINSTANCE.deviceConf_Cloud)
			return
		} else if (clouds.size() > 1) {
			error('''There must be at most 1 cloud definition''', CodeGeneratorPackage.eINSTANCE.deviceConf_Cloud)
			return
		}

		val fogs = configuration.fog

		if (fogs.size() > 1) {
			error('''There must be at most 1 fog definition''', CodeGeneratorPackage.eINSTANCE.deviceConf_Fog)
			return
		}
	}

	@Check
	def validateBoard(BaseBoard board) {
		val b = UtilityBoard.getBoard(board)
		if (b === null) {
			error('''unsupported board type «board.name»''', CodeGeneratorPackage.eINSTANCE.board_Name)
		} else if (b.sensors === null) {
			error('''unsupported version «board.version» for board type «board.name»''',
				CodeGeneratorPackage.eINSTANCE.baseBoard_Version)
		} else {
			info('''«board.version» supports the following sensors: «b.sensors»''',
				CodeGeneratorPackage.eINSTANCE.baseBoard_Version)
		}
	}

	@Check
	def validateOnboardSensor(Sensor sensor) {
		if (sensor instanceof OnbSensor) {
			val cb = sensor.getContainerOfType(BaseBoard)
			val b = UtilityBoard.getBoard(cb)
			val s = sensor as OnbSensor
			val variableCount = b.getVariableCount(s.sensortype)

			// Do not bother with invalid boards
			if (b.sensors === null) {
				return
			}

			if (variableCount == -1) {
				error('''«b» does not support sensor: «s.sensortype»''',
					CodeGeneratorPackage.eINSTANCE.baseSensor_Sensortype)
			} else if (variableCount < s.variables.ids.length) {
				error('''Maximum number of output variables for sensor type «s.sensortype» is «variableCount»''',
					CodeGeneratorPackage.eINSTANCE.baseSensor_Sensortype)
			} else if (variableCount > s.variables.ids.length) {
				info('''«s.sensortype» supports up to «variableCount» variables''',
					CodeGeneratorPackage.eINSTANCE.baseSensor_Sensortype)
			}
		}
	}

	@Check
	def validatePinsMatchesVars(Variables variables) {
		val parent = variables.eContainer
		switch parent {
			ExtSensor:
				if (parent.pins.size() < variables.ids.size()) {
					error('''Expected «parent.pins.size()» pin inputs, got «variables.ids.size()»''',
						CodeGeneratorPackage.eINSTANCE.variables_Ids)
				} else if (parent.pins.size() > variables.ids.size()) {
					warning('''Number of pin inputs shuld match number of variables after "as"''',
						CodeGeneratorPackage.eINSTANCE.variables_Ids)
				}
		}
	}

	@Check
	def validateLanguage(Language lang) {
		var approved = Arrays.asList("python", "cplusplus")
		if (!approved.contains(lang.name)) {
			error('''no support for language «lang.name», only "python" and "cplusplus"''',
				CodeGeneratorPackage.eINSTANCE.language_Name)
		} else {
			info('''generator supports "python" and "cplusplus"''', CodeGeneratorPackage.eINSTANCE.language_Name)
		}
	}

	def checkNoDuplicateDataName(List<Data> datas) {
		val dataNameValues = new HashMap<String, Set<Data>>
		for (data : datas) {
			val name = data.name
			if (dataNameValues.containsKey(name)) {
				dataNameValues.get(name).add(data)
			} else {
				dataNameValues.put(name, Sets.newHashSet(data))
			}
		}

		for (Set<Data> dataSet : dataNameValues.values) {
			if (dataSet.size > 1) {
				for (data : dataSet) {
					error('''duplicate «data.name»''', data, CodeGeneratorPackage.eINSTANCE.data_Name)
				}
			}
		}
	}

	@Check
	def validateUsageOfdataDeclaration(SensorData data) {
		val deviceConf = data.eContainer.getContainerOfType(DeviceConf)
		val fog = deviceConf.fog.last
		val cloud = deviceConf.cloud.last
		val list = Stream.concat(fog.transformations.stream(), cloud.transformations.stream()).collect(
			Collectors.toList());

		if (!list.exists[it.provider == data]) {
			warning('''Unused variable''', data, CodeGeneratorPackage.Literals.DATA__NAME, UNUSED_VARIABLE)

		}

	}

	@Check
	def validateData(Data data) {
		var datas = new ArrayList<Data>
		for (EObject eObject : data.eResource.getContents()) {
			if (eObject instanceof DeviceConf) {
				val deviceConf = eObject as DeviceConf
				val board = deviceConf.board
				val cloud = deviceConf.cloud
				val fog = deviceConf.fog

				if (board.size > 0 && board instanceof BaseBoard) {
					for (Sensor sensor : board.get(0).sensors) {
						if (sensor instanceof BaseSensor) {
							datas.addAll(sensor.datas)
						}
					}
				}

				if (cloud.size > 0) {
					for (Transformation transformation : cloud.get(0).transformations) {
						datas.addAll(transformation.datas)
					}
				}

				if (fog.size > 0) {
					for (Transformation transformation : fog.get(0).transformations) {
						datas.addAll(transformation.datas)
					}
				}

				checkNoDuplicateDataName(datas)
				return
			}
		}
	}

	def checkNoDuplicateVariableNamesInStatement(List<Variable> variables) {
		val variableNameValues = new HashMap<String, Set<Variable>>

		for (variable : variables) {
			val name = variable.name
			if (variableNameValues.containsKey(name)) {
				variableNameValues.get(name).add(variable)
			} else {
				variableNameValues.put(name, Sets.newHashSet(variable))
			}
		}

		for (Set<Variable> variableSet : variableNameValues.values) {
			if (variableSet.size > 1) {
				for (variable : variableSet) {
					error('''duplicate «variable.name»''', variable, CodeGeneratorPackage.eINSTANCE.variable_Name)
				}
			}
		}
	}

	@Check
	def validateVariable(Variables variables) {
		val eContainer = variables.eContainer
		if (eContainer instanceof Provider) {
			val provider = eContainer as Provider
			checkNoDuplicateVariableNamesInStatement(provider.variablesOnProvider.ids)

		}
	}

	def static Variables getVariablesOnProvider(Provider provider) {
		switch (provider) {
			OverrideSensor:
				provider.variables
			BaseSensor:
				provider.variables
			Transformation:
				provider.variables
		}
	}

	@Check
	def validateDataOut(Variables variables) {
		variables.cacheVariables
	}

	def checkSameTypeOfTransformationOutPipelines(List<TransformationOut> transformationOuts) {
		if (transformationOuts.size > 1) {
			val firstPipelineType = transformationOuts.get(0).pipeline.lastType
			for (TransformationOut transformationOut : transformationOuts) {
				val currentPipelineType = transformationOut.pipeline.lastType
				if (firstPipelineType !== currentPipelineType) {
					error(
						'''expected «firstPipelineType» got «currentPipelineType»''',
						transformationOut,
						CodeGeneratorPackage.eINSTANCE.transformationOut_Pipeline
					)
				}
			}
		}
	}

	def checkSameTypeOfChannelOutPipelines(List<ChannelOut> channelOuts) {
		if (channelOuts.size > 1) {
			val firstPipelineType = channelOuts.get(0).pipeline.lastType
			for (ChannelOut channelOut : channelOuts) {
				val currentPipelineType = channelOut.pipeline.lastType
				if (firstPipelineType !== currentPipelineType) {
					error(
						'''expected «firstPipelineType» got «currentPipelineType»''',
						channelOut,
						CodeGeneratorPackage.eINSTANCE.channelOut_Pipeline
					)
				}
			}
		}
	}

	def checkWindowPipeline(Pipeline pipeline) {
		if (pipeline instanceof WindowPipeline) {
			error('''cannot use byWindow on tuple type''', pipeline, CodeGeneratorPackage.eINSTANCE.pipeline_Next)
		}
	}

	@Check
	def validatePipelineOutputs(Data data) {
		if (data instanceof TransformationData) {
			var transformationOuts = new ArrayList<TransformationOut>
			val transformationDataOutputs = (data as TransformationData).outputs

			for (TransformationOut transformationOut : transformationDataOutputs) {
				transformationOuts.add(transformationOut)
				checkWindowPipeline(transformationOut.pipeline)
			}
			checkSameTypeOfTransformationOutPipelines(transformationOuts)
		} else if (data instanceof SensorData) {
			var channelOuts = new ArrayList<ChannelOut>
			val sensorDataOutputs = (data as SensorData).outputs

			for (SensorDataOut sensorDataOut : sensorDataOutputs) {
				if (sensorDataOut instanceof ChannelOut) {
					val channelOut = sensorDataOut as ChannelOut
					channelOuts.add(channelOut)
					checkWindowPipeline(channelOut.pipeline)
				}
			}
			checkSameTypeOfChannelOutPipelines(channelOuts)
		}
	}

	def validateTypes(TypeChecker.Type actual, TypeChecker.Type expected, EStructuralFeature error) {
		if (expected != actual) {
			error('''expected «expected» got «actual»''', error)
		}
	}

	def validateNumbers(TypeChecker.Type type, EStructuralFeature error) {
		if (!type.isNumberType) {
			error('''expected number got «type»''', error)
		}
	}

	@Check
	def validateFilterExpression(Filter filter) {
		filter.expression.type.validateTypes(TypeChecker.Type.BOOLEAN,
			CodeGeneratorPackage.Literals.TUPLE_PIPELINE__EXPRESSION)
	}

	@Check
	def checkExpression(Conditional conditional) {
		conditional.condition.type.validateTypes(TypeChecker.Type.BOOLEAN,
			CodeGeneratorPackage.Literals.CONDITIONAL__CONDITION)
		conditional.incorrect.type.validateTypes(conditional.correct.type,
			CodeGeneratorPackage.Literals.CONDITIONAL__INCORRECT)
	}

	@Check
	def checkExpression(Or or) {
		or.left.type.validateTypes(TypeChecker.Type.BOOLEAN, CodeGeneratorPackage.Literals.OR__LEFT)
		or.right.type.validateTypes(TypeChecker.Type.BOOLEAN, CodeGeneratorPackage.Literals.OR__RIGHT)
	}

	@Check
	def checkExpression(And and) {
		and.left.type.validateTypes(TypeChecker.Type.BOOLEAN, CodeGeneratorPackage.Literals.AND__LEFT)
		and.right.type.validateTypes(TypeChecker.Type.BOOLEAN, CodeGeneratorPackage.Literals.AND__RIGHT)
	}

	@Check
	def checkExpression(Equal equal) {
		if (!equal.left.type.isNumberType || !equal.right.type.isNumberType) {
			equal.right.type.validateTypes(equal.left.type, CodeGeneratorPackage.Literals.EQUAL__RIGHT)
		}
	}

	@Check
	def checkExpression(Unequal unequal) {
		if (!unequal.left.type.isNumberType || !unequal.right.type.isNumberType) {
			unequal.right.type.validateTypes(unequal.left.type, CodeGeneratorPackage.Literals.UNEQUAL__RIGHT)
		}
	}

	@Check
	def checkExpression(LessThan lessThan) {
		lessThan.left.type.validateNumbers(CodeGeneratorPackage.Literals.LESS_THAN__LEFT)
		lessThan.right.type.validateNumbers(CodeGeneratorPackage.Literals.LESS_THAN__RIGHT)
	}

	@Check
	def checkExpression(LessThanEqual lessThanEqual) {
		lessThanEqual.left.type.validateNumbers(CodeGeneratorPackage.Literals.LESS_THAN_EQUAL__LEFT)
		lessThanEqual.right.type.validateNumbers(CodeGeneratorPackage.Literals.LESS_THAN_EQUAL__RIGHT)
	}

	@Check
	def checkExpression(GreaterThan greaterThan) {
		greaterThan.left.type.validateNumbers(CodeGeneratorPackage.Literals.GREATER_THAN__LEFT)
		greaterThan.right.type.validateNumbers(CodeGeneratorPackage.Literals.GREATER_THAN__RIGHT)
	}

	@Check
	def checkExpression(GreaterThanEqual greaterThanEqual) {
		greaterThanEqual.left.type.validateNumbers(CodeGeneratorPackage.Literals.GREATER_THAN_EQUAL__LEFT)
		greaterThanEqual.right.type.validateNumbers(CodeGeneratorPackage.Literals.GREATER_THAN_EQUAL__RIGHT)
	}

	@Check
	def checkExpression(Plus plus) {
		if (plus.left.type != TypeChecker.Type.STRING && plus.right.type != TypeChecker.Type.STRING) {
			plus.left.type.validateNumbers(CodeGeneratorPackage.Literals.PLUS__LEFT)
			plus.right.type.validateNumbers(CodeGeneratorPackage.Literals.PLUS__RIGHT)
		}
	}

	@Check
	def checkExpression(Minus minus) {
		minus.left.type.validateNumbers(CodeGeneratorPackage.Literals.MINUS__LEFT)
		minus.right.type.validateNumbers(CodeGeneratorPackage.Literals.MINUS__RIGHT)
	}

	@Check
	def checkExpression(Mul mul) {
		mul.left.type.validateNumbers(CodeGeneratorPackage.Literals.MUL__LEFT)
		mul.right.type.validateNumbers(CodeGeneratorPackage.Literals.MUL__RIGHT)
	}

	@Check
	def checkExpression(Div div) {
		div.left.type.validateNumbers(CodeGeneratorPackage.Literals.DIV__LEFT)
		div.right.type.validateNumbers(CodeGeneratorPackage.Literals.DIV__RIGHT)
	}

	@Check
	def checkExpression(Negation negation) {
		negation.value.type.validateNumbers(CodeGeneratorPackage.Literals.NEGATION__VALUE)
	}

	@Check
	def checkExpression(Exponent exponent) {
		exponent.base.type.validateNumbers(CodeGeneratorPackage.Literals.EXPONENT__BASE)
		exponent.power.type.validateNumbers(CodeGeneratorPackage.Literals.EXPONENT__POWER)
	}

	@Check
	def checkPower(Not not) {
		not.value.type.validateTypes(TypeChecker.Type.BOOLEAN, CodeGeneratorPackage.Literals.NOT__VALUE)
	}

}
