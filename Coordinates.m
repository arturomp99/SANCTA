classdef Coordinates

    methods (Static)

        function posGeografic = ecef2geografic(x, y, z)
            % Transforma las coordenadas desde el sistema de coordenadas ECEF al sistema de coordenadas geografico
            % OUTPUT
            %   - longitud
            %   - latitud
            %   - altura
            posGeografic = [
                            atan2d(y, x); % longitud
                            atan2d(z, norm([x, y])); % latitud
                            norm([x, y]) / cosd(atan2d(z, norm([x, y]))) % altitud
                            ];
        end

        function posEcef = geografic2ecef(lat, lon, h)
            % Transforma las coordenadas desde el sistema de coordenadas geografico al sistema de coordenadas ECEF
            % INPUT
            %   - latitud (degrees)
            %   - longitud (degrees)
            %   - altura (degrees)

            posEcef = (Earth.radius + h) * [
                                            cosd(lat) * cosd(lon);
                                            cosd(lat) * sind(lon);
                                            sind(lat)
                                            ];
        end

        function observerTransformMatrix = ...
                findObserverTransformMatrix(lon, lat)
            normalVec = Coordinates.findNormalVector(lon, lat);
            northingVec = Coordinates.findNorthingVec(lon, lat);
            eastingVec = Coordinates.findEastingVec(normalVec, northingVec);

            observerTransformMatrix = [eastingVec, northingVec, normalVec];
        end

        function normalVec = findNormalVector(lon, lat)
            normalVec = [
                         cosd(lat) * cosd(lon);
                         cosd(lat) * sind(lon);
                         sind(lat);
                         ];

        end

        function northingVec = findNorthingVec(lon, lat)
            northingVec = [
                           -sind(lat) * cosd(lon);
                           -cosd(lat) * sind(lon);
                           cosd(lat);
                           ];
        end

        function eastingVec = findEastingVec(normalVec, northingVec)
            eastingVec = cross(northingVec, normalVec);
        end

    end

end
