classdef Constellation
    properties (Constant)
        satHeight = 20000; % km
    end
    properties (Constant, Access=private)
        numOrbitas = 6;
    end

    properties (Access=private)
        orbitas Orbita;
        satPositions;
    end

    methods (Access=private)
        function obj = initializeOrbitas(obj)
            nOrbitas = Constellation.numOrbitas;
            obj.orbitas(nOrbitas) = Orbita();
            for index = 1:nOrbitas
                rans = 360/nOrbitas * (index - 1) * pi/180; % Ascensión recta del nodo ascendente de la órbita
                offset = 15 * (index - 1) * pi/180;
                obj.orbitas(index) = Orbita(rans, offset);
            end
        end

        function obj = initializeSatPositions(obj)
            nOrbitas = Constellation.numOrbitas;
            nSatsPerOrbit = Orbita.nSatellites;
            obj.satPositions = zeros([3, nSatsPerOrbit, nOrbitas]);
        end

        function obj = updateSatPositions(obj, time)
            nOrbitas = Constellation.numOrbitas;
            for index = 1:nOrbitas
                orbita = obj.orbitas(index);
                obj.satPositions(:,:,index) = orbita.getSatPositionsAt(time);
            end
        end
    end

    methods (Access=public)
        function obj = Constellation()
            obj = obj.initializeOrbitas();
            obj = obj.initializeSatPositions();
            obj = obj.updateSatPositions(0);
        end

        function positions = getSatPositions(obj)
            positions = obj.satPositions;
        end

        function plotOrbitas(obj)
            for index = 1:obj.numOrbitas
                orbita = obj.orbitas(index);
                orbita.plot(500);
            end
        end

        function simulateSatellites(obj, tFinal, fps, speed)
            timeStep = 1/fps; % fps son los frames per second
            time = 0;
            figure = obj.plotSatPositions();
            drawnow;

            while time < tFinal
                time
                obj = obj.updateSatPositions(time);
                obj.updatePlotSatPositions(figure);
                drawnow;
                pause(timeStep);
                time = time + timeStep * speed;
            end
        end
    end

    methods (Access=private)
        function figure =  plotSatPositions(obj)
            positions = obj.satPositions;
            figure = scatter3(positions(1,:), positions(2,:), positions(3,:), 'filled');
        end

        function updatePlotSatPositions(obj, figure)
            positions = obj.satPositions;
            set(figure, ...
                'XData', positions(1,:), ...
                'YData', positions(2,:), ...
                'ZData', positions(3,:)...
            );
        end
    end
end