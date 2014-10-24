cam_width = 121;
cam_depth = 32;

cam_slope = 2;

cam_back_radius = 10;
cam_front_radius = 3;

base_plate_thickness = 5;

module BasePlate()
{
	/*base_points = [
		[-cam_width/2,-cam_depth/2],
		[cam_width/2,-cam_depth/2],
		[cam_width/2-cam_slope,cam_depth/2],
		[-(cam_width/2-cam_slope),cam_depth/2]];*/

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

// make space for them film rewind lever
left_hole_diameter = 27.98;

center_hole_diameter = 26.04;
center_hole_depth = 1;

right_hole_diameter = 23.06;
right_little_hole_diameter = 7;

left_to_center_dist = 14.2;
center_to_right_dist = 21.6;

left_hole_x_placement = -(left_hole_diameter/2 + left_to_center_dist + center_hole_diameter + center_to_right_dist + right_hole_diameter/2)/2;
center_hole_x_placement = left_hole_x_placement + left_hole_diameter/2 + left_to_center_dist + center_hole_diameter/2;
right_hole_x_placement = -left_hole_x_placement;// assuming symetry!

difference() {
	BasePlate();

	translate([left_hole_x_placement, 0, 0])
	linear_extrude(height=base_plate_thickness)
	circle(r=left_hole_diameter/2);

	translate([center_hole_x_placement, 0, base_plate_thickness-center_hole_depth])
	linear_extrude(height=right_hole_depth)
	circle(r=center_hole_diameter/2);
	
	translate([right_hole_x_placement, 0, 0])
	linear_extrude(height=base_plate_thickness)
	hull(){
		circle(r=right_hole_diameter/2);
		translate([-20, -right_hole_diameter/2+right_little_hole_diameter/2, 0])
		circle(r=right_little_hole_diameter/2);
	}
}
