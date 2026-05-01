classdef Simulation

    properties (Access = private)
        constellation;
        lsFilter;
    end

    methods (Access = public)

        function obj = Simulation(constellation, lsFilter)
            obj.constellation = constellation;
            obj.lsFilter = lsFilter;
        end

        function [vecT, posEstimations, biasEstimations] = simulate(obj, endT, deltaT, initialT)
            vecT = initialT:deltaT:(initialT + endT);
            posEstimations = zeros(3, length(vecT));
            biasEstimations = zeros(1, length(vecT));

            for indexT = 1:length(vecT)
                t = vecT(indexT);
                [posEstimationHistory, biasEstimationHistory] = ...
                    obj.lsFilter.estimate(obj.constellation.getSatsPosAt(t));
                estimatedPos = posEstimationHistory(:, end);
                estimatedBias = biasEstimationHistory(end);
                posEstimations(:, indexT) = estimatedPos;
                biasEstimations(indexT) = estimatedBias;
            end

        end

        function visualizeResults(obj, vecT, posEstimations, biasEstimations)
            longitude = atan2d(posEstimations(2, :), posEstimations(1, :));
            latitude = atan2d(posEstimations(3, :), vecnorm(posEstimations(1:2, :)));
            altitude = sqrt(posEstimations(1, :) .^ 2 + posEstimations(2, :) .^ 2) ./ cosd(latitude);

            figure;
            hold on;
            subplot(4, 1, 1)
            plot(vecT, longitude)
            title('Estimaciones de la longitud')

            subplot(4, 1, 2)
            plot(vecT, latitude)
            title('Estimaciones de la latitud')

            subplot(4, 1, 3)
            plot(vecT, altitude)
            title('Estimaciones de la altitud')

            subplot(4, 1, 4)
            plot(vecT, biasEstimations)
            title('Estimaciones del bias')

            hold off;
        end

        function [gdop, pdop, hdop, vdop, tdop] = findDopStatistics(obj, posEstimations, biasEstimations, observer)
            [covMatrix, biasVariance] = obj.findStatistics(posEstimations, biasEstimations);
            transformMatrix = ...
                Coordinates.findObserverTransformMatrix(observer.getLon(), observer.getLat());
            covMatrixENU = obj.transformCovarianceMatrix(transformMatrix, covMatrix);

            varX = covMatrix(1, 1);
            varY = covMatrix(2, 2);
            varZ = covMatrix(3, 3);
            varE = covMatrixENU(1, 1);
            varN = covMatrixENU(2, 2);
            varU = covMatrixENU(3, 3);
            measureVariance = LeastSquaresFilter.signoise;

            % Calculos de las estadisticas DOP
            gdop = sqrt((varX + varY + varZ + biasVariance) / measureVariance);
            pdop = sqrt((varX + varY + varZ) / measureVariance);
            hdop = sqrt((varE + varN) / measureVariance);
            vdop = sqrt(varU / measureVariance);
            tdop = sqrt(biasVariance / measureVariance);
        end

    end

    methods (Access = private)

        function [covarianceMatrix, biasVariance] = ...
                findStatistics(obj, posEstimations, biasEstimations)
            estimations = [posEstimations; biasEstimations];
            variances = var(estimations, 0, 2);
            temp = cov(estimations(1, :), estimations(2, :)); covXY = temp(1, 2); covYX = temp(2, 1);
            temp = cov(estimations(1, :), estimations(3, :)); covXZ = temp(1, 2); covZX = temp(2, 1);
            temp = cov(estimations(2, :), estimations(3, :)); covYZ = temp(1, 2); covZY = temp(2, 1);

            covarianceMatrix = [
                                variances(1), covXY, covXZ;
                                covYX, variances(2), covYZ;
                                covZX, covZY, variances(3)
                                ];
            biasVariance = variances(4);
        end

        function transformedCovMatrix = ...
                transformCovarianceMatrix(obj, transformationMatrix, covMatrix)
            transformedCovMatrix = ...
                transformationMatrix' * covMatrix * transformationMatrix;
        end

    end

end
