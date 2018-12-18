/**
 *  traffic
 *  Author: Nicolas
 *  Description: 
 */ model traffic


global{
	 //IMPORTATION DES FICHIERS SHAPEFILE 
 	file shape_file_arret <- file("../includes/Arret.shp");
	file shape_file_roads <- file("../includes/road.shp");
	file shape_file_station <- file("../includes/Station.shp");
	file shape_file_feux1 <- file("../includes/noeudF1.shp");
	file shape_file_feux2 <- file("../includes/noeudF2.shp");
	graph graphe_route; 
	
	file shape_file_ligne1 <- file("../includes/ligne5.shp");
	file shape_file_ligne1d <-file("../includes/debut_l1.shp");
	file shape_file_ligne1f <- file("../includes/fin_5.shp");
	graph graphe_ligne1; 
	
	file shape_file_ligne2 <- file("../includes/ligne2.shp");
	file shape_file_ligne2d <- file("../includes/debut_l2.shp");
	file shape_file_ligne2f <- file("../includes/fin_2.shp");
	graph graphe_ligne2; 
	
	file shape_file_ligne3 <- file("../includes/ligne2.shp");
	file shape_file_ligne3d <- file("../includes/debut_l2.shp");
	file shape_file_ligne3f <- file("../includes/fin_2.shp");
	graph graphe_ligne3; 
	
	file shape_file_ligne4 <- file("../includes/ligne4.shp");
	file shape_file_ligne4d <- file("../includes/debut_l4.shp");
	file shape_file_ligne4f <- file("../includes/fin_4.shp");
	graph graphe_ligne4; 
	
	file arret_bus <- file("../includes/Arret.shp");
	float temps_arret_bus<-10; 
	
	
	//VITESSE
	float vitesse_actuelle<-50°km/°h parameter: 'Vitesse actuelle de la bus'category:'bus1';
	float vitesse_maximale<-70°km/°h parameter: 'Vitesse maximale de la bus'category:'bus1';
	float vitesse_minimale<-20°km/°h parameter: 'Vitesse minimale de la bus'category:'bus1';
	
	float attente<-15 parameter: 'Temps d\'attente des bus aux arrets' category:'bus1';
	
	float distance_securite<-2 parameter: 'Distance de sécurite'category:'bus';
	
	int nombre_bus<-1 parameter:'Nombre de bus' category:'bus1' min:1 max:30;
	
	//COMPMTAGE DU NOMBRE DE BUS EN STOP
	int nombre_bus1<-0;  
	int nombre_bus2<-0;  
	int nombre_bus3<-0;  
	int nombre_bus4<-0;   
	 	        
	//DUREE DES FEUX TRICOLORES
 	int duree_rouge <-20 parameter: 'Durée du feu rouge' category: 'feux1';
	int duree_vert  <-10  parameter: 'Durée du feu vert' category: 'feux1';
	int duree_jaune <-5 parameter: 'Durée du feu jaune' category: 'feux1';
 	bool feu1_rouge <-true;
 	bool feu2_rouge <-false;
 	bool arret<-false;
 	
 	init{
		create routes from: shape_file_roads with:[nbLanes::int(read("lanes"))] {	}
		create feux1 from: shape_file_feux1;
		create feux2 from: shape_file_feux2;
		create bus_stop from : arret_bus;
		set graphe_route<-(as_edge_graph(routes));
		
		//LIGNE 1
		create ligne1 from  :  shape_file_ligne1 with:[nbLanes::int(read("lanes"))] {	}
		set graphe_ligne1 <- (as_edge_graph(ligne1));
		create ligne1D from : shape_file_ligne1d;
		create ligne1F from : shape_file_ligne1f;
		create station from : shape_file_station;
		
		//LIGNE 2
		create ligne2 from  :  shape_file_ligne2 with:[nbLanes::int(read("lanes"))] {	}
		set graphe_ligne2 <- (as_edge_graph(ligne2));
		create ligne2D from : shape_file_ligne2d;
		create ligne2F from : shape_file_ligne2f;
		
		//LIGNE 3
		create ligne3 from  :  shape_file_ligne3 with:[nbLanes::int(read("lanes"))] {	}
		graphe_ligne3 <- (as_edge_graph(ligne3));
		create ligne3D from : shape_file_ligne3d;
		create ligne3F from : shape_file_ligne3f;
		
		//LIGNE 4
		create ligne4 from  :  shape_file_ligne4 with:[nbLanes::int(read("lanes"))] {	}
		 graphe_ligne4 <- (as_edge_graph(ligne4));
		create ligne4D from : shape_file_ligne4d;
		create ligne4F from : shape_file_ligne4f;
	}
	
	reflex creation_bus when: every(10){
		create bus2 number: nombre_bus  { 
			speed <- vitesse_actuelle ;
			living_space <-2;
			target <-one_of(ligne2F);
			location <- one_of(ligne2D);
			lanes_attribute <- "nbLanes";
			obstacle_species <- [species(self),bus1,bus3,bus4]; 
			image<-("../images/bus.jpg");	  	
		} 
		create voiture number: 1  { 
			speed <- vitesse_actuelle ;
			living_space <-2;
			target <-one_of(ligne2F);
			location <- one_of(ligne2D);
			lanes_attribute <- "nbLanes";
			obstacle_species <- [species(self),bus1,bus3,bus4]; 
			image<-("../images/voiture.jpg");
		}
		create bus1 number: nombre_bus  { 
			speed <- vitesse_actuelle ;
			living_space <-2;
			target <-one_of(ligne1F);
			location <- one_of(ligne1D);
			lanes_attribute <- "nbLanes";
			obstacle_species <- [species(self),bus2,bus3,bus4]; 
			image<-("../images/bus.jpg");		
		}
		create bus3 number: nombre_bus  { 
			speed <- vitesse_actuelle ;
			target <-one_of(ligne3F);
			location <- one_of(ligne3D);
			lanes_attribute <- "nbLanes";
			obstacle_species <- [species(self),bus1,bus2,bus4]; 
			image<-("../images/bus.jpg"); 	
			living_space <-2;
		} 
		create bus4 number: nombre_bus  { 
			speed <- vitesse_actuelle ;
			target <-one_of(ligne4F);
			location <- one_of(ligne4D);
			lanes_attribute <- "nbLanes";
			obstacle_species <- [species(self),bus1,bus2,bus3]; 
			image<-("../images/bus.jpg");
			living_space <-2;
		}
		create voiture number: 1  { 
			speed <- vitesse_actuelle ;
			living_space <-2;
			target <-any_location_in(one_of(routes));
			location <- any_location_in(one_of(routes));
			lanes_attribute <- "nbLanes";
			obstacle_species <- [species(self),bus2,bus3,bus4,bus1,voiture]; 
			image<-("../images/voiture.jpg");	 	
		}
 		//CREATION DES AGENTS BUS LIGNE1
		create voiture number: 1  { 
			speed <- vitesse_actuelle ;
			living_space <-2;
			target <-one_of(ligne1F);
			location <- one_of(ligne1D);
			lanes_attribute <- "nbLanes";
			obstacle_species <- [species(self),bus2,bus3,bus4]; 
			image<-("../images/voiture.jpg");	
		} 
		create voiture number: 1  { 
			speed <- vitesse_actuelle ;
			living_space <-2;
			target <-any_location_in(one_of(routes));
			location <- any_location_in(one_of(routes));
			lanes_attribute <- "nbLanes";
			obstacle_species <- [species(self),bus2,bus3,bus4,bus1,voiture]; 
			image<-("../images/voiture.jpg");
		}  	
	}
}	

//CREATION DES ENTITES
entities{ 
	//SPECIES ROUTES
	species routes skills: [skill_road]{
		float distance_entre_voiture;
		int nbLanes;
		aspect basic{
			draw shape color: rgb("black");
		}
	} 
		
	//SPECIES ROUTES
 	species station{
 		float distance_entre_voiture;
		int nbLanes;		
		aspect basic{
			draw circle(5) color: rgb("blue");
		}
	} 
		
	//SPECIES VOITURES
	species voiture skills: [driving]  { 
	    point target <- nil ; 
	    file image;
	    float distance_entre_agent<-5.0;		
		reflex Deplacement{
			ask list(voiture){
				do goto_driving target:target on:graphe_route;
				switch location {
					match target {
						do action:die;
					}									
				}
			}	
		}
		reflex deplacement {
			feux1 feux_min<-feux1 with_min_of(each distance_to self);
			float distance_feux1<- feux_min distance_to self;
			bool feu1_est_rouge<-false;
			feux2 feux_min2<-feux2 with_min_of(each distance_to self);
			float distance_feux2<- feux_min2 distance_to self;
			
			ask feux_min{
				if(((distance_feux1/80)<=0.1) and feu1_rouge){
				 	myself.speed<-0.0;
				 }
				 else{
				 	myself.speed<-rnd(50);
				 }	
			}
			ask feux_min2{
				if(((distance_feux2/80)<=0.3) and feu2_rouge ){
					feu1_est_rouge<-true;
				 	myself.speed<-0.0;
				 }
				 else{
				 	myself.speed<-25;
				 	feu1_est_rouge<-false;
				 }		 	
			}
		}
		reflex update {
			list<agent> neighbours <- agents at_distance(distance_entre_agent);
		}
		aspect basic {
			draw image  size:(50) rotate:heading;
		}
	}
	//SPECIES LIGNE 1
	species ligne1{
		int nbLanes;
		aspect basic{
			draw shape color: #blue;
		}
	} 
	//SPECIES LIGNE 1 DEBUT
	species ligne1D{
		int nbLanes;
		aspect basic{
			draw shape color: rgb("blue");
		}
	} 
	//SPECIES LIGNE 1 FIN
	species ligne1F{
		int nbLanes;
		aspect basic{
			draw shape color: rgb("blue");
		}
	} 
	//SPECIES BUS1
	species bus1 skills: [driving]  { 
		point target <- nil ; 
		file image;
		int compteur<-0;
		reflex Deplacement{
			ask list(bus1){
				do goto_driving target:target on:graphe_ligne1;
				switch location {
					match target {
						nombre_bus1<-nombre_bus1+1;
						target <-one_of(ligne1D);
					}									
				}
			}
		}
		reflex deplacement {
			feux1 feux_min<-feux1 with_min_of(each distance_to self);
			float distance_feux1<- feux_min distance_to self;
			bool feu1_est_rouge<-false;
			feux2 feux_min2<-feux2 with_min_of(each distance_to self);
			float distance_feux2<- feux_min2 distance_to self;
			
			ask feux_min{
				if(((distance_feux1/80)<=0.1) and feu1_rouge){
				 	myself.speed<-0.0;
				 }
				 else{
				 	myself.speed<-rnd(50);
				 }	
			}
			ask feux_min2{
				if(((distance_feux2/80)<=0.3) and feu2_rouge ){
					feu1_est_rouge<-true;
				 	myself.speed<-0.0;
				 }
				 else{
				 	myself.speed<-25;
				 	feu1_est_rouge<-false;
				 }		 	
			}
		}
		reflex arret{	
			bus_stop arret_p<-bus_stop with_min_of(each distance_to self);
			float distance_arret_bus<- arret_p distance_to self;
		
			ask arret_p{	
				if((distance_arret_bus/25<=1) and arret=false){
					myself.speed<-0.0;
				}
				if(myself.speed=0){
					myself.compteur<-myself.compteur+1;
					if(myself.compteur=attente){
						myself.speed<-50;
						myself.compteur<-0;
						arret<-false;
					}
				}
			}
		}
		aspect basic {
			draw image  size:50 rotate:heading;
		}
	}

		
///////////////////////////////////DEUXIEME LIGNE DE BUS/////////////////////////////////////
		//SPECIES LIGNE 2
		species ligne2{
			int nbLanes;
			aspect basic{
				draw shape color: rgb("green");
			}
		} 
		
		//SPECIES LIGNE 2 DEBUT
		species ligne2D{
			int nbLanes;
			aspect basic{
				draw shape color: rgb("green");
			}
		} 
		
		//SPECIES LIGNE 2 FIN
		species ligne2F{
			int nbLanes;
			aspect basic{
				draw shape color: rgb("red");
			}
		} 
		//SPECIES BUS2
		species bus2 skills: [driving]  { 
		    point target <- nil ; 
		    file image;
		    int compteur<-0;
		    bool arret<-false;
		    int taille<-50;
			reflex Deplacement{
			
			bus_stop stop<-nil;
			ask list(bus2){
				do goto_driving target:target on:graphe_ligne2;
				switch location {
					match target {
						nombre_bus2<-nombre_bus2+1;
						target <-one_of(ligne2D);
					}									
				}
			}	
		}
		
		reflex deplacement {
			feux1 feux_min<-feux1 with_min_of(each distance_to self);
			float distance_feux1<- feux_min distance_to self;
			bool feu1_est_rouge<-false;
			feux2 feux_min2<-feux2 with_min_of(each distance_to self);
			float distance_feux2<- feux_min2 distance_to self;
			bool deja_A<-false;
			ask feux_min{
				if(((distance_feux1/80)<=0.3) and feu1_rouge){
				 	myself.speed<-0.0;
				 }
				 else{
				 	myself.speed<-rnd(25);
				 }	
			}
			ask feux_min2{
				if(((distance_feux2/80)<=0.3) and feu2_rouge ){
					feu1_est_rouge<-true;
				 	myself.speed<-0.0;
				 }
				 else{
				 	myself.speed<-25;
				 	feu1_est_rouge<-false;
				}		 	
			}
		}
		reflex arret{	
			bus_stop arret_p<-bus_stop with_min_of(each distance_to self);
			float distance_arret_bus<- arret_p distance_to self;
	
			ask arret_p{	
				if((distance_arret_bus/25<=1) and arret=false){
					myself.speed<-0.0;
				}
				if(myself.speed=0){
					myself.compteur<-myself.compteur+1;
					if(myself.compteur=attente){
						myself.speed<-50;
						myself.compteur<-0;
						arret<-false;	
					}
				}
				
			}
		}
		aspect basic {
			draw image size:(taille) rotate:heading;
		}
	}
	
	///////////////////////////////////TROIXIEME LIGNE DE BUS/////////////////////////////////////
		//SPECIES LIGNE 3
		species ligne3{
			int nbLanes;
			aspect basic{
				draw shape color: rgb("blue");
			}
		} 
		
		//SPECIES LIGNE 3 DEBUT
		species ligne3D{
			int nbLanes;
			aspect basic{
				draw shape size:10  color:rgb("blue");
			}
		} 
		
		//SPECIES LIGNE 3 FIN
		species ligne3F{
			int nbLanes;
			aspect basic{
				draw shape size:10  color:rgb("blue");
			}
		} 
		//SPECIES BUS3
		species bus3 skills:[driving]  { 
		    point target <- nil ; 
		    file image;
		    int compteur<-0;
		    bool arret<-false;
		    int taille<-50;
			reflex Deplacement{
			
			bus_stop stop<-nil;
			ask list(bus3){
				do goto_driving target:target on:graphe_ligne3;
				switch location {
					match target {
						nombre_bus2<-nombre_bus2+1;
						target <-one_of(ligne3D);
					}									
				}
			}	
		}
		
		reflex deplacement {
			feux1 feux_min<-feux1 with_min_of(each distance_to self);
			float distance_feux1<- feux_min distance_to self;
			bool feu1_est_rouge<-false;
			feux2 feux_min2<-feux2 with_min_of(each distance_to self);
			float distance_feux2<- feux_min2 distance_to self;
			bool deja_A<-false;
			
			ask feux_min{
				if(((distance_feux1/80)<=0.3) and feu1_rouge){
				 	myself.speed<-0.0;
				 }
				 else{
				 	myself.speed<-rnd(25);
				 }
			}
			ask feux_min2{
				if(((distance_feux2/80)<=0.3) and feu2_rouge ){
					feu1_est_rouge<-true;
				 	myself.speed<-0.0;
				 }
				else{
				 	myself.speed<-25;
				 	feu1_est_rouge<-false;
				}		 	
			}	
		}
		reflex arret{	
		bus_stop arret_p<-bus_stop with_min_of(each distance_to self);
		float distance_arret_bus<- arret_p distance_to self;
		
			ask arret_p{
				if((distance_arret_bus/25<=1) and arret=false){
					myself.speed<-0.0;
				}
				if(myself.speed=0){
					myself.compteur<-myself.compteur+1;
					if(myself.compteur=attente){
						myself.speed<-50;
						myself.compteur<-0;
						arret<-false;
					}
				}
			}
		}
		aspect basic {
			draw image size:(taille) rotate:heading;
		}
	}
	
	///////////////////////////////////QUATRIEME LIGNE DE BUS/////////////////////////////////////
	//SPECIES LIGNE 4
	species ligne4{
		int nbLanes;
		aspect basic{
			draw shape color: rgb("brown");
		}
	} 
		
	//SPECIES LIGNE 4 DEBUT
	species ligne4D{
		int nbLanes;
		aspect basic{
			draw shape color: rgb("red");
		}
	} 
	//SPECIES LIGNE 4 FIN
	species ligne4F{
		int nbLanes;
		aspect basic{
			draw shape color: rgb("red");
		}
	} 
	//SPECIES BUS4
	species bus4 skills: [driving]  { 
		point target <- nil ; 
		file image;
		int compteur<-0;
		reflex Deplacement{
			ask list(bus4){
				do goto_driving target:target on:graphe_ligne4;
				switch location {
					match target {
						target <-one_of(ligne4D);
						nombre_bus4<-nombre_bus4+1;
					}									
				}
			}	
		}
		reflex deplacement {
			feux1 feux_min<-feux1 with_min_of(each distance_to self);
			float distance_feux1<- feux_min distance_to self;
			bool feu1_est_rouge<-false;
			feux2 feux_min2<-feux2 with_min_of(each distance_to self);
			float distance_feux2<- feux_min2 distance_to self;
			
			ask feux_min{
				if(((distance_feux1/80)<=0.1) and feu1_rouge){
				 	myself.speed<-0.0;
				}
				else{
				 	myself.speed<-rnd(50);
				}	
			}
			ask feux_min2{
				if(((distance_feux2/80)<=0.3) and feu2_rouge ){
					feu1_est_rouge<-true;
				 	myself.speed<-0.0;
				 }
				 else{
				 	myself.speed<-25;
				 	feu1_est_rouge<-false;
				}		 	
			}
		}
		reflex arret{	
			bus_stop arret_p<-bus_stop with_min_of(each distance_to self);
			float distance_arret_bus<- arret_p distance_to self;
			ask arret_p{
				if((distance_arret_bus/25<=1) and arret=false){
					myself.speed<-0.0;
				}
				if(myself.speed=0){
					myself.compteur<-myself.compteur+1;
					if(myself.compteur=attente){
						myself.speed<-50;
						myself.compteur<-0;
						arret<-false;	
					}
				}
			}
		}
		aspect basic {
			draw image  size:(50) rotate:heading;
		}
	}
		
/////////////////////////////    GESTION DES FEUX TRICOLORES //////////////////////////	
		
		//SPECIES FEUX1
 	species feux1 skills: [skill_road_node] {
		rgb color <- rgb('red');
		int temps_feu<-0;	
		int cycle_feux1 <- 0;		
		int feuRouge<-1;
		
		action feu_rouge{
			set color <- #red;
			set cycle_feux1<-0;
			set temps_feu<-0;
			set feu1_rouge<-true;	
		}
		action feu_vert{
			set color <- #green;
			set temps_feu<-0;
			set feu1_rouge<-false;
		}
		action feu_jaune{
			set color <- #yellow;
			set temps_feu<-0;
			set feu1_rouge<-true;
		}
		
		reflex dynamic{
			cycle_feux1 <- cycle_feux1+ 1;
			temps_feu<-temps_feu+1;
			
			if (((cycle_feux1 ) = duree_rouge) and (temps_feu=duree_rouge)){
				do action: feu_vert;
			}
			if ((cycle_feux1 = duree_vert+duree_rouge) and (temps_feu=duree_vert)){
				do action: feu_jaune;
			}
			if ((cycle_feux1 = (duree_rouge+duree_vert+duree_jaune)) and (temps_feu=duree_jaune)){
				do action: feu_rouge;	
			}
		}
		
		aspect basic {	
			draw circle(8) color: color;
		}		
	}
	
	//SPECIES FEUX2
	species feux2 control : fsm{
		rgb color <- rgb('green');
		int temps_feu2<-0;
		int cycle_feux2 <- 0; 
		
		state intact initial: true{
			transition to : changement_etat_feu when: cycle_feux2 = 0;
		}
		action feu_rouge{
			set color <- rgb('red');
			set temps_feu2<-0;
			set feu2_rouge<-true;
		}
		action feu_vert{
			set color <- #green;
			set temps_feu2<-0;
			cycle_feux2 <- 0;
			set feu2_rouge<-false;
		}
		action feu_jaune{
			set color <- rgb('yellow');
			set temps_feu2<-0;
			set feu2_rouge<-false;
		}
		state changement_etat_feu{
			cycle_feux2 <- cycle_feux2+ 1;
			temps_feu2<-temps_feu2+1;
			ask list(feux2){
				if (((cycle_feux2 ) = duree_rouge+duree_vert+duree_jaune) and (temps_feu2=(duree_rouge))){
					do action: feu_vert;
				}
				if ((cycle_feux2 = duree_vert) and (temps_feu2=duree_vert)){
					do action: feu_jaune;
				}
				if ((cycle_feux2 = duree_vert+duree_jaune) and (temps_feu2=duree_jaune)){
					do action: feu_rouge;
				}
			}
		}
		aspect basic{
			draw circle(8) color: color;
		}
	}
	
	///////////////////////////////// GESTION DES ARRETS DE BUS /////////////////*
	
	species bus_stop{
		rgb couleur<-#green;
		float taille<-5;
		
		aspect basic{
			draw square(taille) color:couleur;
		} 
	}
}

environment height: 3500 width: 3500 torus: true{}

experiment traffic type: gui{
	output{
		 display "circulation" type:opengl{
			species routes aspect: basic;
			species feux1 aspect: basic;
			species feux2 aspect: basic;
			species bus_stop aspect: basic;
			species station aspect: basic;
			
			//LIGNE 1 ET BUS 1
			species ligne1 aspect: basic;
			species ligne1D aspect: basic;
			species ligne1F aspect: basic;
			species bus1 aspect: basic;
			
			//LIGNE 2 ET BUS 2
			/*species ligne2 aspect: basic;
			species ligne2D aspect: basic;
			species ligne2F aspect: basic;
			species bus2 aspect: basic;*/
			
			//LIGNE 3 ET BUS 3
			species ligne3 aspect: basic;
			species ligne3D aspect: basic;
			species ligne3F aspect: basic;
			species bus3 aspect: basic;
			
			//LIGNE 4 ET BUS 4
			species ligne4 aspect: basic;
			species ligne4D aspect: basic;
			species ligne4F aspect: basic;
			species bus4 aspect: basic;
			
			//species station aspect: basic;
			species voiture aspect: basic;				
		}
		display Graphiques{
	     	chart "nombre_agent"{
	            data "Nombre de bus en circulation sur la ligne 1"
				value: length(bus1) 
				color:rgb('red');
				
				data "Nombre de bus en circulation sur la ligne 2"
				value: length(bus2) 
				color:rgb('blue');
				
				data "Nombre de bus en circulation sur la ligne 3"
				value:length(bus3) 
				color:rgb('green');
				
				data "Nombre de bus en circulation sur la ligne 4"
				value:length(bus4) 
				color:rgb('black');
 			}
 		}
 		display stat_ligne {
			chart "statistiques ligne 1" type: pie size:{0.5,0.5} position:{0.0,0.5}{
				data "Ligne 1 en activité" value: length(bus1) color: (rgb(rnd(150), rnd(200), rnd(255)));
				data "Ligne 1 en stop" value: (length(list(bus1))-nombre_bus1)  color: (rgb(rnd(200), rnd(255), rnd(170)));	
 			}
 			chart "statistiques ligne 2" type: pie size:{0.5,0.5} position:{0.5,3.5}{
				data "Ligne 2 en activité" value: length(bus2)  color: (rgb(rnd(150), rnd(200), rnd(255)));
				data "Ligne 2 en stop" value: (length(list(bus2))-nombre_bus2)  color: (rgb(rnd(200), rnd(255), rnd(170)));	
			}
 			chart "statistiques ligne 3" type: pie size:{0.5,0.5} position:{0.0,3.5}{
				data "Ligne 3 en activité" value: length(bus4)  color: (rgb(rnd(150), rnd(200), rnd(255)));
				data "Ligne 3 en stop" value: (length(list(bus4))-nombre_bus4)  color: (rgb(rnd(200), rnd(255), rnd(170)));	
 			}
 			
 		}
 		display Statistiques {
 			chart "statistiques lignes" type: pie {
				data "Ligne 3 en activité" value: (length(bus4)+length(bus1)+length(bus2))  color: (rgb(rnd(255), rnd(90), rnd(50)));
				data "Ligne 3 en stop" value: ((length(list(bus2))-nombre_bus2)+(length(list(bus4))-nombre_bus4)+(length(list(bus1))-nombre_bus1)) color: (rgb(rnd(200), rnd(255), rnd(170)));	
 			}
 		}
 	}
 }

