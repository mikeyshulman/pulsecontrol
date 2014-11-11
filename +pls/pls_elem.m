classdef pls_elem < matlab.mixin.Heterogeneous & handle & matlab.mixin.Copyable & dynamicprops
    %classdef pls_elem < matlab.mixin.Heterogeneous &  matlab.mixin.Copyable & handle
    %   pulse element class. has properties name and data;
    %   methods: constructor, to_tab
    %   all classes that derive from this must implement a function
    %   make_tab. the to_tab method allows for vectorized operations, i.e.
    %   a member of pls_elem can be an array, and still have predictable
    %   behavior. This is done by having the to_tab method sealed so that
    %   theere is predicatable behavior across heterogeneous objects
    %   the Copyable class allows shallow and deep copies to be made, e.g.
    %   b = a is a shallow copy, b = copy(a) is a deep copy. 
    %   this will allow for example, for dictionaries to either point to
    %   commond references or to copy them without modifying the old copy
    
    properties
        name;
%        dt = -1e-9;
    end
    properties (Constant)
       dt = 1e-9; 
    end
    
    methods
        function pe = pls_elem(nm,data)
            if exist('nm','var')&& ~isempty(nm)
                pe.name = nm;
            end
            if exist('data','var') && ~isempty(data)
                pe.data = data;
            end
        end
    end
    
    methods (Sealed = true)
        function [tab,mktab] = to_tab(pe,varargin)
            mktab = zeros(5,0);
            tab = zeros(3, 0);
            if isempty(pe)
                return
            end
            for j = 1:length(pe)
                if length(properties(pe)) > length(properties('pls_elem'))
                    [t,m] = pe(j).make_tab(varargin{:});
                    tab= [tab,t];%#ok<AGROW>
                    mktab = [mktab,m];%#ok<AGROW>
                end
            end
        end
        
%         function disp(pe)
%             switch length(pe)
%                 case 0
%                     disp('empty pulse element');
%                 case 1
%                     fprintf('instance of class %s, named %s\n',class(pe(1)),pe(1).name);
%                     disp(pe.data);
%                 otherwise
%                     fprintf('pulse elem array of length %i\n\n',length(pe));
%                     fprintf('first element is:\n');
%                     disp(pe(1))
%             end
%         end
    end
    
    methods (Static)
        function wf_data = tabtowf(tab_data,clk,tbase,pulse_inds)
            dt=1e-11;
            if isempty(clk)
               clk = 1e9; 
            end
            %looks at pack_data(pulse_inds).tab and marktab and makes wf
            for jj = pulse_inds
                if isempty(tab_data(jj).pulsetab)%||isempty(tab_data(jj).marktab)
                    error('pulse number %i not filled into table\n',jj)
                end
                
                pulsetab=tab_data.pulsetab;
                nchan = size(pulsetab, 1)-1;
                npoints = round(max(pulsetab(1, :)) * tbase * clk/1e9);
                
                data = zeros(nchan, npoints+1);
                ttime = linspace(pulsetab(1, 1), pulsetab(1, end), npoints+1);
                
                %            avg = zeros(nchan, 1);
                for j = 1:nchan
                    for i = 2:size(pulsetab, 2)
                        mask = ttime >= pulsetab(1, i-1)-dt & ttime <= pulsetab(1, i)+dt;
                        % added small shifts to mitigate rounding errors 08/04/09. Never seen to matter.
                        % below makes writes the pulse into data using lines to connect the
                        % corners defined in pulstab
                        if 0
                            data(j, mask) = (-pulsetab(j+1, i-1) * (ttime(mask) - pulsetab(1, i)) ...
                                + pulsetab(j+1, i) * (ttime(mask) - pulsetab(1, i-1)))./...
                                (pulsetab(1, i) -  pulsetab(1, i-1));
                        else
                            data(j, mask) = ((-pulsetab(j+1, i-1) + pulsetab(j+1,i)) * ttime(mask) + ...
                                pulsetab(j+1,i-1) * pulsetab(1, i) - pulsetab(j+1,i) * pulsetab(1, i-1))./...
                                (pulsetab(1, i) -  pulsetab(1, i-1));
                        end
                        
                    end
                end
                % lets pulses be defined with functions (eg. sin, cos) instead of
                % just lines
                %             for i = 1:length(pulseinf.pulsefn)
                %                 mask = ttime > pulseinf.pulsefn(i).t(1) & ttime <= pulseinf.pulsefn(i).t(2);
                %                 for j = 1:nchan
                %                     data(j, mask) = pulseinf.pulsefn(i).fn{j}(ttime(mask)-pulseinf.pulsefn(i).t(1), pulseinf.pulsefn(i).args{j, :}) - avg(j);
                %                 end
                %             end
                
                data(:, end) = [];
                marker = zeros(nchan, npoints, 'uint8');
                
                % extend marktab to be right dimensions
                mktab = tab_data(jj).marktab;
                mktab(end+1:2*nchan+1,:) = 0;
                
                for i = 1:size(mktab, 2)
                    for j = 1:nchan
                        for k = 1:2;
                            mask = ttime(1:end-1) >= mktab(1, i) - dt &...
                                ttime(1:end-1) < mktab(1, i) + mktab(j*2+k-1, i)-2e-11;
                            marker(j, mask) = bitor(marker(j, mask), k);
                        end
                    end
                end
                wf_data(jj).marker = marker;
                wf_data(jj).wf = data;
                %tab_data(jj).marker = marker;
                %tab_data(jj).wf = data;%+vc;
            end
        end
    end
    
end

