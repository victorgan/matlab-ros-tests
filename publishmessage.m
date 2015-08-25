
joyCmdsTopic = '/chair_joy2';
joyCmdsPub = rospublisher(joyCmdsTopic, rostype.sensor_msgs_Joy);
pause(2) % Wait to ensure publisher is setup

while true
    % create an empty ros message that's the type of joyCmdsPub
    joyCmdsMsg = rosmessage(joyCmdsPub);

    % Populate message:
    % roughly, linear and angular veloctiy
    angularJoyCmd = 0.00;
    translationalJoyCmd = 0.2;
    joyCmdsMsg.Axes = [angularJoyCmd translationalJoyCmd];

    % output time
    joyCmdsMsg.Header.Stamp = rostime('now'); 

    % send!
    send(joyCmdsPub, joyCmdsMsg);
    pause(2)
end
