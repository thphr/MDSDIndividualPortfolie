from composition_root import CompositionRoot

class CustomCompositionRoot(CompositionRoot):
	# This file will not be overwritten by the IoT code generator.
	# 
	# To adapt the generated code, override the methods from CompositionRoot
	# inside this class, for instance:
	# 
	# def provide_rangerboard(self):
	#     board = super().provide_rangerboard()
	#     board.add_sensor(...)
	#     board.set_input_channel(...)
	#     board.add_output_channel(...)
	pass

CustomCompositionRoot().provide_rangerboard().run()
