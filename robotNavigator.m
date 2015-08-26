odomTopic = '/kinect_odometer/odometry';
timerHandles.odomSub = rossubscriber(odomTopic);
joyCmdsTopic = '/chair_joy2';
timerHandles.joyCmdsPub = rospublisher(joyCmdsTopic, rostype.sensor_msgs_Joy);
timerHandles.R_OdomToGround = R_OdomToGround;
timerHandles.T_OdomToGround = T_OdomToGround;
timerHandles.goalState = [0 3]; % [x y]
timer1 = timer('TimerFcn',{@moveRobot,timerHandles},'Period',0.01,'ExecutionMode','fixedSpacing');
% timer1.StopFcn = {@exampleHelperTurtleBotStopCallback};
% start(timer1);

% hold off
