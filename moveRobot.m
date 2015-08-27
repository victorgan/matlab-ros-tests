
function moveRobot(mTimer, event, handles)
    persistent isSetup; % empty for first run, true for all subsequent runs
    persistent posRotated;
    persistent initialTime;
    persistent theta;

    currentTime = datetime(event.Data.time);

    if isempty(isSetup)
        handles.odomSub.NewMessageFcn = @odomCallbackInternal; % populates posRotated and theta
        disp('Setting Up..Please Wait 3 Seconds');
        initialTime = currentTime;
        pause(3); % in seconds
        isSetup = true;
    end % if isempty(isSetup)

    distFromGoalState = norm([posRotated(1) - handles.goalState(1), posRotated(2) - handles.goalState(2)]);
    closeToGoalState = distFromGoalState < 0.7; % metres
    if closeToGoalState
        disp('found goal')
        angularJoyCmd = 0.00;
        translationalJoyCmd = 0.0;
        stop(mTimer);
    elseif seconds(currentTime - initialTime) > 20 % seconds
        % timeout sanity check
        disp('too long')
        angularJoyCmd = 0.00;
        translationalJoyCmd = 0.0;
        stop(mTimer);
        % distFromGoalState
    else % far from goal state
        disp('moving forward')
        [angularJoyCmd, translationalJoyCmd] = purePursuit(posRotated, theta, handles.goalState);
        translationalJoyCmd = -1 * translationalJoyCmd; % camera is mounted behind
        % distFromGoalState
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

        orientation = message.Pose.Pose.Orientation;
        orientQuat = [orientation.W orientation.X orientation.Y orientation.Z];
        orientRotm = quat2rotm(orientQuat);
        orientRotmGround = handles.R_OdomToGround*orientRotm;
        orientEul = rotm2eul(orientRotmGround);
        theta = orientEul(1); % angle wrt positive x-axis on the x-y plane

        % orientHistory = [orientHistory theta];
        % TODO orientation too
    end
end % function

% posRotated: [x y z]
% theta: angle wrt positive x-axis on the x-y plane
function [angularJoyCmd, translationalJoyCmd] = purePursuit(posRotated, theta, goalState)

    posRotatedDouble = double(posRotated);
    thetaDouble = double(theta);
    % Assume an initial robot orientation (the robot orientation is the angle
    % between the robot heading and the positive X-axis, measured
    % counterclockwise).
    robotCurrentLocation = [posRotatedDouble(1) posRotatedDouble(2)];
    initialOrientation = thetaDouble;
    robotCurrentPose = [robotCurrentLocation initialOrientation];

    path = [robotCurrentLocation; goalState(1) goalState(2)]; % can include more waypoints. Not yet.
    %% Define the path following controller
    % Based on the path defined above and a robot motion model, you need a path
    % following controller to drive the robot along the path. Create the path
    % following controller using the  |<docid:robotics_ref.buoofp1-1 robotics.PurePursuit>|  object.
    controller = robotics.PurePursuit;
    controller.Waypoints = path;
    controller.DesiredLinearVelocity = 0.7;
    controller.MaxAngularVelocity = 1;
    controller.LookaheadDistance = 0.5;

    % Compute the controller outputs, i.e., the inputs to the robot
    [v, omega] = step(controller, robotCurrentPose);

    angularJoyCmd = omega;
    translationalJoyCmd = v;
end % function
