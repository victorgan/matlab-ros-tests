% subscribe and display
timeOut = 3; % seconds

% subscribe to point cloud, get rotation
pointcloudTopic = '/camera/depth/points';
pointcloudSub = rossubscriber(pointcloudTopic);
pointcloudMsg = receive(pointcloudSub,timeOut);
xyz = readXYZ(pointcloudMsg);
voxelGridSize = 0.05; % in metres
ransacParams.floorPlaneTolerance = 0.02; % tolerance in m
ransacParams.maxInclinationAngle = 30; % in degrees
[pointCloudRotated, newOrigin, R, T] = processPointCloud(xyz, voxelGridSize, ransacParams);

% subscribe to odom, get inital odometry.
odomTopic = '/kinect_odometer/odometry';
odomSub = rossubscriber(odomTopic);
odomMsg = receive(odomSub,timeOut);

posHistory = [];
tic;
while toc < 10
    odomMsg = receive(odomSub,timeOut);
    showdetails(odomMsg);

    position = odomMsg.Pose.Pose.Position;
    pos = [position.X; position.Y; position.Z];
    posRotated = R*pos;

    orientation = odomMsg.Pose.Pose.Orientation;
    orientQuat = [orientation.W orientation.X orientation.Y orientation.Z];
    orientRotm = quat2rotm(orientQuat);

    posHistory = [posHistory posRotated];
    figure(1)
    scatter3( posHistory(1,:), posHistory(2,:), posHistory(3,:) );
    title('Position History');
    xlabel('X');
    ylabel('Y');
    zlabel('Z');

end
