classdef reload < pls.pls_elem
    %classdef reload < pls_elem
    %   represents reload of a qubit
    %   has properties:
    %       time: stay a reload point for this time
    %       after_wait: wait at [0 0] for this long after reload
    %       ramp_time: ramp to load point in this time
    %       pos: location in gate space [x,y]
    
    properties
        time;
        after_wait;
        ramp_time;
        pos;
    end
    
    methods
        function rd = reload(varargin)
            rd =rd@pls.pls_elem(varargin{:});
        end
        
        function [pulsetab, mktab]=make_tab(rl)
            mktab = zeros(5,0);
            pulsetab = zeros(3, 0);
            if rl.time > 1e-11
                pulsetab(1, 1:4) = cumsum([rl.ramp_time, rl.time, rl.ramp_time,rl.after_wait]);
                pulsetab(2:3, end+(-3:0)) = [repmat(rl.pos', 1, 2), zeros(2)];
            end
        end
    end
    
end

