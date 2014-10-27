cam_width = 120.5;
cam_depth = 31.6;

cam_slope = 2;

cam_back_radius = 15;
cam_front_radius = 4;

base_plate_thickness = 8;
handle_height = 45;

hole_tolerance = 1;

module BasePlate() {

	// adapted from http://www.thingiverse.com/thing:9347 {
	linear_extrude(height=base_plate_thickness)
	hull()
	{
		translate([-(cam_width/2-cam_back_radius), -(cam_depth/2-cam_back_radius), 0])
		circle(r=cam_back_radius);
		
		translate([(cam_width/2-cam_back_radius), -(cam_depth/2-cam_back_radius), 0])
		circle(r=cam_back_radius);
		
		translate([(cam_width/2-cam_front_radius-cam_slope), (cam_depth/2-cam_front_radius), 0])
		circle(r=cam_front_radius);
		
		translate([-(cam_width/2-cam_front_radius-cam_slope), (cam_depth/2-cam_front_radius), 0])
		circle(r=cam_front_radius);
	}
	// }

}

module Handle() {
	handle_depth = 15;
	handle_width = 15;

	handle_radius = 6;
	handle_inner_radius = 2;

	handle_outer_corner_x_placement = (cam_width/2-handle_radius-(cam_depth+handle_depth-cam_back_radius-handle_radius)*cam_slope/(cam_depth-cam_back_radius-cam_front_radius));

	union() {

		// handle base
		linear_extrude(height=base_plate_thickness)
		hull() {
			translate([(cam_width/2-cam_front_radius-cam_slope), (cam_depth/2-cam_front_radius), 0])
			circle(r=cam_front_radius);
			
			translate([handle_outer_corner_x_placement, 
				(cam_depth/2+handle_depth-handle_radius), 
				0])
			circle(r=handle_radius);
	
			translate([handle_outer_corner_x_placement+handle_radius-handle_width+handle_inner_radius, 
				(cam_depth/2+handle_depth-handle_inner_radius), 
				0])
			circle(r=handle_inner_radius);
	
			translate([handle_outer_corner_x_placement+handle_radius-handle_width+handle_inner_radius, (cam_depth/2-cam_front_radius), 0])
			circle(r=cam_front_radius);
		}

		// handle upper
		difference() {
		minkowski() {
			difference() {
				translate([0, 0, base_plate_thickness])
				linear_extrude(height=handle_height-handle_inner_radius)
				hull() {
					translate([(cam_width/2-cam_front_radius-cam_slope), (cam_depth/2-cam_front_radius), 0])
					circle(r=cam_front_radius-handle_inner_radius);//TODO what happens when r<=0?
					
					translate([handle_outer_corner_x_placement, 
						(cam_depth/2+handle_depth-handle_radius), 
						0])
					circle(r=handle_radius-handle_inner_radius);//TODO what happens when r<=0?
			
					translate([handle_outer_corner_x_placement+handle_radius-handle_width+handle_inner_radius, 
						(cam_depth/2+handle_depth-handle_inner_radius)-1, 
						0])
					square(size = [1, 1], center = false);
			
					translate([handle_outer_corner_x_placement+handle_radius-handle_width+handle_inner_radius, (cam_depth/2-cam_front_radius), 0])
					circle(r=cam_front_radius-handle_inner_radius);//TODO what happens when r<=0?
				}
	
				// Cut away excess material from the handle (plus a bit more which minkowski will fill)
				translate([0, 0, base_plate_thickness])
				linear_extrude(height=handle_height)
				square(size = [cam_width, cam_depth+2*handle_inner_radius], center = true);
				
				// Cut the top in an angle
				difference() {	
					translate([0, cam_depth/2+handle_inner_radius, base_plate_thickness+handle_height])
					rotate([-10, 0, 0]){
						linear_extrude(height=handle_height) // doesn't really matter
						square(size = [cam_width, handle_depth*2], center = false); // doesn't really matter
					}
					
				}
				
			}

		
		sphere(r = handle_inner_radius);
		}

		difference() {	
			translate([0, cam_depth/2+handle_inner_radius-10, base_plate_thickness+handle_height-handle_inner_radius-handle_radius])
			rotate([-10, 0, 0]){
				linear_extrude(height=handle_height) // doesn't really matter
				square(size = [cam_width, handle_depth*2], center = false); // doesn't really matter
			}
			
			translate([cam_width/2-cam_slope-handle_width/2-cam_slope, // more or less...
				cam_depth/2+3, 
				0]) 
			rotate([0, 90, 0]) {
				rotate_extrude(convexity = 10, $fn = 100) {
				translate([handle_height+base_plate_thickness-handle_inner_radius-1.2*handle_width/2, 0, 0])
				circle(r = 1.2*handle_width/2);
				}
	
			};

		}

		}

	}

}

// function to make simple holes, supports negative depth!
module Hole(diameter, depth, placement=[0, 0, 0]) {
	placement_offset=depth < 0? [0, 0, depth] : [0, 0, 0];
	translate(placement+placement_offset)
	linear_extrude(height=abs(depth))
	circle(r=diameter/2);
}

module BasePlateHoles(tolerance = 0) {
	left_hole_diameter = 27.98;
	
	center_hole_diameter = 26.04;
	center_hole_depth = 2.5;
	tripod_hole_diameter = 6.2;
	tripod_screw_head_diameter = 12; // TODO measure
	tripod_screw_head_height = 3; // TODO measure
	
	right_hole_diameter = 23.06;
	right_little_hole_diameter = 9.95;
	
	left_to_center_dist = 14.2;
	center_to_right_dist = 21.6;
	right_to_right_little_dist = 33.5;
	
	left_hole_x_placement = -(left_hole_diameter/2 + left_to_center_dist + center_hole_diameter + center_to_right_dist + right_hole_diameter/2)/2;
	center_hole_x_placement = left_hole_x_placement + left_hole_diameter/2 + left_to_center_dist + center_hole_diameter/2;
	right_hole_x_placement = -left_hole_x_placement;// assuming symmetry!
	
	Hole(left_hole_diameter+tolerance, 
		base_plate_thickness,
		[left_hole_x_placement, 0, 0]);

	Hole(center_hole_diameter+tolerance,
		-center_hole_depth,
		[center_hole_x_placement, 0, base_plate_thickness]);

	Hole(tripod_hole_diameter+tolerance,
		base_plate_thickness,
		[center_hole_x_placement, 0, 0]);

	Hole(tripod_screw_head_diameter,
		tripod_screw_head_height,
		[center_hole_x_placement, 0, 0]);

	translate([right_hole_x_placement, 0, 0])
	hull() {
		Hole(right_hole_diameter+tolerance,
			base_plate_thickness);
		Hole(right_little_hole_diameter+tolerance,
			base_plate_thickness,
			[-sqrt(right_to_right_little_dist*right_to_right_little_dist - right_to_right_little_dist*(right_hole_diameter+right_little_hole_diameter) + right_hole_diameter*right_little_hole_diameter), 
			-right_hole_diameter/2+right_little_hole_diameter/2, 
			0]);
	}
}

module BasePlateWithHolesAndHandle() {

		// Cut Holes for levers on the bottom of the camera
		difference() {
			// Join BasePlate and Handle
			union() {
				BasePlate();
				Handle();
			}
			BasePlateHoles(hole_tolerance);
		}
}

BasePlateWithHolesAndHandle();

//translate([cam_width/2-cam_slope-15/2, cam_depth/2+3, 0]) 
//rotate([0, 90, 0]) {
//	rotate_extrude(convexity = 10) {
//	translate([handle_height+base_plate_thickness-6*2, 0, 0])
//	circle(r = 15);//handle_radius);
//} 
//}