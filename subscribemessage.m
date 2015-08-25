close all;
% subscribe and display
timeOut = 3; % seconds

% subscribe to point cloud, get rotation
% points are respect to camera_depth_optical_frame
pointcloudTopic = '/camera/depth/points';
pointcloudSub = rossubscriber(pointcloudTopic);
pointCloudMsgOptic = receive(pointcloudSub,timeOut);

tftree = rostf;
waitForTransform(tftree, 'odom', 'camera_depth_optical_frame');
pointcloudMsgOdom = transform(tftree, 'odom', pointCloudMsgOptic);

% Get OtoO : transform from odom to camera_depth_optical_frame
tf_OdomToOptic = getTransform(tftree,'camera_depth_optical_frame', 'odom');
trans = tf_OdomToOptic.Transform.Translation;
T_OdomToOptic= [trans.X; trans.Y; trans.Z];
quat = tf_OdomToOptic.Transform.Rotation;
OtoOquat = [quat.W quat.X quat.Y quat.Z];
R_OdomToOptic = quat2rotm(OtoOquat);

xyzOptic = readXYZ(pointCloudMsgOptic);
voxelGridSize = 0.05; % in metres
ransacParams.floorPlaneTolerance = 0.02; % tolerance in m
ransacParams.maxInclinationAngle = 30; % in degrees
% points are respect to gan_ground_frame
[pointCloudRotated, newOrigin, R_OpticToGround, T_OpticToGround] = processPointCloud(xyzOptic, voxelGridSize, ransacParams);

xyzOdom = readXYZ(pointcloudMsgOdom);
R_OdomToGround = R_OpticToGround*R_OdomToOptic;
T_OdomToGround = T_OpticToGround+T_OdomToOptic;
pointCloudRotated2 = R_OdomToGround*xyzOdom' + repmat(T_OdomToGround,1,size(xyzOdom',2));
% pointCloudRotated2 == pointCloudRotated


figure(1)
% scatter3(pointcloudMsgOdom);
plotPointCloud(pointCloud(pointCloudRotated2'), titleString);
xlabel('X');
ylabel('Y');
zlabel('Z');
hold on

% subscribe to odom, get inital odometry.
% points are respect to odom
odomTopic = '/kinect_odometer/odometry';
odomSub = rossubscriber(odomTopic);
odomMsg = receive(odomSub,timeOut);

posHistory = [];
orientHistory = [];
tic;
while toc < 5
    odomMsg = receive(odomSub,timeOut);

    position = odomMsg.Pose.Pose.Position;
    pos = [position.X; position.Y; position.Z];
    posRotated = R_OdomToGround*pos + T_OdomToGround;
    posHistory = [posHistory posRotated];

    % orientation = odomMsg.Pose.Pose.Orientation;
    % orientQuat = [orientation.W orientation.X orientation.Y orientation.Z];
    % orientRotm = quat2rotm(orientQuat);
    % orientHistory = [orientHistory orientQuat'];

    % figure(1)
    % subplot(1,2,1)
    % scatter3( posHistory(1,:), posHistory(2,:), posHistory(3,:) );
    scatter3( pos(1,:), pos(2,:), pos(3,:) );

    % subplot(1,2,2)
    % scatter3( orientHistory(1,:), orientHistory(2,:), orientHistory(3,:) );
    % title('Orientation Quaternion History');
    % xlabel('X');
    % ylabel('Y');
    % zlabel('Z');

end
hold off
