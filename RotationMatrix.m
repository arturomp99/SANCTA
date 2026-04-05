classdef RotationMatrix
    methods (Static)
        function matrix = rotX(theta)
            matrix = [
                1   0           0; 
                0   cos(theta)  -sin(theta); 
                0   sin(theta)  cos(theta)
            ];
        end

        function matrix = rotY(theta)
            matrix = [
                cos(theta)  0   sin(theta);
                0           1   0;
                -sin(theta) 0   cos(theta)
            ];
        end

        function matrix = rotZ(theta)
            matrix = [
                cos(theta)  -sin(theta) 0;
                sin(theta)  cos(theta)  0; 
                0           0           1
            ];
        end
    end
end