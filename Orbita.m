classdef Orbita
    properties (Constant)
        nSatellites = 4;
        period = 12 * 3600; % el periodo orbital son 12 horas
    end

    properties (Constant, Access=private)
        inclination = 55 * pi/180;
    end

    properties (Access=private)
        rans
        satellites
    end

    methods (Access = private)
        function rotMatrix = getOrbitRotationMatrix(obj)
            rotMatrix = RotationMatrix.rotZ(obj.rans) * RotationMatrix.rotX(obj.inclination);
        end
    end

    methods (Access=public)
        function obj = Orbita(rans, offset)
            if nargin > 0 
                obj.rans = rans;
                obj.satellites = [...
                    Satellite(offset),...
                    Satellite(offset + pi/2),...
                    Satellite(offset + pi),...
                    Satellite(offset + 3*pi/2),...
                ];
            end
        end

        function satPositions = getSatPositions(obj)
            rotMatrix = obj.getOrbitRotationMatrix();
            satPositions = zeros(3, Orbita.nSatellites);

            for index=1:Orbita.nSatellites
                sat = obj.satellites(index);
                satPositions(:, index) = rotMatrix * sat.getPositionPerifocal();
            end
        end

        function satPositions = getSatPositionsAt(obj, time)
            rotMatrix = obj.getOrbitRotationMatrix();
            satPositions = zeros(3, Orbita.nSatellites);

            for index=1:Orbita.nSatellites
                sat = obj.satellites(index);
                satPositions(:, index) = rotMatrix * sat.getPositionPerifocalAt(time);
            end
        end

        function plot(obj, resolution)
            r = Earth.radius + Constellation.satHeight;
            rotMatrix = obj.getOrbitRotationMatrix();
            thetaVector = linspace(0, 2*pi, resolution);
            orbitPts = rotMatrix * [
                r * cos(thetaVector);
                r * sin(thetaVector);
                zeros(1, resolution)
            ];

            plot3(orbitPts(1,:), orbitPts(2,:), orbitPts(3,:));
        end
    end
end