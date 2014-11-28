$fn=50;

cam_width = 120.5;
cam_depth = 31.6;

cam_slope = 2;

cam_back_radius = 15;
cam_front_radius = 4;

base_plate_thickness = 8.8;

handle_height = 47;
handle_depth = 15;
handle_width = 17;

handle_outer_radius = 6;
handle_radius = 2;

hole_tolerance = 1; // will be added to the measured diameters

// Create a hull of two to four circles
// Usage: RoundedCornerPolygon([x1, y1, r1], ..., [x4, y4, r4])
module RoundedCornerPolygon(A=[0, 0, 0], B=[0, 0, 0], C=[0, 0, -1], D=[0, 0, -1]) {

	// adapted from http://www.thingiverse.com/thing:9347 {
	hull() {

		translate([A[0], A[1], 0])
		circle(r=A[2]);

		translate([B[0], B[1], 0])
		circle(r=B[2]);

		if (C[2]!=-1) {

			translate([C[0], C[1], 0])
			circle(r=C[2]);

			if (C[2]!=-1) {

				translate([D[0], D[1], 0])
				circle(r=D[2]);

			}

		}

	}

}


module BasePlate() {

	linear_extrude(height=base_plate_thickness)
	RoundedCornerPolygon([-(cam_width/2-cam_back_radius), -(cam_depth/2-cam_back_radius), cam_back_radius], 
		[(cam_width/2-cam_back_radius), -(cam_depth/2-cam_back_radius), cam_back_radius], 
		[(cam_width/2-cam_front_radius-cam_slope), (cam_depth/2-cam_front_radius), cam_front_radius], 
		[-(cam_width/2-cam_front_radius-cam_slope), (cam_depth/2-cam_front_radius), cam_front_radius]);

}


module Handle() {

	handle_outer_right_corner_x = (cam_width/2-handle_outer_radius-(cam_depth+handle_depth-cam_back_radius-handle_outer_radius)*cam_slope/(cam_depth-cam_back_radius-cam_front_radius));
	handle_outer_right_corner_y = cam_depth/2+handle_depth-handle_outer_radius;

	handle_outer_left_corner_x = handle_outer_right_corner_x+handle_outer_radius-handle_width+handle_radius;
	handle_outer_left_corner_y = cam_depth/2+handle_depth-handle_radius;

	handle_inner_right_corner_x = -cam_slope / (cam_depth/2-cam_front_radius) * (cam_depth/2+handle_radius) + cam_width/2-cam_front_radius+handle_radius;//TODO bug
	handle_inner_right_corner_y = cam_depth/2+handle_radius;

	handle_inner_left_corner_x = handle_outer_left_corner_x;
	handle_inner_left_corner_y = handle_inner_right_corner_y;

	// handle base
	difference() {

		union(){

			linear_extrude(height=base_plate_thickness)
			RoundedCornerPolygon([(cam_width/2-cam_front_radius-cam_slope), (cam_depth/2-cam_front_radius), cam_front_radius],
				[handle_outer_right_corner_x, (cam_depth/2+handle_depth-handle_outer_radius), handle_outer_radius],
				[handle_outer_left_corner_x, (cam_depth/2+handle_depth-handle_radius), handle_radius],
				[handle_inner_left_corner_x, (cam_depth/2-cam_front_radius), handle_radius]);

			linear_extrude(height=base_plate_thickness+handle_height-handle_radius)
			RoundedCornerPolygon([handle_inner_right_corner_x, handle_inner_right_corner_y, handle_radius],
				[handle_outer_right_corner_x, handle_outer_right_corner_y, handle_outer_radius],
				[handle_outer_left_corner_x, handle_outer_left_corner_y, handle_radius],
				[handle_inner_left_corner_x, handle_inner_left_corner_y, handle_radius]);

			linear_extrude(height=base_plate_thickness)
			RoundedCornerPolygon([(cam_width/2-cam_front_radius-cam_slope), (cam_depth/2-cam_front_radius), cam_front_radius],
				[handle_outer_right_corner_x, (cam_depth/2+handle_depth-handle_outer_radius), handle_outer_radius],
				[handle_outer_left_corner_x, (cam_depth/2+handle_depth-handle_radius), handle_radius],
				[handle_inner_left_corner_x, (cam_depth/2-cam_front_radius), handle_radius]);

			linear_extrude(height=base_plate_thickness+handle_height-handle_radius)
			RoundedCornerPolygon([handle_inner_right_corner_x, handle_inner_right_corner_y, handle_radius],
				[handle_outer_right_corner_x, handle_outer_right_corner_y, handle_outer_radius],
				[handle_outer_left_corner_x, handle_outer_left_corner_y, handle_radius],
				[handle_inner_left_corner_x, handle_inner_left_corner_y, handle_radius]);
		
			translate([0, 0, base_plate_thickness+handle_height-handle_radius-.1])
			minkowski() {

				linear_extrude(height=.1)//minkowski apparently only works on 3D objects...
				hull() {

					polygon(points=[[handle_inner_left_corner_x, handle_inner_left_corner_y],[handle_inner_right_corner_x, handle_inner_right_corner_y],[handle_outer_left_corner_x, handle_outer_left_corner_y]], paths=[[0,1,2]]);
					
					translate([handle_outer_right_corner_x,
						handle_outer_right_corner_y, 
						0])
					circle(r=handle_outer_radius-handle_radius);

				}
		
				sphere(r=handle_radius);

			}

		}
		
		// Cut away excess material from the handle
		translate([0, 0, base_plate_thickness])
		linear_extrude(height=2*handle_height)
		square(size = [cam_width, cam_depth], center = true);

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
	tripod_screw_head_diameter = 13.50;
	tripod_screw_head_height = 3.7;
	
	right_hole_diameter = 23.06;
	right_little_hole_diameter = 9.95;
	
	left_to_center_dist = 14.2;
	center_to_right_dist = 21.6;
	right_to_right_little_dist = 33.5;
	
	left_hole_x = -(left_hole_diameter/2 + left_to_center_dist + center_hole_diameter + center_to_right_dist + right_hole_diameter/2)/2;
	center_hole_x = left_hole_x + left_hole_diameter/2 + left_to_center_dist + center_hole_diameter/2;
	right_hole_x = -left_hole_x;// assuming symmetry!
	
	Hole(left_hole_diameter+tolerance, 
		base_plate_thickness,
		[left_hole_x, 0, 0]);

	Hole(center_hole_diameter+tolerance,
		-center_hole_depth,
		[center_hole_x, 0, base_plate_thickness]);

	Hole(tripod_hole_diameter+tolerance,
		base_plate_thickness,
		[center_hole_x, 0, 0]);

	Hole(tripod_screw_head_diameter+tolerance,
		tripod_screw_head_height,
		[center_hole_x, 0, 0]);

	translate([right_hole_x, 0, 0])
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