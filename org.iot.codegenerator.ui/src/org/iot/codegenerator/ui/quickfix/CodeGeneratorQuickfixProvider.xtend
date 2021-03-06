/*
 * generated by Xtext 2.20.0
 */
package org.iot.codegenerator.ui.quickfix

import org.eclipse.xtext.nodemodel.INode
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.ui.editor.quickfix.DefaultQuickfixProvider
import org.eclipse.xtext.ui.editor.quickfix.Fix
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionAcceptor
import org.eclipse.xtext.validation.Issue
import org.iot.codegenerator.codeGenerator.DeviceConf
import org.iot.codegenerator.validation.CodeGeneratorValidator

import static extension org.eclipse.xtext.EcoreUtil2.*

/**
 * Custom quickfixes.
 * 
 * See https://www.eclipse.org/Xtext/documentation/310_eclipse_support.html#quick-fixes
 */
class CodeGeneratorQuickfixProvider extends DefaultQuickfixProvider {

	@Fix(CodeGeneratorValidator.UNUSED_VARIABLE)
	def void insertUsageOfVariable(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, "Use the variable in fog",
			"The variable is not used, please consider using the variable", null, [ element, context |
				val deviceConf = element.eContainer.getContainerOfType(DeviceConf)
				val fog = deviceConf.fog.last
				val transformation = fog.transformations.last
				val INode node = NodeModelUtils.getNode(transformation)    
				val issueText = context.xtextDocument.get(issue.offset, issue.length)            

                context.xtextDocument.replace(node.endOffset,0,"\n\ttransformation " + issueText + " as x(a) \n" + "\t\tdata x \n" + "\t\t\tout x")
                
			])
	}

	
	@Fix(CodeGeneratorValidator.UNUSED_VARIABLE)
	def void insertUsageOfVariableCloud(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, "Use the variable in cloud",
			"The variable is not used, please consider using the variable", null, [ element, context |
				val deviceConf = element.eContainer.getContainerOfType(DeviceConf)
				val cloud = deviceConf.cloud.last
				val transformation = cloud.transformations.last
				val INode node = NodeModelUtils.getNode(transformation)    
				val issueText = context.xtextDocument.get(issue.offset, issue.length)            

                context.xtextDocument.replace(node.endOffset,0,"\n\ttransformation " + issueText + " as x(a) \n" + "\t\tdata x \n" + "\t\t\tout x")
                
			])
	}
}
