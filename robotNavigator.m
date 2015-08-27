odomTopic = '/kinect_odometer/odometry';
timerHandles.odomSub = rossubscriber(odomTopic);
joyCmdsTopic = '/chair_joy2';
timerHandles.joyCmdsPub = rospublisher(joyCmdsTopic, rostype.sensor_msgs_Joy);
timerHandles.R_OdomToGround = R_OdomToGround;
timerHandles.T_OdomToGround = T_OdomToGround;
timerHandles.goalState = [0; 3.1]; % [x y]
% timerHandles.goalState = [0 chosenStateWorldY];
timerMoveRobot = timer('TimerFcn',{@moveRobot,timerHandles},'Period',0.01,'ExecutionMode','fixedSpacing');
start(timerMoveRobot);

% stop(timerMoveRobot)
% timerMoveRobot.Running
% delete(timerMoveRobot)
% clear timerMoveRobot
% clear timerHandles

% hold off
