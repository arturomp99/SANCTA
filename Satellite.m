classdef Satellite

    properties (Constant, Access = private)
        period = 12 * 3600; % s
    end

    properties (Access = private)
        r;
        theta;
        inclination;
        rans;
        isVisible;
    end

    methods (Access = public)

        function obj = Satellite(theta0, rans)
            obj.r = Earth.radius + Constellation.satHeight;
            obj.theta = theta0;
            obj.inclination = Orbita.inclination;
            obj.rans = rans;
        end

        function pos = getPositionECIAt(obj, time)
            rotMatrix = obj.getOrbitRotationMatrix();
            posPerifocal = obj.getPositionPerifocalAt(time);

            pos = rotMatrix * posPerifocal;
        end

        function pos = getPositionECI(obj)
            rotMatrix = obj.getOrbitRotationMatrix();
            posPerifocal = obj.getPositionPerifocal();

            pos = rotMatrix * posPerifocal;
        end

        function obj = setIsVisible(obj, bool)
            obj.isVisible = bool;
        end

    end

    methods (Access = private)

        function rotMatrix = getOrbitRotationMatrix(obj)
            rotMatrix = RotationMatrix.rotZ(obj.rans) * RotationMatrix.rotX(obj.inclination);
        end

        function pos = getPositionPerifocal(obj)
            pos = [
                   obj.r * cos(obj.theta);
                   obj.r * sin(obj.theta);
                   0
                   ];
        end

        function pos = getPositionPerifocalAt(obj, time)
            angularVelocity = 2 * pi / Orbita.period;
            pos = [
                   obj.r * cos(obj.theta + angularVelocity * time);
                   obj.r * sin(obj.theta + angularVelocity * time);
                   0
                   ];
        end

    end

end
