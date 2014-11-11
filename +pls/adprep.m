classdef adprep < pls.pls_elem
    %classdef adprep < pls_elem
    %   adpred: ramp from start to finish in time
    
    properties
        time = .5;
        start = 1;;
        finish =5;
        mult = 1;
    end
    
    methods
        function ap = adprep(varargin)
            ap =ap@pls.pls_elem(varargin{:});
        end
        
        function [pulsetab, mktab]=make_tab(ap)
            pulsetab = zeros(3, 0);
            mktab =  zeros(5, 0);
            if ap.time > 1e-11
                pulsetab(1, end+(1:2)) = [ap.dt, ap.time];
                switch length(ap.mult)
                    case 0
                        dir = [1, 1];
                    case 1
                        dir = ap.mult*[1, 1];
                    case 2
                        dir = ap.mult;
                    otherwise
                        error('adprep.mult has too many values')
                end
                   
                pulsetab(2:3, end-1) = ap.start  * dir;
                pulsetab(2:3, end) = ap.finish  * dir;
            end
            
        end
    end
    
end

