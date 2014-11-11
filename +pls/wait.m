classdef wait < pls.pls_elem
    %classdef wait < pls_elem
    %   wait for a duration time at a location val*mult
    
    properties
        time;
        val;
        mult;
    end
    
    methods
        function wt = wait(varargin)
            wt = wt@pls.pls_elem(varargin{:});
        end
        
        function [pulsetab, mktab]=make_tab(wt)
            pulsetab = zeros(3, 0);
            mktab =  zeros(5, 0);
            if wt.time > 1e-11
                %fillpos = fillpos +(fillpos==size(pulsetab,2)); % are we filling the wait? if so, we don't want to fill like a ramp
                pulsetab(1, 1:2) = [wt.dt, wt.time]; %pinf.tbase*1e6/pinf.clk.
                if ~isempty(wt.mult)
                    pulsetab(2:3, end+(-1:0)) = repmat(wt.mult*wt.val(1:2)', 1, 2);
                else
                    pulsetab(2:3, end+(-1:0)) = repmat(wt.val(1:2)', 1, 2);
                end
            end
        end
    end
    
end

