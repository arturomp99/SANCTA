classdef Orbita

    properties (Constant)
        nSatellites = 4;
        period = 12 * 3600; % el periodo orbital son 12 horas
        inclination = 55 * pi / 180;
    end

    properties (Access = private)
        rans
        satellites Satellite
    end

    methods (Access = public)

        function obj = Orbita(rans, offset)

            obj.rans = rans;
            obj.satellites = [ ...
                                  Satellite(offset, rans), ...
                                  Satellite(offset + pi / 2, rans), ...
                                  Satellite(offset + pi, rans), ...
                                  Satellite(offset + 3 * pi / 2, rans), ...
                              ];

        end

        function plot(obj, resolution)
            r = Earth.radius + Constellation.satHeight;
            rotMatrix = obj.getOrbitRotationMatrix();
            thetaVector = linspace(0, 2 * pi, resolution);
            orbitPts = rotMatrix * [
                                    r * cos(thetaVector);
                                    r * sin(thetaVector);
                                    zeros(1, resolution)
                                    ];

            plot3(orbitPts(1, :), orbitPts(2, :), orbitPts(3, :));
        end

        function sats = getSatellites(obj)
            sats = obj.satellites;
        end

    end

    methods (Access = private)

        function rotMatrix = getOrbitRotationMatrix(obj)
            rotMatrix = RotationMatrix.rotZ(obj.rans) * RotationMatrix.rotX(obj.inclination);
        end

    end

end
