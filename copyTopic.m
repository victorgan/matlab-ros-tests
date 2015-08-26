chairJoyTopic = '/chair_joy';
timerHandles.chairJoySub = rossubscriber(chairJoyTopic, rostype.sensor_msgs_Joy);
joyCmdsTopic = '/chair_joy2';
timerHandles.joyCmdsPub = rospublisher(joyCmdsTopic, rostype.sensor_msgs_Joy);
timerCopyTopic = timer('TimerFcn',{@copyTopicTimer,timerHandles},'Period',0.01,'ExecutionMode','fixedSpacing');
start(timerCopyTopic)
timerCopyTopic.Running

% stop(timerCopyTopic)
% timerCopyTopic.Running
% delete(timerCopyTopic)
