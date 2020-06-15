from composition_root import CompositionRoot

class CustomCompositionRoot(CompositionRoot):
	# This file will not be overwritten by the IoT code generator.
	# 
	# To adapt the generated code, override the methods from CompositionRoot
	# inside this class, for instance:
	# 
	# def provide_esp32(self):
	#     board = super().provide_esp32()
	#     board.add_sensor(...)
	#     board.set_input_channel(...)
	#     board.add_output_channel(...)
	pass

CustomCompositionRoot().provide_esp32().run()
