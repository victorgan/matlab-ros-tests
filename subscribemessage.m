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
[~, ~, R_OpticToGround, T_OpticToGround, ~] = processPointCloudLocal(xyzOptic, voxelGridSize, ransacParams); % points are respect to gan_ground_frame

xyzOdom = readXYZ(pointcloudMsgOdom);
R_OdomToGround = R_OpticToGround*R_OdomToOptic;
T_OdomToGround = T_OpticToGround+T_OdomToOptic;
pointCloudRotated2 = R_OdomToGround*xyzOdom' + repmat(T_OdomToGround,1,size(xyzOdom',2));

% subscribe to odom, get inital odometry.
% points are respect to odom
odomTopic = '/kinect_odometer/odometry';
odomSub = rossubscriber(odomTopic);
odomMsg = receive(odomSub,timeOut);

goalState = [0 3]; % [x y]
joyCmdsTopic = '/chair_joy2';
joyCmdsPub = rospublisher(joyCmdsTopic, rostype.sensor_msgs_Joy);
pause(2) % Wait to ensure publisher is setup

figure(1)
% scatter3(pointcloudMsgOdom);
titleString = 'relative to ground';
plotPointCloud(pointCloud(pointCloudRotated2'), titleString);
xlabel('X');
ylabel('Y');
zlabel('Z');
hold on
posHistory = [];
orientHistory = [];
transJoyCmdHistory = [];
% plot3(goalState(1),goalState(2),0,'.','MarkerSize',50);
tic;
while toc < 100
    odomMsg = receive(odomSub,timeOut);

    position = odomMsg.Pose.Pose.Position;
    pos = [position.X; position.Y; position.Z];
    posRotated = R_OdomToGround*pos + T_OdomToGround;
    posHistory = [posHistory posRotated];

    % orientation = odomMsg.Pose.Pose.Orientation;
    % orientQuat = [orientation.W orientation.X orientation.Y orientation.Z];
    % orientRotm = quat2rotm(orientQuat);
    % orientEul = quat2eul(orientQuat);
    % theta = orientEul(1);
    % orientHistory = [orientHistory theta];

    % figure(1)
    % subplot(1,2,1)
    % scatter3( posHistory(1,:), posHistory(2,:), posHistory(3,:) );
    scatter3( posRotated(1,:), posRotated(2,:), posRotated(3,:) );


%     distFromGoalState = norm([posRotated(1) - goalState(1), posRotated(2) - goalState(2)])   
%     closeToGoalState = distFromGoalState < 0.5; % metres
%     if ~closeToGoalState
%         angularJoyCmd = 0.00;
%         translationalJoyCmd = 0.2;
%         transJoyCmdHistory = [transJoyCmdHistory translationalJoyCmd];
%         joyCmdsMsg = rosmessage(joyCmdsPub);
%         joyCmdsMsg.Axes = [angularJoyCmd translationalJoyCmd];
%         joyCmdsMsg.Header.Stamp = rostime('now'); 
%         send(joyCmdsPub, joyCmdsMsg);
%     end
end
hold off
