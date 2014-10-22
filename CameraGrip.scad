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
film_lever_hole_diameter = 30;
film_lever_x_placement = -44;
film_display_hole_diameter = 25;
film_display_x_placement = 44;
tripod_outer_diameter = 25;
tripod_outer_depth = 1;
tripod_outer_x_placement = -3;
difference() {
	BasePlate();

	translate([film_lever_x_placement, 0, 0])
	linear_extrude(height=base_plate_thickness)
	circle(r=film_lever_hole_diameter/2);

	translate([film_display_x_placement, 0, 0])
	linear_extrude(height=base_plate_thickness)
	circle(r=film_display_hole_diameter/2);

	translate([tripod_outer_x_placement, 0, base_plate_thickness-tripod_outer_depth])
	linear_extrude(height=tripod_outer_depth)
	circle(r=tripod_outer_diameter/2);
}
