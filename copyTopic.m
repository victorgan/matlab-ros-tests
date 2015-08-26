joyCmds2Topic = '/chair_joy2';
sourceSub = rossubscriber(joyCmds2Topic, rostype.sensor_msgs_Joy);
sourceSub.NewMessageFcn = @(~,message) rospublisher('/chair_joy',message);

