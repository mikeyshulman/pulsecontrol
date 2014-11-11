%% change this to find a path to the plsdata file and plsdata.grpdir
%% careful, this clears workspace
clear all;
clear all global
b = instrfind;
delete(b(:));
%pdata_file = 'C:\DropBox\Dropbox\pulsecontrol3\files\plsdata_2012_08_22'
%gdir  = 'C:\DropBox\Dropbox\pulsecontrol3\files\groups\'
pdata_file = '/Users/mikey/Dropbox/pulsecontrol3/files/plsdata_2012_08_22';
gdir ='/Users/mikey/Dropbox/pulsecontrol3/files/groups/';
%gdir = '/Users/michaelshulman/Documents/MATLAB/';

%% this will load plsdata, change it to be compatible with new stuff

plsdata2=load(pdata_file); 
%plsdata2 = load('z:/qDots/awg_pulses/plsdata_2012_08_22.mat');
plsdata2 = plsdata2.plsdata;
plsdata2.pulses = plsdata2.pulses(14:16);
global plsdata;
for j = 1:length(plsdata2.pulses)
    s = struct();
    pp=plsdata2.pulses(j).pardef;
    pardef = struct();
    for kk = 1:size(pp,1)
        pardef(kk).elem_num = pp(kk,1);
        if pp(kk,2)<0
            pardef(kk).par = 'time';
        else
            pardef(kk).par = 'val';
        end
        pardef(kk).ind = abs(pp(kk,2));
    end
    s.pardef = pardef;
    s.trafofn = func2str(plsdata2.pulses(j).trafofn);
    s.fill.elem = [];s.fill.time = [];
    ee = {plsdata2.pulses(j).data.type};
    for jj = length(ee):-1:1
       tmp(jj) = pls.blank(ee{jj}); 
    end
    s.elems = tmp;
    plsdata.pulses(j) = pls.pls_pls(s);
end

plsdata.grpdir = gdir;
plsdata.datafile = plsdata2.datafile;
plsdata.tbase = plsdata2.tbase;


%% now make some pulsegroups
clear s;
s.name = 'testpg';
s.pulses = 2;
s.params = {[4 .2 .3]};
s.chan = [3 4];
s.varpar{1} =struct('param',2,'val',(1:100)*1e-3);
%s.dict = {'right'};
s.dict = {struct('prep','@adprep','read','@adread'),'left'};
clear pg
pg = pls_plsgroup(s);

s.chan = [4 5];
s.params{1}(2) = .4;
pg2 = pls_plsgroup(s);

s.params{1}(2) = .23;
s.chan = [5 6];
pg3 = pls_plsgroup(s);

% clear s;
% s.groups = {pg,pg2};
% cg = sm_combo_group(s);

%% now make some awgs
% note, the awg waveform dirs are assumed to be
%plsdata.grpdir/tmp/awg1, or /awg2.
% make these directories if they don't exist
% also, populate the variable awg_inst
%awg_inst = visa('ni','tcpip::140.247.189.8::INSTR');
awg_inst = [plsdata.grpdir,'tmp/fake_awg1'];
awg_inst2 = [plsdata.grpdir,'tmp/fake_awg2'];
clear s
s.wf_dir= [plsdata.grpdir,'tmp/awg1/'];
s.trig_pls.name = 'trig_awg1';
s.trig_pls.len = 1000;
s.trig_pls.chan = 2;
s.trig_pls.marker = 1;
awg = sm_awg(s);
s.wf_dir = [plsdata.grpdir, 'tmp/awg2/'];
s.trig_pls.name = 'trig_awg2';
s.slave = 1;
awg2 = sm_awg(s);

chans = struct();
for j =1:8
    if j <5
        chans(j).awg = 1;
       chans(j).channel = j; 
    else
        chans(j).awg = 2;
        chans(j).channel = j-4;
    end
    chans(j).scale =10;
    chans(j).offset =0;
end

clear s;
s.awg = awg;
s.awg(2) = awg2;
s.chans = chans;
s.name = 'awgdata';
global awgdata;
awgdata = sm_awg_data(s);


awgdata.queue{1} = pg;
awgdata.queue{2} = pg2;%cg;
awgdata.queue{3} = pg3;
try
    awgdata.awg(1).inst= awg_inst;
    awgdata.awg(2).inst = awg_inst2;
    fopen(awgdata.awg(1).inst);
    fopen(awgdata.awg(2).inst);
end

%%
%plsgrp,ind, clk, tbase, time
% now everything is set up. try the following low level commands:
foo=awgdata.queue{1}.make(1:100,1e9,plsdata.tbase,[]);
% and see that foo has the wfs packed nicely. 
% awgdata.sync()
% awgdata.write_seq


