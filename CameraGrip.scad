cam_width = 120.5;
cam_depth = 31.6;

cam_slope = 2;

cam_back_radius = 15;
cam_front_radius = 4;

base_plate_thickness = 5;
handle_height = 45;

module BasePlate()
{

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

module HandleBase()
{
	handle_depth = 15;
	handle_width = 15;

	handle_radius = 6;
	handle_inner_radius = 3;

	handle_outer_corner_x_placement = (cam_width/2-handle_radius-(cam_depth+handle_depth-cam_back_radius-handle_radius)*cam_slope/(cam_depth-cam_back_radius-cam_front_radius));

	linear_extrude(height=handle_height+base_plate_thickness)
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
}

module BasePlateWithHoles()
{
	// make space for the film rewind lever
	tolerance = 1;
	
	left_hole_diameter = 27.98;
	
	center_hole_diameter = 26.04;
	center_hole_depth = 2.5;
	
	right_hole_diameter = 23.06;
	right_little_hole_diameter = 9.95;
	
	left_to_center_dist = 14.2;
	center_to_right_dist = 21.6;
	right_to_right_little_dist = 33.5;
	
	left_hole_x_placement = -(left_hole_diameter/2 + left_to_center_dist + center_hole_diameter + center_to_right_dist + right_hole_diameter/2)/2;
	center_hole_x_placement = left_hole_x_placement + left_hole_diameter/2 + left_to_center_dist + center_hole_diameter/2;
	right_hole_x_placement = -left_hole_x_placement;// assuming symmetry!
	
	difference() {
		union() {
			HandleBase();
			BasePlate();
		}
	
		translate([left_hole_x_placement, 0, 0])
		linear_extrude(height=base_plate_thickness)
		circle(r=(left_hole_diameter+tolerance)/2);
	
		translate([center_hole_x_placement, 0, base_plate_thickness-center_hole_depth])
		linear_extrude(height=center_hole_depth)
		circle(r=(center_hole_diameter+tolerance)/2);
		
		translate([right_hole_x_placement, 0, 0])
		linear_extrude(height=base_plate_thickness)
		hull() {
			circle(r=(right_hole_diameter+tolerance)/2);
			translate([-sqrt(right_to_right_little_dist*right_to_right_little_dist - right_to_right_little_dist*(right_hole_diameter+right_little_hole_diameter) + right_hole_diameter*right_little_hole_diameter), 
				-right_hole_diameter/2+right_little_hole_diameter/2, 
				0])
			circle(r=(right_little_hole_diameter+tolerance)/2);
		}
	}
}

difference() {
	BasePlateWithHoles();
	translate([0, 0, base_plate_thickness])
	linear_extrude(height=handle_height)
	square(size = [cam_width, cam_depth], center = true);
}
