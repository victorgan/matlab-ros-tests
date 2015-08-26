function copyTopicTimer(mTimer, event, handles)
    persistent isSetup; % empty for first run, true for all subsequent runs
    persistent angularJoyCmd;
    persistent translationalJoyCmd;
    if isempty(isSetup)
        handles.chairJoySub.NewMessageFcn = @callbackInternal; % populates posRotated
        disp('Setting Up..Please Wait 3 Seconds');
        pause(3); % in seconds
        isSetup = true;
    end % if isempty(isSetup)

    joyCmdsMsg = rosmessage(handles.joyCmdsPub);
    joyCmdsMsg.Header.Stamp = rostime('now'); 
    joyCmdsMsg.Axes = [angularJoyCmd translationalJoyCmd];
    send(handles.joyCmdsPub, joyCmdsMsg);

    function callbackInternal(~, message)
        %ODOMCALLBACKINTERNAL Collects pose information
        angularJoyCmd = message.Axes(1);
        translationalJoyCmd = message.Axes(2);
    end
end % function
