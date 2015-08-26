
function moveRobot(mTimer, event, handles)
    persistent isSetup; % empty for first run, true for all subsequent runs
    persistent posRotated;
    persistent initialTime;

    currentTime = datetime(event.Data.time);

    if isempty(isSetup)
        handles.odomSub.NewMessageFcn = @odomCallbackInternal; % populates posRotated
        disp('Setting Up..Please Wait 3 Seconds');
        initialTime = currentTime;
        pause(3); % in seconds
        isSetup = true;
    end % if isempty(isSetup)

    distFromGoalState = norm([posRotated(1) - handles.goalState(1), posRotated(2) - handles.goalState(2)]);
    closeToGoalState = distFromGoalState < 2.5; % metres
    if closeToGoalState
        disp('found goal')
        angularJoyCmd = 0.00;
        translationalJoyCmd = 0.0;
    else if seconds(currentTime - initialTime) > 5 % 10 seconds
        % too long. terminate.
        disp('too long')
        angularJoyCmd = 0.00;
        translationalJoyCmd = 0.0;
    else % far from goal state
        disp('moving forward')
        angularJoyCmd = 0.00;
        translationalJoyCmd = 0.05;
    end


    % Filter the velocities
    % linVFilt = betaLin*linearV + (1-betaLin)*linVFilt;
    % angVFilt = betaAng*angularV + (1-betaAng)*angVFilt;

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
