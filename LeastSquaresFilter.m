classdef LeastSquaresFilter < handle

    properties (Constant)
        maxIterations = 1000;
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

            for i = 1:obj.maxIterations
                [bias, pos] = obj.estimationStep(satsPos);
                obj.estimatedBias = bias;
                obj.estimatedPos = pos;
                posEstimationHistory(:, i) = pos;
                biasEstimationHistory(i) = bias;
            end

        end

    end

    methods (Access = private)

        function [estimatedBias, estimatedPos] = estimationStep(obj, statsPos)
            measuredPseudodistances = obj.findPseudodistances(statsPos, obj.observer.getPos());
            estimatedPseudodistances = obj.findPseudodistances(statsPos, obj.estimatedPos) + Earth.lightSpeed * obj.estimatedBias;

            measuresResidual = measuredPseudodistances - estimatedPseudodistances;

            jacobian = obj.findJacobian(statsPos, obj.estimatedPos, obj.estimatedBias);

            estimationsResidual = (jacobian' * jacobian) \ (jacobian' * measuresResidual);

            estimation = estimationsResidual + [obj.estimatedPos; obj.estimatedBias];

            estimatedPos = estimation(1:3);
            estimatedBias = estimation(4);
        end

        function pseudoDistances = findPseudodistances(obj, positions, observerPosition)
            pseudoDistances = [];

            for i = 1:length(positions)
                pseudoDistance = norm(observerPosition - positions(i));
                pseudoDistances = [pseudoDistances; pseudoDistance];
            end

        end

        function jacobian = findJacobian(obj, satsPos, estimatedPos, estimatedBias)
            jacobian = [];

            for i = 1:length(satsPos)
                satPos = satsPos(:, i);
                estimatedPseudodistance = norm(estimatedPos - satPos);
                jacobian(i, :) = [- (satPos(1) - estimatedPos(1)) / (estimatedPseudodistance - Earth.lightSpeed * estimatedBias), ...
                                      - (satPos(2) - estimatedPos(2)) / (estimatedPseudodistance - Earth.lightSpeed * estimatedBias), ...
                                      - (satPos(3) - estimatedPos(3)) / (estimatedPseudodistance - Earth.lightSpeed * estimatedBias), ...
                                      Earth.lightSpeed];
            end

        end

    end

end
