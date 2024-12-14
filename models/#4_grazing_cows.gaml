/**
* Name: NewModel1
* Based on the internal empty template. 
* Author: rabinatwayana
* Tags: 
*/
model GrazingCows

/* Insert your model definition here */
global {
	float total_biomass <- 0.0;
	int total_grassland_cell <- 0;
	float mean_biomass;
	grass best_spot;

	//	float step <- 24*60 #minute;
	// Load geospatial file
	file vierkaser_file <- file("../includes/grazing_cows/Vierkaser.geojson"); // a polygon file
	file hirschanger_file <- file("../includes/grazing_cows/Hirschanger.geojson");
	file meadow_file <- file("../includes/grazing_cows/Meadow.geojson");
	file cleaned_2020_file <- file("../includes/grazing_cows/cleaned_2020.geojson");
	file cleaned_2021_file <- file("../includes/grazing_cows/cleaned_2021.geojson");
	file cleaned_2022_file <- file("../includes/grazing_cows/cleaned_2022.geojson");
	file cleaned_2023_file <- file("../includes/grazing_cows/cleaned_2023.geojson");
	geometry vierkaser_polygon <- geometry(vierkaser_file);
	geometry hirschanger_polygon <- geometry(hirschanger_file);
	geometry meadow_polygon <- geometry(meadow_file);
	geometry cleaned_2020_polygon <- geometry(cleaned_2020_file);
	geometry cleaned_2021_polygon <- geometry(cleaned_2021_file);
	geometry cleaned_2022_polygon <- geometry(cleaned_2022_file);
	geometry cleaned_2023_polygon <- geometry(cleaned_2023_file);
	geometry grassland <- geometry(hirschanger_file + meadow_file + cleaned_2020_file + cleaned_2021_file + cleaned_2022_file + cleaned_2023_file);
	geometry shape <- envelope(vierkaser_file);

	init {
		create vierkher from: [vierkaser_polygon];
		create hirschanger from: [hirschanger_polygon];
		create meadow from: [meadow_polygon];
		create cleaned_2020 from: [cleaned_2020_polygon];
		create cleaned_2021 from: [cleaned_2021_polygon];
		create cleaned_2022 from: [cleaned_2022_polygon];
		create cleaned_2023 from: [cleaned_2023_polygon];
		create cows number: 12 {
			location <- any_location_in(grassland);
		}

		total_biomass <- 0.0;
		total_grassland_cell <- 0;
		loop i over: grass {
			bool is_pasture <- i intersects (grassland);
			if is_pasture {
			//				write ("is_pasture");
				total_biomass <- total_biomass + i.biomass;
				total_grassland_cell <- total_grassland_cell + 1;
			}

		}

		mean_biomass <- total_biomass / total_grassland_cell;
	}

	reflex update_mean_biomass_value {
		total_biomass <- 0.0;
		total_grassland_cell <- 0;
		loop i over: grass {
			bool is_pasture <- i intersects (grassland);
			if is_pasture {
			//				write ("is_pasture");
				total_biomass <- total_biomass + i.biomass;
				total_grassland_cell <- total_grassland_cell + 1;
			}

		}

		mean_biomass <- total_biomass / total_grassland_cell;
	}

}

species vierkher {

	aspect vierkher_polygon_aspect {
		draw vierkaser_polygon color: #white border: #black;
	}

}

species hirschanger {

	aspect hirschanger_polygon_aspect {
		draw hirschanger_polygon color: #green border: #black;
	}

}

species meadow {

	aspect meadow_polygon_aspect {
		draw meadow_polygon color: #blue border: #black;
	}

}

species cleaned_2020 {

	aspect cleaned_2020_polygon_aspect {
		draw cleaned_2020_polygon color: #yellow border: #black;
	}

}

species cleaned_2021 {

	aspect cleaned_2021_polygon_aspect {
		draw cleaned_2021_polygon color: #orange border: #black;
	}

}

species cleaned_2022 {

	aspect cleaned_2022_polygon_aspect {
		draw cleaned_2022_polygon color: #purple border: #black;
	}

}

species cleaned_2023 {

	aspect cleaned_2023_polygon_aspect {
		draw cleaned_2023_polygon color: #grey border: #black;
	}

}

species cows skills: [moving] {
	float action_radius <- 10 #m;
	geometry cow_action_area;

	reflex move_cow {
		do wander speed: 5.0 amplitude: 90.0 bounds: grassland;
	}

	reflex update_cow_actionArea {
	//		cow_action_area <- circle(action_radius) intersection cone(heading - 45, heading + 45);
		cow_action_area <- circle(action_radius);
	}

	reflex cow_graze {
		list<grass> my_grasses <- grass intersecting (cow_action_area);
		list<float> biomass_values <- [];
		best_spot <- (my_grasses with_max_of (each.biomass));

		//		float max_biomass <- 0.0;
		//		grass my_grass;
		//		loop i over: my_grasses {
		//			if max_biomass < i.biomass {
		//				my_grass <- i;
		//				max_biomass <- i.biomass;
		//			}
		//
		//		}
		ask best_spot {
			biomass <- biomass - 0.1; //biomass is a grid variable in this example
		}

	}

	aspect cow_action_neighbourhood {
		draw cow_action_area color: #goldenrod;
	}

	aspect default {
		draw circle(3) color: #brown;
	}

}

grid grass cell_width: 5 cell_height: 5 {
//declare variables
	float biomass;
	bool is_pasture <- self intersects (grassland);
	bool is_hirschanger <- self intersects (hirschanger_polygon);
	bool is_meadow <- self intersects (meadow_polygon);
	bool is_cutback_2020 <- self intersects (cleaned_2020_polygon);
	bool is_cutback_2021_23 <- self intersects (cleaned_2021_polygon + cleaned_2022_polygon + cleaned_2023_polygon);

	init {
		if is_hirschanger {
			biomass <- 2.0;
		} else if is_meadow {
		//			write ("is_meadow");
			biomass <- 3.0;
			//			write (biomass);
		} else if is_cutback_2020 {
			biomass <- 3.5;
		} else if is_cutback_2021_23 {
			biomass <- 3.0;
		} else {
			biomass <- 0.0;
		} }

		//grass growth
	reflex grow when: is_pasture {
	//		if (is_meadow and biomass < 6.1) {
	//			write (biomass);
	//		}
		if (is_meadow and biomass < 6.1) or (is_cutback_2020 and biomass < 7.1) or (is_cutback_2021_23 and biomass < 6.1) or (is_hirschanger and biomass < 4.1) {
		//			write (biomass);
		//			write ("before"); 
			biomass <- biomass + 0.1;
			//			write (biomass);
			//			write ("after"); 
		}

	}

	aspect default {
		if biomass = 0 {
			draw square(5) color: rgb(0, 0, 0, 0);
		} else {
		//			draw square(5) color: rgb(0, int(biomass * 40), 0) border: rgb(0, int(biomass * 40), 0);
			draw square(5) color: rgb(0, 255 - int(biomass * 20), 0) border: rgb(0, 255 - int(biomass * 20), 0);
			//			draw square(5) color: rgb(0, 255 - int(60 * 2), 0) border: rgb(0, 255 - int(60 * 2), 0);
		}

	} }

experiment main_experiment type: gui {
	output {
		display map {
			species vierkher aspect: vierkher_polygon_aspect;
			//			species hirschanger aspect: hirschanger_polygon_aspect;
			//			species meadow aspect: meadow_polygon_aspect;
			//			species cleaned_2020 aspect: cleaned_2020_polygon_aspect;
			//			species cleaned_2021 aspect: cleaned_2021_polygon_aspect;
			//			species cleaned_2022 aspect: cleaned_2022_polygon_aspect;
			//			species cleaned_2023 aspect: cleaned_2023_polygon_aspect;
			species grass aspect: default;
			species cows aspect: cow_action_neighbourhood transparency: 0.1;
			species cows aspect: default;
		}

		display "my_display" {
			chart "Average Biomass Over Time" type: series {
				data "Average Biomass" value: mean_biomass;
			}

		}

	}

}

//maximum biomass. max biomass for lower pasture and cutback 2021-23 = 6; for Hirschanger = 4; for cutback 2020 = 7.

