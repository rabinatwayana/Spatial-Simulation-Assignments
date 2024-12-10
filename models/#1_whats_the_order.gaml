/**
* Name: Assigment (What's the Order)
* Author: rabinatwayana
* Description: This model demonstrates the order of execution of different parts of a GAMA model
* Tags: 
*/
model OrderOfExecution

global {

	init {
//		write "time step:" + cycle;
		create range_agent number: 5;
		create random_agent number: 3;
		create float_agent number: 2;
	}

	reflex time_step {
		write "time step:" + cycle;
	}

}
 
species range_agent {
	int range_var <- index + 1 update: range_var + 2; // increase value by 2 in every step 
	init {
		write "Range agent init value: " + range_var;
	}

	reflex print_range_value {
		write "Range agent value: " + range_var;
	}

}

species random_agent {
	int random_var <- int(rnd(2, 6)) update: random_var + 2; // increase value by 2 in every step 
	init {
		write "Random agent init value: " + random_var;
	}

	reflex print_random_value {
		write "Random agent value: " + random_var;
	}

}

species float_agent {
	float float_var <- 0.0 update: float_var + 2; // increase value by 2 in every step 
	init {
		write "Float agent init value: " + float_var;
	}

	reflex print_float_value {
		write "Float agent value: " + float_var;
	}

}

grid CA width: 2 height: 2 {
	int grid_var update: grid_var + 2; // increase value by 2 in every step 
	init {
		grid_var <- grid_x; // assigning x-coordinate value to corresponding cell
		write "CA variable x-coordinate: " + grid_var;
	}

	reflex print_CA_value {
		write "CA variable: " + grid_var;
	}

}

experiment OrderOfExecution type: gui {
}





