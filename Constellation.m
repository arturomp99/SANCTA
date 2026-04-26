classdef Constellation

    properties (Constant)
        satHeight = 20000; % km
    end

    properties (Constant, Access = private)
        numOrbitas = 6;
    end

    properties (Access = private)
        orbitas Orbita;
    end

    methods (Access = private)

        function obj = initializeOrbitas(obj)
            nOrbitas = Constellation.numOrbitas;

            for index = 1:nOrbitas
                rans = 360 / nOrbitas * (index - 1) * pi / 180; % Ascensión recta del nodo ascendente de la órbita
                offset = 15 * (index - 1) * pi / 180;
                obj.orbitas(index) = Orbita(rans, offset);
            end

        end

    end

    methods (Access = public)

        function obj = Constellation()
            obj = obj.initializeOrbitas();
        end

        function plotOrbitas(obj)

            for index = 1:obj.numOrbitas
                orbita = obj.orbitas(index);
                orbita.plot(500);
            end

        end

        function figure = plotSats(obj, observer)
            satsPos = obj.getSatsPos();

            [invisibleSatsPos, visibleSatsPos] = observer.getVisibleSats(satsPos);

            figure = scatter3( ...
                invisibleSatsPos(1, :), ...
                invisibleSatsPos(2, :), ...
                invisibleSatsPos(3, :), ...
                36, ...
                'black', ...
                'filled' ...
            );

            hold on

            scatter3( ...
                visibleSatsPos(1, :), ...
                visibleSatsPos(2, :), ...
                visibleSatsPos(3, :), ...
                36, ...
                'blue', ...
                'filled' ...
            );

        end

        function simulateSats(obj, tFinal, fps, speed)
            timeStep = 1 / fps; % fps son los frames per second
            time = 0;
            figure = obj.plotSats();
            drawnow;

            while time < tFinal
                obj = obj.updateSats(time);
                obj.updatePlotSatPositions(figure);
                drawnow;
                pause(timeStep);
                time = time + timeStep * speed;
            end

        end

        function satsPos = getSatsPos(obj)
            sats = obj.getSatellites();
            satsPos = [];

            nSats = length(sats);

            for i = 1:nSats
                sat = sats(i);
                satsPos = [satsPos, sat.getPositionECI()];
            end

        end

    end

    methods (Access = private)

        function sats = getSatellites(obj)
            nOrbitas = Constellation.numOrbitas;
            sats = [];

            for index = 1:nOrbitas
                orbita = obj.orbitas(index);
                sats = [sats, orbita.getSatellites()];
            end

        end

        function updatePlotSatPositions(obj, figure)
            positions = obj.satPositions;
            set(figure, ...
                'XData', positions(1, :), ...
                'YData', positions(2, :), ...
                'ZData', positions(3, :) ...
            );
        end

    end

end
