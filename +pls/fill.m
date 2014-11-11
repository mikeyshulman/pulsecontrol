classdef fill < pls.pls_elem
    %classdef pls_fill < pls_elem
    %   fill the next element of the pulse to stretch the pulse to have
    %   total length of property time.
    
    properties
        time;
    end
    
    methods
        function rd = fill(varargin)
            rd =rd@pls.pls_elem(varargin{:});
        end
        
        function [pulsetab, mktab]=make_tab(rl)
            mktab = zeros(5,0);
            pulsetab = zeros(3, 0);
        end
    end
    
end

