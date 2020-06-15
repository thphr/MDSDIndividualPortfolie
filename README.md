The DSL can be written using the extension; iot
To run the DSL, following DSL program can be used:


language python  
channel endpoint1
channel inserial
channel outserial

abstract board anotherboard 
	abstract sensor motion 
	
board rangerboard version pixi  
	in inserial  

	sensor thermometer as x(a,b)   
		sample signal     
		       
		data temperature      
			out endpoint1 x.map[false -> c]
	       
		data debug   
			out outserial x.map[1 + " : " + 0 -> c] 
			
	sensor thermistor (12,13) as x(a,b)
		sample frequency 10
		                
		data voltage 
			out endpoint1 x.filter[5 > 100].byWindow[20].median
			out outserial x.map[5 -> c]
 
board esp32 version wrover extends anotherboard, rangerboard   
	in inserial   
	
	override sensor thermometer as x(a,b) 
		sample signal
		
		data temperature    
			out endpoint1 x.map[2 -> c]
	
	override sensor motion as x(a,b,c) 
		sample signal
		
		data movement 
			out endpoint1 x.map[4 -> b]
 
fog 
	transformation temperature as x(a)
		data temperature_max
			out x	  
 
cloud 
	transformation voltage as x(a) 
		data voltage_mean
			out x

