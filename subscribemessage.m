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
orientHistory = [];
tic;
while toc < 40
    odomMsg = receive(odomSub,timeOut);

    position = odomMsg.Pose.Pose.Position;
    pos = [position.X; position.Y; position.Z];
    posRotated = R*pos;
    posHistory = [posHistory pos];

    orientation = odomMsg.Pose.Pose.Orientation;
    orientQuat = [orientation.W orientation.X orientation.Y orientation.Z];
    orientRotm = quat2rotm(orientQuat);
    orientHistory = [orientHistory orientQuat'];

    figure(1)
    subplot(1,2,1)
    scatter3( posHistory(1,:), posHistory(2,:), posHistory(3,:) );
    title('Position History');
    xlabel('X');
    ylabel('Y');
    zlabel('Z');

    subplot(1,2,2)
    scatter3( orientHistory(1,:), orientHistory(2,:), orientHistory(3,:) );
    title('Orientation Quaternion History');
    xlabel('X');
    ylabel('Y');
    zlabel('Z');

end
