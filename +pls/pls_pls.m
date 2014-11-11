classdef pls_pls < matlab.mixin.Copyable & handle
    %classdef pls_pls < matlab.mixin.Copyable & handle
    %   represents a pulse template. 
    %   has properties
    %       elems: array of class pls.pls_elem or derived classes
    %       name:
    %       pardef: struct with fields elem_num, par, ind
    %       param_names
    %       trafofn: string, fn to turn params into pardef
    %       fill: struct with fields elem, time
    %       derives from copyable. allows for pulses to be 
    %           copied from plsdata without modifying plsdata;
    
    properties
        elems;
        name;
        trafofn = '@(x) x';
        pardef = struct('elem_num',{},'par',{},'ind',{});
        param_names={};
        fill=struct('elem',{},'time',{});;
    end
    
    methods    
        function p = pls_pls(stct)
            if ~isfield(stct,'elems')
               error('no elems found in pulse. invalid'); 
            end
            switch class(stct.elems)
                case {'pls.pls_elem','pls_blank'}
                    tmp = stct.elems;
                case 'cell'
                    tmp(length(stct.elems))=pls.pls_elem();
                    for j = 1:length(tmp)
                        if isa(stct.elems{j},'pls.pls_elem')
                            tmp(j) = stct.elems{j};
                        elseif isa(stct.elems{j},'pls')
                            tmp(j) = stct.elems{j}.to_elem;
                        elseif ischar(stct.elems{j})
                            tmp(j) = pls_blank(['@',stct.elems{j}]);
                        else
                            error('cannot turn a %s into a pls.pls_elem',class(stct.elems{j}));
                        end
                    end
                otherwise
                    error('known elems type of class %s',class(stct.elems))
            end
            stct.elems = tmp;
            fn = fieldnames(stct);
            pr = properties('pls.pls_pls');
            fn = intersect(fn,pr);
            for j = 1:length(fn)
                p.(fn{j}) = stct.(fn{j});
            end
          %  pls.make_backward_compatible();
            if isa(p.trafofn,'function_handle');
                p.trafofn = func2str(p.trafofn);
            end
            if length(p.param_names) < length(p.pardef)
                warning('param names doesn''t have enough entries. this will be confusing...');
            end
            for j = 1:length(p.pardef)
               if isempty(p.pardef(j).ind) && ~isempty(p.pardef(j).elem_num)
                  p.pardef(j).ind = 1; 
               end
            end
        end
        
        function out =to_tab(pulse)
            pulsetab = zeros(3, 0);
            mktab =  zeros(5, 0);
            fillpos =[];
            readout = [];
            readpos =[];
            if ~isempty(pulse.fill)&&~isempty(pulse.fill.elem)
               fill_1 = pulse.fill.elem;
            else
                fill_1 = 0;
            end
            fill_2 = [];
            for j = 1:length(pulse.elems)
                if isa(pulse.elems(j),'pls_fill')
                    fill_2 = [fill_2,j];
                end
            end
            
            if fill_1 && ~isempty(fill_2)
               error('fill_elem given and found pls_fill element'); 
            end
            if length(fill_2)>1
               error('two fills found'); 
            end
            if fill_1
                filltime = pulse.fill.time;
                fillelem = pulse.fill.elem;
            else
                filltime = pulse.elems(fill_2).time;
                fillelem = fill_2;
            end
            
            for j = 1:length(pulse.elems)
                if j==fillelem
                   fillpos = size(pulsetab,2);
                   fillmarkpos = size(mktab,2);
                   if isa(pulse.elems(j),'pls_wait') || isa(pulse.elems(j),'pls_reload')
                      fillpos = fillpos+1; 
                   end
                end
                [t,mt]= pulse.elems(j).to_tab;
                if ~isempty(pulsetab)
                    t(1,:) = t(1,:)+pulsetab(1,end)+pls.pls_elem.dt;
                end
                if ~isempty(mktab)    
                    mt(1,:) = mt(1,:)+mktab(1,end) +pls.pls_elem.dt;
                end
                pulsetab = [pulsetab,t];
                mktab = [mktab,mt];
            end
            if ~isempty(fillpos)
                filltime = filltime - pulsetab(1, end);
                if filltime < 0
                    disp(pulsetab);
                    error('Pulse too long by %g (target %g).',-filltime,filltime+pulsetab(1,end));
                end
                pulsetab(1, fillpos+1:end) = pulsetab(1, fillpos+1:end) + filltime;
                if ~isempty(readpos)
                    readout(readpos > fillpos, 2) = readout(readpos > fillpos, 2) + filltime;
                end
                mktab(1, fillmarkpos+1:end) = mktab(1, fillmarkpos+1:end) + filltime;
            end
            out.pulsetab = pulsetab;
            out.marktab = mktab;
            out.readout = readout;
        end
        
        function changedout = apply_dict(pulse,pd)
            % If pd is a cell array, apply each dictionary in sequence.  This allows
            % for some *neat* effects. :p
            if iscell(pd)
                changedout = 0;
                while true
                    changed = false;
                    for i = 1:length(pd)
                        c2 = pulse.apply_dict(pd{i});
                        changed = changed || c2;
                    end
                    changedout = changed | c2;
                    if ~changed
                        break
                    end
                end
                return;
            end
            
            changed = true;
            changedout=false;
            if isstruct(pd)
               pdtmp = pls_dict('tmp',pd);
            else
                pdtmp = copy(pd);
            end
            while changed
                changed=false;
                for i=1:length(pulse.elems)
                    if ~changed && isa(pulse.elems(i),'pls_blank') && pulse.elems(i).name(1)=='@'
                        if isprop(pdtmp,pulse.elems(i).name(2:end))
                            nels=(pdtmp.(pulse.elems(i).name(2:end)));
                            if ischar(nels)
                               nels = pls_blank(nels); 
                            end
                            template=copy(pulse.elems(i));
                            %ot = ~isnan(template.time);
                            %ov = ~isnan(template.val);
                            for j=1:length(nels)
                                fn = setdiff(properties(nels(j)),properties('pls.pls_elem'));
                                for k = 1:length(fn)
                                    if  ~isprop('pls.pls_elem',fn{k}) && isprop(template,fn{k}) ...
                                            && all(~isempty(template.(fn{k}))) && all(~isnan(template.(fn{k})))
                                        nels(j).(fn{k}) = template.(fn{k});
                                    end
                                end
                            end
                            pulse.elems = [pulse.elems(1:i-1), nels, pulse.elems(i+1:end)];
                            changed=1;
                            changedout=1;
                            if ~isempty(pulse.pardef)
                                pulse.pardef = bump_pardef(pulse.pardef,i,length(nels)-1);
                            end
                            break;
                            
                        end %isfield
                    end
                end
            end 
        end
    end
    
    methods (Access = protected)
        function cpObj = copyElement(obj)
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            cpObj.elems = copy(obj.elems);
        end
    end
    
    %%%%%
    %%%%%
    methods (Static)
        function new_pardef = make_pardef_compatible(pardef)
            if isstruct(pardef)
                new_pardef = pardef;
                return
            elseif isnumeric(pardef)
                new_pardef = struct();
                for kk = 1:size(pardef,1)
                    new_pardef(kk).elem_num = pardef(kk,1);
                    if pardef(kk,2)<0
                        new_pardef(kk).par = 'time';
                    else
                        new_pardef(kk).par = 'val';
                    end
                    new_pardef(kk).ind = abs(smp.pardef(kk,2));
                end
            else
                error('pardef format not recognized');
            end
        end % end function
    end
    
end

function pardef = bump_pardef(pardef, from, by)
tobump=find([pardef.elem_num] > from);
%this for loop is faster and easier to read than the vecotrized version
for j = tobump
   pardef(j).elem_num = pardef(j).elem_num+by; 
end
%new_nums = num2cell([pardef(tobump).elem_num]+by);
%[pardef(tobump).elem_num]=deal(new_nums{:});
end

