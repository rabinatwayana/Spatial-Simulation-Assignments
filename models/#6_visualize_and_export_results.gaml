/**
* Name: NewModel1
* Based on the internal empty template. 
* Author: rabinatwayana
* Tags: 
*/
model GrazingCows

/* Insert your model definition here */
global {
	float total_available_grass;
	list<float> available_grass_list <- [];
	float total_grass_eaten;
	int total_cow <- 12;
	float mean_biomass;
	float min_biomass;
	float max_biomass;

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
		create cows number: total_cow {
			location <- any_location_in(grassland);
		}

		// 		grassland_cells <- grass where (location intersects grassland);
		// 		
		list<float> biomass_values <- [];
		loop g over: grass {
			bool is_pasture <- g intersects (grassland);
			if is_pasture {
				biomass_values <- biomass_values + [g.biomass];
			}

		}

		write length(biomass_values);
		mean_biomass <- mean(biomass_values);
		min_biomass <- min(biomass_values);
		max_biomass <- max(biomass_values);
		write min_biomass;
	}

	reflex update_mean_biomass_value {
		total_grass_eaten <- 0.0;
		total_available_grass <- 0.0;
		list<float> biomass_values <- [];
		loop g over: grass {
			bool is_pasture <- g intersects (grassland);
			if is_pasture {
				biomass_values <- biomass_values + [g.biomass];
			}

		}

		mean_biomass <- mean(biomass_values);
		min_biomass <- min(biomass_values);
		max_biomass <- max(biomass_values);
		//        write min_biomass;
		write length(available_grass_list);
		available_grass_list <- [];
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

		//		list<float> biomass_values <- [];

		//finding best spot to graze
		float max_biomass <- 0.0;
		grass my_grass;
		loop i over: my_grasses {
			if max_biomass < i.biomass {
				my_grass <- i;
				max_biomass <- i.biomass;
			}

		}

		ask my_grasses {
			if biomass > 0 {
				add biomass to: available_grass_list;
				//				total_available_grass <- total_available_grass+ biomass;
				biomass <- biomass - 0.1; //biomass is a grid variable in this example
				total_grass_eaten <- total_grass_eaten + 0.1;
			}

		}

	}

	aspect cow_action_neighbourhood {
		draw cow_action_area color: #goldenrod;
	}

	aspect default {
		draw circle(3) color: #brown;
	}

}

grid grass cell_width: 50 cell_height: 50 {
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
			biomass <- 3.0;
		} else if is_cutback_2020 {
			biomass <- 3.5;
		} else if is_cutback_2021_23 {
			biomass <- 3.0;
		} else {
			biomass <- 0.0;
		} }

		//grass growth
	reflex grow when: is_pasture {
		if (is_meadow and biomass < 6.1) or (is_cutback_2020 and biomass < 7.1) or (is_cutback_2021_23 and biomass < 6.1) or (is_hirschanger and biomass < 4.1) {
			biomass <- biomass + 0.1;
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

	reflex save_data {
		save [cycle, mean_biomass, min_biomass, max_biomass] to: "../results/results.csv" format:"csv" rewrite: false header: true;
	}

	output {
		display map_2d {
			species vierkher aspect: vierkher_polygon_aspect;
			species hirschanger aspect: hirschanger_polygon_aspect;
			species meadow aspect: meadow_polygon_aspect;
			species cleaned_2020 aspect: cleaned_2020_polygon_aspect;
			species cleaned_2021 aspect: cleaned_2021_polygon_aspect;
			species cleaned_2022 aspect: cleaned_2022_polygon_aspect;
			species cleaned_2023 aspect: cleaned_2023_polygon_aspect;
			species grass aspect: default;
			species cows aspect: cow_action_neighbourhood transparency: 0.1;
			species cows aspect: default;
		}

		display "chart_1" {
			chart "Biomass Ditribution of Grassland" type: series {
				data "Average Biomass" value: mean_biomass marker: false;
				data "Minimum Biomass" value: min_biomass marker: false;
				data "Maximim Biomass" value: max_biomass marker: false;
			}

		}

		display "chart_2" {
			chart "Average Grass Eaten by Cows" type: series {
				data "Average grass eaten by cow" value: total_grass_eaten / total_cow color: #blue marker: false;
			}

		}

		display "chart_3" {
			chart "Average grass eaten by cow vs average grass available" type: xy background: #white {
				data "Average available Grass per Cell Vs Mean Grass Eaten per Cow" value: length(available_grass_list) > 0 ?
				[sum(available_grass_list) / length(available_grass_list), total_grass_eaten / total_cow] : [0, 0] color: #blue;
			}

		}

	}

}

//maximum biomass. max biomass for lower pasture and cutback 2021-23 = 6; for Hirschanger = 4; for cutback 2020 = 7.

