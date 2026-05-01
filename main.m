%% Autores
%% - Martínez Pastor, Arturo José
%% -

clc; close all; clear all;

%% Setup
config.FPS = 20; % Animation Frames per Second
config.final_t = 3600; % s
config.simulation_speed = 200; % x200 faster

constellation = Constellation();
observer = Observer(39, 0);

%% Dibujar la constelacion
figure;
hold on
constellation.plotOrbitas();
Earth.plot();
constellation.plotSats(observer);
observer.plot();
hold off

%% Least Squares Filter - validacion
% Al cabo de pocas iteraciones, los valores estimados se aproximan los estados reales.

lsFilter = LeastSquaresFilter(observer);
[posEstimationHistory, biasEstimationHistory] = ...
    lsFilter.estimate(constellation.getSatsPos());
lsFilter.plotEstimations(posEstimationHistory, biasEstimationHistory);

%% Least Squares Filter - Simulation
% Los satélites cambian de posición
% Cada deltaT segundos se toman medidas y se estima la posición del observador

endT = 60; % s
deltaT = 1.5; % s

simulation = Simulation(constellation, lsFilter);
[vecT, posEstimations, biasEstimations] = simulation.simulate(endT, deltaT, 0);
simulation.visualizeResults(vecT, posEstimations, biasEstimations);

%% Simulation - Study of DOP
% Estudiar como cambia la dop cada 20 minutos durante 12 horas
% En cada instante estimamos la posicion durante 5 minutos con tiempos de muestreo de 10 segundos
initialT = 0; %s
endT = 12 * 3600; %s
deltaT = 20 * 60; %s
estimationDuration = 1 * 60; %s
estimationDeltaT = 1; %s

tVec = initialT:deltaT:(initialT + endT);
gDopHistory = zeros(1, length(tVec));
pDopHistory = zeros(1, length(tVec));
hDopHistory = zeros(1, length(tVec));
vDopHistory = zeros(1, length(tVec));
tDopHistory = zeros(1, length(tVec));

for i = 1:length(tVec)
    estimacionInitialT = tVec(i);
    estimacionEndT = estimationDuration + estimacionInitialT;

    [~, posEstimations, biasEstimations] = ...
        simulation.simulate(estimacionEndT, estimationDeltaT, estimacionInitialT);

    [gdop, pdop, hdop, vdop, tdop] = ...
        simulation.findDopStatistics(posEstimations, biasEstimations, observer);
    gDopHistory(i) = gdop;
    pDopHistory(i) = pdop;
    hDopHistory(i) = hdop;
    vDopHistory(i) = vdop;
    tDopHistory(i) = tdop;
end

figure;
hold on;
plot(tVec, [gDopHistory, pDopHistory, hDopHistory, vDopHistory, tDopHistory]);
legend('GDOP', 'PDOP', 'HDOP', 'VDOP', 'TDOP');
hold off;
