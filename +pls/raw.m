classdef raw < pls.pls_elem
    %classdef pls_raw < pls_elem
    %   add raw elements to the pulsetab
    %   has properties time and val
    %   will return values:
    %       pulsetab = [rw.time;rw.val];
    %       mktab =  zeros(5, 0);
    
    properties
        time;
        val;
    end
    
    methods
        function rw = raw(varargin)
           rw = rw@pls.pls_elem(varargin);
           rw.name = 'raw';
        end
        
        function [pulsetab, mktab]=make_tab(rw)
            pulsetab = [rw.time;rw.val];
            mktab =  zeros(5, 0);
        end
    end
    
end

