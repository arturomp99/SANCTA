clc; close all; clear all;

%% Setup
config.FPS = 20; % Animation Frames per Second
config.final_t = 3600; % s
config.simulation_speed = 200; % x200 faster

constellation = Constellation();
observer = Observer(39, 0);

%% Plot the constellation
figure;
hold on
constellation.plotOrbitas();
Earth.plot();
constellation.plotSats(observer);
observer.plot();
hold off

%% Least Squares Filter
lsFilter = LeastSquaresFilter(observer);
[posEstimationHistory, biasEstimationHistory] = ...
    lsFilter.estimate(constellation.getSatsPos());
stepsVec = 1:LeastSquaresFilter.maxIterations;

figure;
hold on

longitude = atan2d(posEstimationHistory(2, :), posEstimationHistory(1, :));
latitude = atan2d(posEstimationHistory(3, :), vecnorm(posEstimationHistory(1:2, :)));
radius = vecnorm(posEstimationHistory);

subplot(4, 1, 1)
plot(stepsVec, longitude)

subplot(4, 1, 2)
plot(stepsVec, latitude)

subplot(4, 1, 3)
plot(stepsVec, radius)

subplot(4, 1, 4)
plot(stepsVec, biasEstimationHistory)

hold off
