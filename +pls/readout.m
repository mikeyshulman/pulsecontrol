classdef readout < pls.pls_elem
    %classdef readout < pls_elem
    %   represents the readout of a qubit
    %   has properties
    %       time: duration of readou
    %       st_dly: the start delay (acquire data starting this long after
    %           beginning)
    %       ed_dly: end delay. opposite of start delay
    %       flag: to flag certain readouts
    
    properties
        time = 1; 
        st_dly = 0;
        ed_dly= 0;
        meas_pt = [0 0];
        flag;
    end
    
    methods
        function rd = readout(varargin)
            rd =rd@pls.pls_elem(varargin{:});
        end
        
        function [pulsetab, mktab] = make_tab(rd)
            pulsetab = zeros(3, 0);
            mktab =  zeros(5, 0);
            if isempty(rd.meas_pt)
                rd.meas_pt = [0 0];
            end
            pulsetab(1, end+(1:2)) = [rd.dt, rd.time]; %pinf.tbase*1e6/pinf.clk.
            pulsetab(2:3, end-1) = rd.meas_pt;
            pulsetab(2:3, end) = rd.meas_pt;
            mktab(:, 1) = [rd.st_dly; 0; 0; 0; [rd.time-rd.st_dly-rd.ed_dly]];
        end
    end
    
end

