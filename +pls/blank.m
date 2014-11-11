classdef blank < pls.pls_elem
    %classdef pls_blank < pls_elem
    %   represents a blank pulse element. to be filled in with dictionaries
    %   etc. just requires a name
    
    properties
    end
    
    methods
        function bk = blank(nm)
            bk = bk@pls.pls_elem();
            if isa(nm,'function_handle')
                nm = ['@',func2str(nm)];
            end
            bk.name = nm;
        end
        
        function [pulsetab, mktab]=make_tab(~)
            pulsetab = zeros(3, 0);
            mktab =  zeros(5, 0);
        end
    end
    
end

