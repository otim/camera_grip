
module CameraGrip()
{
	cam_width = 121;
	cam_depth = 32;

	cam_slope = 5;

	base_plate_thickness = 5;

	base_points = [
		[-cam_width/2,-cam_depth/2],
		[cam_width/2,-cam_depth/2],
		[cam_width/2-cam_slope,cam_depth/2],
		[-(cam_width/2-cam_slope),cam_depth/2]];
	
	linear_extrude(height = base_plate_thickness, center = false, convexity = 10, twist = 0)

	polygon(base_points);
	


}

CameraGrip();
