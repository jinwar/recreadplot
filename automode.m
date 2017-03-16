

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

    save(['autostruct_' codename], 'autostruct')
    
    
  