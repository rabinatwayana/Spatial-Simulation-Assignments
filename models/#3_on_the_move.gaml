/**
* Name: movement
* Based on the internal empty template. 
* Author: rabinatwayana
* Tags: 
*/
model movement

global {

	init {
		create cows number: 5;
		create sheep number: 3;
		create goats number: 2;
	}

}

//move with correlated random walk at a speed of 2, 90 degrees
species cows skills: [moving] {
	geometry cow_action_area;

	reflex move_cow {
		do wander speed: 2.0 amplitude: 90.0;
	}

	reflex update_cow_actionArea {
		cow_action_area <- circle(2) intersection cone(heading - 45, heading + 45);
	}

	aspect cow_action_neighbourhood {
		draw cow_action_area color: #goldenrod;
	}

	aspect default {
		draw circle(1) color: #brown;
	}

}

// move all towards south; speed = 1 (east has heading 0!)
species sheep skills: [moving] {
	geometry sheep_action_area;

	reflex move_sheep {
		do move speed: 1.0 heading: 90.0;
	}

	aspect default {
		draw circle(1) color: #black;
	}

	reflex update_sheep_actionArea {
		write self.location;
		sheep_action_area <- line(self.location, self.location + {0.0, 1.0});
	}

	aspect sheep_action_neighbourhood {
		draw sheep_action_area color: #white width: 10;
	}

}

//slowly walk towards the origin with speed = 0.5, i.e. {0,0}
species goats skills: [moving] {
	geometry goat_action_area;

	reflex move_goat {
		do goto target: {0.0, 0.0} speed: 0.5;
	}

	aspect default {
		draw circle(1) color: #yellow;
	}

	reflex update_goat_actionArea {
		goat_action_area <- line(self.location, {0.0, 0.0}) intersection circle(0.5);
	}

	aspect goat_action_neighbourhood {
		draw goat_action_area color: #blue;
	}

}

grid grass {
//	float bio <- rnd(10.0);
//	reflex growth {
//		bio <- bio + 0.1;
//	}
	aspect default {
	//		draw square(1) color: rgb(0, int(bio * 25), 0) border: #grey;
		draw square(1) color: rgb(190, 255, 205);
	}

}

experiment main_experiment type: gui {
	output {
		display map {
			species grass aspect: default;
			species cows aspect: default;
			species sheep aspect: default;
			species goats aspect: default;
			species cows aspect: cow_action_neighbourhood transparency: 0.2;
			species sheep aspect: sheep_action_neighbourhood transparency: 0.0;
			species goats aspect: goat_action_neighbourhood transparency: 0.4;
		}

	}

}

