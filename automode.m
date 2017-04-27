

function [autostruct] = automode(xl, yl, freq_band, comp);




field1 ='xlims';
field2 = 'ylims';
field3 = 'filter';
field4 = 'component';
field5 = 'description';


    prompt = 'Give a short description of this plot:';
    desc = input(prompt, 's');
    
    prompt = 'Give a save name for these params :' ;
    codename = input(prompt, 's');
    autostruct = struct(field1, xl, field2, yl, field3, freq_band, field4, comp, field5, desc);

    filename = ['autostruct_' codename '.mat'];
    
    if exist(filename, 'file') ~=0;
        prompt = 'You are about to overwrite a file. Continue? [y/N]';
        x = input(prompt, 's');
        if strcmp(x, 'y') == 1 | strcmp(x, 'Y') ==1 | strcmp(x, 'yes') ==1 | strcmp(x, 'Yes') ==1;
            save(['autostruct_' codename], 'autostruct')
        else
            while exist(filename, 'file') ~=0
            prompt = 'Pick a new save name for these params :' ;
            codename = input(prompt, 's');
            filename = ['autostruct_' codename '.mat'];
            end
        end
    end   
    save(['autostruct_' codename], 'autostruct')
    
    
  