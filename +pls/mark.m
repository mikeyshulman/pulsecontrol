classdef mark < pls.pls_elem
    %classdef pls_mark < pls_elem
    %   at raw marktab data;
    % e.g. add a 5 element vector
    %   first element = start time of marker
    %   next 4 = duration of marker for each channel
    
    properties
        time;
        val;
    end
    
    methods
        function rw = pls_mark(varargin)
            rw.name = 'mark';
        end
        
        function [pulsetab, mktab]=make_tab(mk)
            pulsetab = zeros(3,0);
            mktab =  mk.data.time';
        end
    end
    
end

