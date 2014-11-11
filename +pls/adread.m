classdef adread < pls.pls_elem
    %classdef adread < pls_elem
    %   represents adread. ramps from start to finish in time t
    
    properties
        time = .5;
        start = 1;
        finish = 5;;
        mult=1;
    end
    
    methods
        function ar = adread(varargin)
            ar = ar@pls.pls_elem(varargin{:});
        end
        
        function [pulsetab, mktab]=make_tab(ar)
            pulsetab = zeros(3, 0);
            mktab =  zeros(5, 0);
            if ar.time > 1e-11
                pulsetab(1, end+(1:2)) = [ar.dt, ar.time];
                switch length(ar.mult)
                    case 0
                        dir = [1, 1];
                    case 1
                        dir = ar.mult*[1, 1];
                    case 2
                        dir = ar.mult;
                    otherwise
                        error('adread.mult has too many values');
                end
                pulsetab(2:3, end-1) = ar.start  * dir;
                pulsetab(2:3, end) = ar.finish  * dir;
            end            
        end
    end
    
end

