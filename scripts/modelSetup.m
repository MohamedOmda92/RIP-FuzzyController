%% >>> Workspace Initialization
% Define directories
dir = fullfile(pwd, '..'); % project directory
stepFilesPth = fullfile(dir, 'stepFiles/');
fisPth = fullfile(dir, 'inferenceSystems/');
modelPath = fullfile(dir, 'simulation/ripControl.slx');

% Retrive Simulink Model Info
[~, modelName, ~] = fileparts(modelPath);
load_system(modelPath);

% Define FIS Names
swingUp = readfis([fisPth, 'mamT1_SwingUp.fis']);
swingUpNormalized = readfis([fisPth, 'mamT1_SwingUp_normalized.fis']);
stabilization = readfis([fisPth, 'mamT1_Stabilization.fis']);

% Define Step Files Names
baseFname = 'Base_Default_sldprt.STEP';
armFname = 'Link1_Default_sldprt.STEP';
pendFname = 'Link2_Default_sldprt.STEP';
weightFname = 'Weight_Default_sldprt.STEP';

% Define Base Body Dynamic Params 
baseMass = 0.318;
baseCOM = [0 0 30];
baseMOI = [1 1 1];
basePOI = [0 0 0];

% Define Arm Body Dynamic Params 
armMass = 0.087788486;
armCOM = [0.000000000, 0.031271184, 0.050828657];
armMOI = [-0.000133229, 0.000027714, 0.000107116];
armPOI = [-0.000030229, -0.000000000, 0.000000000];

% Define Pendulum Body Dynamic Params 
penMass = 0.032766592;
penCOM = [0.045918100, 0.000317458, 0];
penMOI = [-0.000000588, -0.000108022, -0.000107668];
penPOI = [0.000000000, 0, 0.000000478];

% Define Weight Body Dynamic Params 
weightMass = 0.005517026;
weightCOM = [0 0 7];
weightMOI = [0.000000039, 0.000000110, 0.000000110];
weightPOI = [0.000000000, 0.000000000, -0.000000000];

% Define Joints Initial States
alpha = 0;
theta = 0;


%% >>> FLC Controllers Configuration
% Rertrieve Handles
swingupFlcHn = [modelName, '/SwingUp Controller/SwingUp FLC'];
stabFlcHn = [modelName, '/Stabilization Controller/Stabilization FLC'];

% Set FLCs {FIS Name}
set_param(swingupFlcHn, 'FIS', 'swingUpNormalized');
set_param(stabFlcHn, 'FIS', 'stabilization');


%% >>> RIP Model Configuration
% Retrieve Bodies Handles
systemHn = [modelName, '/RIP System'];
baseHn = [systemHn, '/Base Body'];
armHn = [systemHn, '/Arm Body'];
pendHn = [systemHn, '/Pendulum Body'];
weightHn = [systemHn, '/Weight Body'];

% Set Solid Bodies {File Name}
set_param(baseHn, 'ExtGeomFileName', fullfile(stepFilesPth, baseFname))
set_param(armHn, 'ExtGeomFileName', fullfile(stepFilesPth, armFname))
set_param(pendHn, 'ExtGeomFileName', fullfile(stepFilesPth, pendFname))
set_param(weightHn, 'ExtGeomFileName', fullfile(stepFilesPth, weightFname))

% Revolute Joints 

%% >>> Simulation Configuration
simulationTime = 15;
open_system(modelPath);


% simOut = sim(modelPath, simulationTime);
% disp(simOut)