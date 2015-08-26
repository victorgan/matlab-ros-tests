
function moveRobot(mTimer, event, handles)
    persistent isSetup; % empty for first run, true for all subsequent runs
    persistent posRotated;
    if isempty(isSetup)
        handles.odomSub.NewMessageFcn = @odomCallbackInternal; % populates posRotated
        disp('Setting Up..Please Wait 3 Seconds');
        pause(3); % in seconds
        isSetup = true;
    end % if isempty(isSetup)

    distFromGoalState = norm([posRotated(1) - handles.goalState(1), posRotated(2) - handles.goalState(2)]);
    closeToGoalState = distFromGoalState < 2.5; % metres
    if closeToGoalState
        angularJoyCmd = 0.00;
        translationalJoyCmd = 0.0;
    else
        angularJoyCmd = 0.00;
        translationalJoyCmd = 0.05;
    end

    joyCmdsMsg = rosmessage(handles.joyCmdsPub);
    joyCmdsMsg.Header.Stamp = rostime('now'); 
    joyCmdsMsg.Axes = [angularJoyCmd translationalJoyCmd];
    send(handles.joyCmdsPub, joyCmdsMsg);

    function odomCallbackInternal(~, message)
        %ODOMCALLBACKINTERNAL Collects pose information
        position = message.Pose.Pose.Position;
        pos = [position.X; position.Y; position.Z];
        posRotated = handles.R_OdomToGround*pos + handles.T_OdomToGround;
    end
end % function
