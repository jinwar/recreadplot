function plot_raypaths(raydist,raydepth,linecolor)

figure(93); hold on
    [cx,cy]=circle(6371);
    plot(cx,cy,'k');
    [cx,cy]=circle(3480);
    plot(cx,cy,'color',[0.5 0.5 0.5],'linewidth',2);
    [cx,cy]=circle(1220);
    plot(cx,cy,'color',[0.5 0.5 0.5],'linewidth',2);
    axis off;
    axis equal;
    for ii=1:length(raydist)
        cx=(6371-raydepth(ii)).*sin(raydist(ii)/180*pi);
        cy=(6371-raydepth(ii)).*cos(raydist(ii)/180*pi);
        h(ii)=plot(cx,cy,'Color',linecolor,'LineWidth',2.5);
        if ii == 1
        plot(cx,cy,'k*');
        elseif ii == length(raydist)
        plot(cx,cy,'kv','MarkerFaceColor','k');
        end
    end;
return

function [cx,cy]=circle(r)
    ang=0:0.002:pi*2;
    cx=sin(ang)*r;
    cy=cos(ang)*r;
return;

