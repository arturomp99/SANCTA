classdef LeastSquaresFilter < handle

    properties (Constant)
        maxIterations = 20;
        signoise = 100; % desviacion tipica de las medidas de los satelites
    end

    properties (Constant, Access = private)
        initialEstimatedBias = 0;
        initialEstimatedPos = [0; 0; 0];
    end

    properties (Access = private)
        estimatedBias;
        estimatedPos;
        observer;
    end

    methods (Access = public)

        function obj = LeastSquaresFilter(observer)
            obj.estimatedBias = obj.initialEstimatedBias;
            obj.estimatedPos = obj.initialEstimatedPos;
            obj.observer = observer;
        end

        function [posEstimationHistory, biasEstimationHistory] = estimate(obj, satsPos)
            posEstimationHistory = zeros(3, obj.maxIterations);
            biasEstimationHistory = zeros(1, obj.maxIterations);

            [~, visibleSatPos] = obj.observer.getVisibleSats(satsPos);

            for i = 1:obj.maxIterations
                [bias, pos] = obj.estimationStep(visibleSatPos);
                obj.estimatedBias = bias;
                obj.estimatedPos = pos;
                posEstimationHistory(:, i) = pos;
                biasEstimationHistory(i) = bias;
            end

        end

        function plotEstimations(obj, posEstimationHistory, biasEstimationHistory)
            stepsVec = 1:LeastSquaresFilter.maxIterations;

            figure;
            hold on

            longitude = atan2d(posEstimationHistory(2, :), posEstimationHistory(1, :));
            latitude = atan2d(posEstimationHistory(3, :), vecnorm(posEstimationHistory(1:2, :)));
            radius = vecnorm(posEstimationHistory);

            subplot(4, 2, 1)
            plot(stepsVec, longitude)
            title('Longitud estimada')
            xlabel('Iteración')

            subplot(4, 2, 2)
            plot(stepsVec, latitude)
            title('Latitude estimada')
            xlabel('Iteración')

            subplot(4, 2, 3)
            plot(stepsVec, radius)
            title('Radio Estimado')
            xlabel('Iteración')

            subplot(4, 2, 4)
            plot(stepsVec, biasEstimationHistory)
            title('Bias estimado')
            xlabel('Iteración')

            % Visualizar los errores de estimacion
            observerPos = obj.observer.getPos();
            observerBias = obj.observer.getBias();
            observerLongitude = atan2d(observerPos(2), observerPos(1));
            observerLatitude = atan2d(observerPos(3), norm(observerPos(1:2)));
            observerRadius = norm(observerPos);
            longitudeError = longitude - observerLongitude;
            latitudeError = longitude - observerLatitude;
            radiusError = longitude - observerRadius;
            biasError = biasEstimationHistory - observerBias;

            subplot(4, 2, 4 + 1)
            plot(stepsVec, longitudeError)
            title('Error de estimación de la longitud')
            xlabel('Iteración')

            subplot(4, 2, 4 + 2)
            plot(stepsVec, latitudeError)
            title('Error de estimación de la latitud')
            xlabel('Iteración')

            subplot(4, 2, 4 + 3)
            plot(stepsVec, radiusError)
            title('Error de estimación del radio')
            xlabel('Iteración')

            subplot(4, 2, 4 + 4)
            plot(stepsVec, biasError)
            title('Error de estimación del bias')
            xlabel('Iteración')

            hold off

        end

    end

    methods (Access = private)

        function [estimatedBias, estimatedPos] = estimationStep(obj, statsPos)
            observerBias = obj.observer.getBias();
            measuredPseudodistances = obj.findPseudodistances(statsPos, obj.observer.getPos(), observerBias, obj.signoise);
            estimatedPseudodistances = obj.findPseudodistances(statsPos, obj.estimatedPos, obj.estimatedBias, 0);

            measuresResidual = measuredPseudodistances - estimatedPseudodistances;

            jacobian = obj.findJacobian(statsPos, obj.estimatedPos, obj.estimatedBias);

            estimationsResidual = (jacobian' * jacobian) \ (jacobian' * measuresResidual);

            estimation = estimationsResidual + [obj.estimatedPos; obj.estimatedBias];

            estimatedPos = estimation(1:3);
            estimatedBias = estimation(4);
        end

        function pseudoDistances = findPseudodistances(obj, positions, observerPosition, bias, signoise)
            pseudoDistances = [];

            for i = 1:size(positions, 2)
                pseudoDistance = norm(observerPosition - positions(:, i));
                pseudoDistances = [pseudoDistances; pseudoDistance];
            end

            pseudoDistances = pseudoDistances + Earth.lightSpeed * bias + signoise * randn(size(pseudoDistances, 2));

        end

        function jacobian = findJacobian(obj, satsPos, estimatedPos, estimatedBias)
            jacobian = [];

            for i = 1:size(satsPos, 2)
                satPos = satsPos(:, i);
                estimatedPseudodistance = norm(estimatedPos - satPos);
                jacobian(i, :) = [- (satPos(1) - estimatedPos(1)) / (estimatedPseudodistance), ...
                                      - (satPos(2) - estimatedPos(2)) / (estimatedPseudodistance), ...
                                      - (satPos(3) - estimatedPos(3)) / (estimatedPseudodistance), ...
                                      Earth.lightSpeed];
            end

        end

    end

end
