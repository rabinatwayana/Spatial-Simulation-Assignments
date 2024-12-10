/**
* Name: LionDemographic Model
* Based on the internal empty template. 
* Author: rabinatwayana
* Tags: 
*/

// suggestion: write in experiment to print
model LionDemographic

global {
	int total_lion <- 20;
	float mean_age;
	int min_age;
	int max_age;
	list<int> age_list <- [];

	init {
		create lions number: total_lion;
		write "time step:" + cycle;
		write "Initial age list" + age_list;
		mean_age <- mean(age_list);
		min_age <- min(age_list);
		max_age <- max(age_list);
		write "The mean age of lions is:" + mean_age;
		write "The min age of lions is:" + min_age;
		write "The max age of lions is:" + max_age;
	}

	//reflex report 
	reflex report_lion_demographic {
		write "time step:" + cycle;
		write "Age list" + age_list;
		mean_age <- mean(age_list);
		min_age <- min(age_list);
		max_age <- max(age_list);
		write "The mean age of lions is:" + mean_age;
		write "The min age of lions is:" + min_age;
		write "The max age of lions is:" + max_age;
		age_list <- [];
	}

}

species lions {
	int lion_age <- rnd(1, 50);

	init {
		add lion_age to: age_list;
	}

	reflex get_older {
		lion_age <- lion_age + 1;
		add lion_age to: age_list;
	}

	reflex lion_maturity {
		if (lion_age > 60) {
			create lions number: 1 {
				lion_age <- 0;
			}

			write name + ": I will die";
			do die;
		}

	}

	aspect default {
		draw circle(2) color: rgb(int(min(mean_age * 5)), 0, 0); //245, 66
	}

}

experiment main_experiment type: gui {
	output {
		display map {
			species lions aspect: default;
		}

		display "Graph" {
			chart "Lion Demographic Distribution" type: series {
				data "Maximim Age" value: max_age;
				data "Average Age" value: mean_age;
				data "Minimum Age" value: min_age;
			}

		}

	}

}

