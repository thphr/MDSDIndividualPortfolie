/*
 * generated by Xtext 2.20.0
 */
package org.iot.codegenerator.generator

import com.google.inject.Inject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import org.iot.codegenerator.codeGenerator.BaseBoard
import org.iot.codegenerator.codeGenerator.Channel
import org.iot.codegenerator.codeGenerator.Cloud
import org.iot.codegenerator.codeGenerator.Fog
import org.iot.codegenerator.generator.python.board.BoardGenerator

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class CodeGeneratorGenerator extends AbstractGenerator {

	@Inject extension BoardGenerator

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		fsa.generateFile("config.json", resource.allContents.toIterable.filter(Channel).compile)
		
		val boards = resource.allContents.filter(BaseBoard)
		
		boards.forEach[it.compile(fsa)]
		
		val fog = resource.allContents.filter(Fog).next()
		// TODO
		
		val cloud = resource.allContents.filter(Cloud).next()
		// TODO
	}

	def String compile(Iterable<Channel> channels) {
		val channelFormat = '": {\n        "type": "",\n        "lane": ""\n    }'
		var compiled = '{\n    "wifi": {\n        "ssid": "",\n        "password": "",\n        "cloud": ""\n    },\n    "serial": {\n        "baud": "",\n        "databits": "",\n        "paritybits": "",\n        "stopbit": ""\n    },\n'
		for (channel : channels) {
			compiled += '    "' + channel.name + channelFormat + ',\n'
		}
		compiled.substring(0, compiled.length - 2) + '\n}\n'
	}
}
