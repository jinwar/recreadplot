

function [xlims, ylims, filter, component] = pullautomode(name);

filename = ['autostruct_' name '.mat'];


if exist(filename, 'file') ==0;
    warning([filename ' does not exist'])
    prompt = 'What is the structure codename? ' ;
    
    name = input(prompt, 's');
    filename = ['autostruct_' name '.mat'];
end


load(filename)

xlims = autostruct.xlims;
ylims = autostruct.ylims;
filter = autostruct.filter;
component = autostruct.component;