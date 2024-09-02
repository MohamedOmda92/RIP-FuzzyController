s = daq("ni");

% Add inputs for the encoders and direction signals
arm = addinput(s, 'Dev1', 'ctr0', 'EdgeCount');
pen = addinput(s, 'Dev1', 'ctr1', 'EdgeCount');
dir1 = addinput(s, "Dev1","port0/line6","Digital");
dir2 = addinput(s, "Dev1","port0/line7","Digital");

%Encoders Specs
armCPR = 1440; % 4 x 360
penCPR = 4096; % 4 x 1024

% Initialize variables for counting
armCount = 0;
penCount = 0;
previousArmCount = 0;
previousPenCount = 0;

% Set up the figure and animated lines for live plotting
figure;
h_arm = animatedline('Color', 'b');  % Blue line for arm encoder
h_pen = animatedline('Color', 'r');  % Red line for pendulum encoder
xlabel('Time (s)');
ylabel('Encoders Angle');
legend('Arm Encoder', 'Pendulum Encoder');
grid on;

% Initialize time variable for live plot
startTime = tic;  % Start timer

% Infinite loop to read data, adjust counting, and live plot
while true
    % Read the data for encoder counts and direction signals
    data = read(s, 'OutputFormat', 'Matrix'); 

    currentArmCount = data(:,1);  % Arm encoder count
    currentPenCount = data(:,2);  % Pendulum encoder count
    armDirState = data(:,3);      % Direction for arm
    penDirState = data(:,4);      % Direction for pendulum

    % Calculate the difference in encoder counts since the last reading
    countDiffArm = currentArmCount - previousArmCount;
    countDiffPen = currentPenCount - previousPenCount;

    % Adjust the encoder counts based on the direction
    if armDirState == 1  % Forward direction for arm
        armCount = armCount + countDiffArm;  % Increment count
    elseif armDirState == 0  % Reverse direction for arm
        armCount = armCount - countDiffArm;  % Decrement count
    end

    if penDirState == 1  % Forward direction for pendulum
        penCount = penCount + countDiffPen;  % Increment count
    elseif penDirState == 0  % Reverse direction for pendulum
        penCount = penCount - countDiffPen;  % Decrement count
    end

    if armCount >= armCPR
        armCount = armCount - armCPR;
    elseif armCount <= -armCPR
        armCount = armCount + armCPR;
    end

    if penCount >= penCPR
        penCount = penCount - penCPR;
    elseif penCount <= -penCPR
        penCount = penCount + penCPR;
    end    

    armAngle = (armCount/armCPR)*360;
    penAngle = (penCount/penCPR)*360;

    % Display the adjusted encoder counts
    disp(['Arm Encoder Count: ', num2str(armAngle)]);
    disp(['Pendulum Encoder Count: ', num2str(penAngle)]);
    disp(newline);

    % Get the current elapsed time for plotting
    currentTime = toc(startTime);

    % Add points to the live plot
    addpoints(h_arm, currentTime, armAngle);
    addpoints(h_pen, currentTime, penAngle);

    % Update the plot
    drawnow;

    % Update the previous counts for the next loop iteration
    previousArmCount = currentArmCount;
    previousPenCount = currentPenCount;

    % Pause briefly to prevent excessive CPU usage
    pause(0.01);  % Adjust this time as needed
end

