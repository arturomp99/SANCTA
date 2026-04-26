classdef Observer

    properties (Constant, Access = private)
        visibilityAngle = 90 - 15; % deg
        bias = 20;
    end

    properties (Access = private)
        pos;
    end

    methods (Access = public)

        function obj = Observer(lat, lon)
            obj.pos = Earth.radius * [
                                      cos(lat) * cos(lon);
                                      cos(lat) * sin(lon);
                                      sin(lat)
                                      ];
        end

        function plot(obj)
            position = obj.pos;
            scatter3(position(1), position(2), position(3), 'filled');
        end

        function [invisible, visible] = getVisibleSats(obj, satsPos)
            visible = [];
            invisible = [];

            for i = 1:length(satsPos)
                satPos = satsPos(:, i);
                isSatVisible = obj.findIsVisible(satPos);

                if (isSatVisible)
                    visible = [visible, satPos];
                else
                    invisible = [invisible, satPos];
                end

            end

        end

        function observerPos = getPos(obj)
            observerPos = obj.pos;
        end

    end

    methods (Access = private)

        function isSatVisible = findIsVisible(obj, target_position)
            vec_to_target = target_position - obj.pos;
            observer_position = obj.pos;

            angle_of_vision = ...
                acosd((dot(observer_position, vec_to_target)) / ...
                (norm(observer_position) * norm(vec_to_target)));

            isSatVisible = ...
                angle_of_vision < obj.visibilityAngle & ...
                angle_of_vision > -obj.visibilityAngle;
        end

    end

end
