currentDir = fullfile(pwd, '..');

%retrieve directories
modelPath = fullfile(currentDir, 'simulation', 'ripControl');
fisPath1 = fullfile(currentDir, 'inferenceSystems', 'mamT1_Stabilization.fis');
fisPath2 = fullfile(currentDir, 'inferenceSystems', 'mamT1_SwingUp.fis');
fisPath3 = fullfile(currentDir, 'inferenceSystems', 'mamT1_SwingUp_normalized.fis');
stepFilesPath = fullfile(currentDir, 'stepFiles');

load_system(fullfile(currentDir, 'simulation/ripControl.slx'));

%InferenceSystems Objects
stabilization = readfis(fisPath1);
swingUp = readfis(fisPath2);
swingUpNormalized = readfis(fisPath3);

%step files names
baseFname = 'Base_Default_sldprt.STEP';
armFname = 'Link1_Default_sldprt.STEP';
pendFname = 'Link2_Default_sldprt.STEP';
weightFname = 'Weight_Default_sldprt.STEP';

%retrieve bodies handles
systemHn = 'ripControl/RIP System';
baseHn = [systemHn, '/Base Body'];
armHn = [systemHn, '/Arm Body'];
pendHn = [systemHn, '/Pendulum Body'];
weightHn = [systemHn, '/Weight Body'];

%Set Bodies (File Name)
set_param(baseHn, 'ExtGeomFileName', fullfile(stepFilesPath, baseFname))
set_param(armHn, 'ExtGeomFileName', fullfile(stepFilesPath, armFname))
set_param(pendHn, 'ExtGeomFileName', fullfile(stepFilesPath, pendFname))
set_param(weightHn, 'ExtGeomFileName', fullfile(stepFilesPath, weightFname))

%Simulation Parameters
simulationTime = 15;

%Initial Conditions
alpha = 0;
theta = 0;

%Dynamic Parameters
baseMass = 0.318;
baseCOM = [0 0 30];
baseMOI = [1 1 1];
basePOI = [0 0 0];

armMass = 0.087788486;
armCOM = [0.000000000, 0.031271184, 0.050828657];
armMOI = [-0.000133229, 0.000027714, 0.000107116];
armPOI = [-0.000030229, -0.000000000, 0.000000000];

penMass = 0.032766592;
penCOM = [0.045918100, 0.000317458, 0];
penMOI = [-0.000000588, -0.000108022, -0.000107668];
penPOI = [0.000000000, 0, 0.000000478];

weightMass = 0.005517026;
weightCOM = [0 0 7];
weightMOI = [0.000000039, 0.000000110, 0.000000110];
weightPOI = [0.000000000, 0.000000000, -0.000000000];

open_system(modelPath);

% simOut = sim(modelPath, simulationTime);
% disp(simOut)