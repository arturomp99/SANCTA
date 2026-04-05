clc; close all; clear all;

config.FPS = 20; % Animation Frames per Second
config.final_t = 3600; % s
config.simulation_speed = 200; % x200 faster

constellation = Constellation();

figure;
hold on
constellation.plotOrbitas();
Earth.plot();
constellation.simulateSatellites(...
    config.final_t,...
    config.FPS,...
    config.simulation_speed...
);

hold off