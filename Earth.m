classdef Earth
    properties (Constant, Access=public)
        radius = 6378; % km
    end

    properties (Constant, Access=private)
        resolution = 50;
    end

    methods (Static)
        function plot()
            [X, Y, Z] = sphere(Earth.resolution);
            earth = surf(X * Earth.radius, Y * Earth.radius, Z * Earth.radius);
            set(earth, 'FaceColor', [0 0.45 0.74], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
        end
    end
end