
function [R_OdomToGround, T_OdomToGround] = odomToGround()
    timeOut = 3; % seconds
    pointcloudTopic = '/camera/depth/points';
    pointcloudSub = rossubscriber(pointcloudTopic);
    pointCloudMsgOptic = receive(pointcloudSub,timeOut);
    clear('pointcloudSub')

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
    clear('tftree')

    xyzOptic = readXYZ(pointCloudMsgOptic);
    voxelGridSize = 0.05; % in metres
    ransacParams.floorPlaneTolerance = 0.02; % tolerance in m
    ransacParams.maxInclinationAngle = 30; % in degrees
    [~, ~, R_OpticToGround, T_OpticToGround, ~] = processPointCloudLocal(xyzOptic, voxelGridSize, ransacParams); % points are respect to gan_ground_frame

    xyzOdom = readXYZ(pointcloudMsgOdom);
    R_OdomToGround = R_OpticToGround*R_OdomToOptic;
    T_OdomToGround = T_OpticToGround+T_OdomToOptic;
    % pointCloudRotated2 = R_OdomToGround*xyzOdom' + repmat(T_OdomToGround,1,size(xyzOdom',2));
end
