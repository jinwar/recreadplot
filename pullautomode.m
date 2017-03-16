

function [xlims, ylims, filter, component] = pullautomode(name);

filename = ['autostruct_' name];

load(filename)

xlims = autostruct.xlims;
ylims = autostruct.ylims;
filter = autostruct.filter;
component = autostruct.component;