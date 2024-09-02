function readEncoderSFcn(block)
% Custom S-Function for NI Encoder Data Acquisition

setup(block);

function setup(block)
    % Register number of ports
    block.NumInputPorts  = 0;
    block.NumOutputPorts = 2; % Output ports for arm and pen angles

    % Setup output port properties
    block.OutputPort(1).Dimensions        = 1;
    block.OutputPort(2).Dimensions        = 1;
    block.OutputPort(1).SamplingMode      = 'Sample';
    block.OutputPort(2).SamplingMode      = 'Sample';

    % Register the methods
    block.RegBlockMethod('Outputs', @Output);
    block.RegBlockMethod('Start', @Start);
    block.RegBlockMethod('Terminate', @Terminate);

    % Specify sample time
    block.SampleTimes = [0.01 0];  % [sample time, offset] in seconds

function Output(block)
    % Read and update encoder data
    global s armCount penCount previousArmCount previousPenCount
    data = read(s, 'OutputFormat', 'Matrix'); 
    currentArmCount = data(:,1); 
    currentPenCount = data(:,2); 
    armDirState = data(:,3); 
    penDirState = data(:,4);

    countDiffArm = currentArmCount - previousArmCount;
    countDiffPen = currentPenCount - previousPenCount;

    if armDirState == 1
        armCount = armCount + countDiffArm;
    elseif armDirState == 0
        armCount = armCount - countDiffArm;
    end

    if penDirState == 1
        penCount = penCount + countDiffPen;
    elseif penDirState == 0
        penCount = penCount - countDiffPen;
    end

    % Encoder specs
    armCPR = 1440;
    penCPR = 4096;

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

    block.OutputPort(1).Data = armAngle;
    block.OutputPort(2).Data = penAngle;

    previousArmCount = currentArmCount;
    previousPenCount = currentPenCount;

function Start(block)
    % Initialize global variables and set up DAQ session
    global s armCount penCount previousArmCount previousPenCount
    s = daq("ni");
    addinput(s, 'Dev1', 'ctr0', 'EdgeCount');
    addinput(s, 'Dev1', 'ctr1', 'EdgeCount');
    addinput(s, 'Dev1', "port0/line6", "Digital");
    addinput(s, 'Dev1', "port0/line7", "Digital");

    armCount = 0;
    penCount = 0;
    previousArmCount = 0;
    previousPenCount = 0;

function Terminate(block)
    % Cleanup
    global s
    delete(s);
    clear global s;
