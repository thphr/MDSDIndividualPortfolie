package org.iot.codegenerator.generator.python.board

import com.google.inject.Inject
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.iot.codegenerator.codeGenerator.BaseBoard
import org.iot.codegenerator.codeGenerator.Board
import org.iot.codegenerator.codeGenerator.ScreenOut
import org.iot.codegenerator.util.CommonLibrary

import static extension org.iot.codegenerator.generator.python.GeneratorUtil.*

class BoardGenerator {

	@Inject CompositionRootGenerator compositionRootGenerator
	@Inject SensorProviderGenerator sensorProviderGenerator
	@Inject DeviceGenerator deviceGenerator
	@Inject SensorGenerator sensorGenerator 
	@Inject extension CommonLibrary
	static IFileSystemAccess2 _fsa
	static BaseBoard currentBoard
	def compile(BaseBoard board, IFileSystemAccess2 fsa) {
		currentBoard = board
		BoardGenerator._fsa = fsa
		fsa.generateFile('''«folderName»/composition_root.py''', compositionRootGenerator.compile(board))
		fsa.generateFile('''«folderName»/sensor_provider.py''', sensorProviderGenerator.compile(board))
		fsa.generateFile('''«folderName»/«board.name.asModule».py''', deviceGenerator.compile(board))

		if (fsa.isFile("board/main.py")) {
			val mainContents = fsa.readTextFile("board/main.py")
			fsa.generateFile('''«folderName»/main.py''', mainContents)
		} else {
			fsa.generateFile('''«folderName»/main.py''', compileMain(board))
		}

		board.allSensors.forEach [
			fsa.generateFile('''«folderName»/«name».py''', sensorGenerator.compile(it))
		]

		"/libfiles/communication.py".compileAsLibfile()
		"/libfiles/pipeline.py".compileAsLibfile()
		"/libfiles/thread.py".compileAsLibfile()
		
		if (board.usesOled) {
			"/libfiles/ssd1306.py".compileAsLibfile()
			"/libfiles/LICENSE_ssd1306.txt".compileAsLibfile()
		}
	}

	def static compileAsLibfile(String path) {
		try (val stream = BoardGenerator.classLoader.getResourceAsStream(path)) {
			val fileName = BoardGenerator._fsa.getURI(path).deresolve(BoardGenerator._fsa.getURI("libfiles/"))
			BoardGenerator._fsa.generateFile('''«folderName»/«fileName.path»''', stream)
		}
	}
	
	def usesOled(Board board) {
		return !board.eContents.filter(ScreenOut).empty
	}

	def String compileMain(BaseBoard board) {
		'''
			from composition_root import CompositionRoot
			
			class CustomCompositionRoot(CompositionRoot):
				# This file will not be overwritten by the IoT code generator.
				# 
				# To adapt the generated code, override the methods from CompositionRoot
				# inside this class, for instance:
				# 
				# def provide_«board.name.asModule»(self):
				#     board = super().provide_«board.name.asModule»()
				#     board.add_sensor(...)
				«IF board.input !== null»
					#     board.set_input_channel(...)
				«ENDIF»
				#     board.add_output_channel(...)
				pass
			
			CustomCompositionRoot().provide_«board.name.asModule»().run()
		'''
	}
	
	 def static folderName(){
		'''board-«currentBoard.name»'''
	}
}
