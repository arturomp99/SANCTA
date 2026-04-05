classdef Satellite
    properties (Constant, Access=private)
        period = 12 * 3600; % s
    end

    properties (Access=private)
        r
        theta
    end

    methods (Access=public)
        function obj = Satellite(theta0)
            obj.r = Earth.radius + Constellation.satHeight;
            obj.theta = theta0;
        end

        function pos = getPositionPerifocal(obj)
            pos = [
                obj.r * cos(obj.theta);
                obj.r * sin(obj.theta);
                0
            ];
        end

        function pos = getPositionPerifocalAt(obj, time)
            angularVelocity = 2*pi/Orbita.period;
            pos = [
                obj.r * cos(obj.theta + angularVelocity * time);
                obj.r * sin(obj.theta + angularVelocity * time);
                0
            ];
        end
    end
end