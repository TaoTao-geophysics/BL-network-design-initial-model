function pltt1(m1,dc)
const1=0;const2=0;
ss3='BL2022.PRE';
icount=ss3(5:end-4);
np_down=1;size_marker_rs=5;size_marker_re=5;
rs_line=1.0;re_line=0.1;width_line=1;
font_name='default';
font_size=18;label_size=12;
fid=fopen(ss3);
while(~feof(fid))
    line=fgets(fid);
    if(length(line)>18&line(1:19)=='pole [1]/dipole [2]')
     iflag=str2num(line(33:40));
     rec_iflag=str2num(line(41:48));
    end
    if(length(line)>7&line(1:8)=='L-factor')
        cm=str2num(line(33:40));
    end
    if(length(line)>79&line(1:80)=='source coordinates in meters (3 for single pole, 6 for dipole, 1 set per line)..')
     if(iflag==1)
        rs=fscanf(fid,'%f%f%f%f',[4,inf]);
     else
        rs=fscanf(fid,'%f%f%f%f%f%f%f',[7,inf]);
     end
    end
    if(length(line)>58&line(1:59)=='single pole receiver coordinates in meters (1 set per line)')
      if(rec_iflag==2)
        re=fscanf(fid,'%f%f%f%f%f%f',[6,inf]);
      else
        re=fscanf(fid,'%f%f%f',[3,inf]);
      end
    end
    if(length(line)>21&line(1:22)=='grid coordinates in x:')
     x=fscanf(fid,'%f');
    end
    if(length(line)>21&line(1:22)=='grid coordinates in y:')
     y=fscanf(fid,'%f');
    end   
    if(length(line)>21&line(1:22)=='grid coordinates in z:')
     z=fscanf(fid,'%f');
    end
    if(length(line)>6&line(1:7)=='(Ohm*m)')
     model0=fscanf(fid,'%f');
    end
    if(length(line)>5&line(1:6)=='dike (')
     model=fscanf(fid,'%f%f%f%f%f%f%f%f',[8,inf]);
    end
end
fclose(fid);
re=re';rs=rs';
nsrc=size(rs,1);nrec=size(re,1);
model=model';
nm=size(model,1);

x=x+const1;y=y+const2;
xmin=min(x);xmax=max(x);
ymin=min(y);ymax=max(y);
zmin=0;zmax=max(z);
if(iflag==1)
    rsmx=rs(:,1)+const1; rsmy=rs(:,2)+const2;rsmz=rs(:,3);
    rsx=rsmx;rsy=rsmy;rsz=rsmz;
else
    rsmx=rs(:,1)+const1;rsmy=rs(:,2)+const2; rsmz=rs(:,3);
    rsnx=rs(:,4)+const1;rsny=rs(:,5)+const2;rsnz=rs(:,6);
    rsx=[rsmx;rsnx]; rsy=[rsmy;rsny];rsz=[rsmz;rsnz];
end
if(rec_iflag==1)
    recmx=re(:,1)+const1;recmy=re(:,2)+const2;recmz=re(:,3);
    recx=recmx;recy=recmy; recz=recmz;
else
    recmx=re(:,1)+const1;recmy=re(:,2)+const2;recmz=re(:,3);
    recnx=re(:,4)+const1;recny=re(:,5)+const2;recnz=re(:,6);
    recx=[recmx;recnx];recy=[recmy;recny];recz=[recmz;recnz];
end
rs(:,1)=rs(:,1)+const1;rs(:,2)=rs(:,2)+const2;    

%% 
ndec=30;
xc=x(1:end-1);yc=y(1:end-1);zc=z(1:end-1);
km=length(z)-1;im=length(x)-1;jm=length(y)-1;
for j=1:jm
    for i=1:im
        for k=1:km
            jj=k+(i-1)*km+(j-1)*im*km;
            if(dc==0)
                m11(j,i,k)=1/m1(jj);
                invm(jj)=1/m1(jj);
            else
                m11(j,i,k)=100*m1(jj);
            end
        end
    end
end
nx = length(x);ny = length(y);nz = length(z);

%%
figure(1)
ni=ceil(nx/2);
for j=1:jm
    for k=1:km
        app_res(j,k)=m11(j,ni,k);
    end
end

app_res= app_res';
if(dc==0)
    pcolor(yc,zc,log10(app_res))
end
hold on;
set(gca,'Ydir','reverse');
cmap=jet(); 
ncolor=80;cmap=jet(ncolor);cmap(ncolor-10:ncolor,:)=[];cmap(1:10,:)=[];
colormap(cmap);colorbar;A=min(log10(app_res));A=min(A);A1=max(log10(app_res));A1=max(A1);
h=colorbar;
shading flat
title(['x= ',num2str(x(ni)), ' m'],'fontsize',18);xlabel('Y position (m)','fontsize',18);ylabel('Z position (m)','fontsize',18);
zlabel('Z position (m)','fontsize',18);
a = get(h,'title');
if(dc==0)
    rhoscale=[1  2]; caxis(rhoscale);
    yticknum=rhoscale(1):2*(rhoscale(2)-rhoscale(1))/ndec:rhoscale(2);
    set(h,'YTick',yticknum); set(h,'YTickLabel',round(power(10,yticknum)));set(a,'String','老(次﹞m)');
elseif(dc==1)
    set(a,'String','灰(%)');
end


figure(2)
nj=ceil(ny/2);
for i=1:im
    for k=1:km
        app_res2(i,k)=m11(nj,i,k);
    end
end
app_res2= app_res2';
if(dc==0)
    pcolor(xc,zc,log10(app_res2))
end
set(gca,'Ydir','reverse');
cmap=jet();  
ncolor=80;cmap=jet(ncolor);cmap(ncolor-10:ncolor,:)=[];cmap(1:10,:)=[];colormap(cmap);
h1=colorbar;shading flat;
B=min(log10(app_res2));B=min(B);B1=max(log10(app_res2));B1=max(B1);
title(['y= ',num2str(y(nj)), ' m'],'fontsize',18);xlabel('X position (m)','fontsize',18);ylabel('Z position (m)','fontsize',18);
a = get(h1,'title');
if(dc==0)
    rhoscale=[1 2];
    caxis(rhoscale);
    yticknum=rhoscale(1):2*(rhoscale(2)-rhoscale(1))/ndec:rhoscale(2);
    set(h1,'YTick',yticknum);set(h1,'YTickLabel',round(power(10,yticknum)));set(a,'String','老(次﹞m)');
elseif(dc==1)
    set(a,'String','灰(%)');
end

figure(3)
nz=5;
for j=1:jm
    for i=1:im
        app_res3(j,i)=m11(j,i,nz);
    end
end
app_res3= app_res3;pcolor(xc,yc,log10(app_res3))
cmap=jet(); ncolor=80;cmap=jet(ncolor);cmap(ncolor-10:ncolor,:)=[];cmap(1:10,:)=[];colormap(cmap);
h1=colorbar;shading flat;
C=min(log10(app_res3));C=min(C);C1=max(log10(app_res3));C1=max(C1);
title(['z= ',num2str(z(nz)),' m'],'fontsize',20);xlabel('X position (m)','fontsize',18);ylabel('Y position (m)','fontsize',18);
a = get(h1,'title');
if(dc==0)
    rhoscale=[1  2];
    caxis(rhoscale);
    yticknum=rhoscale(1):2*(rhoscale(2)-rhoscale(1))/ndec:rhoscale(2);
    set(h1,'YTick',yticknum);set(h1,'YTickLabel',round(power(10,yticknum)));set(a,'String','老(次﹞m)');
end

figure(4)
depth=1;
nz = length(z);
[X,Y,Z] = meshgrid(xc,yc,zc);
m13=log10(m11);
   slice(X,Y,Z,m13,xc(ceil(nx/2)),yc(ceil(ny/2)),zc(ceil(nz/2)));
    set(gca,'Zdir','reverse');
    axis tight 
    shading flat
    D=min(log10(invm));D1=max(log10(invm));
    cmap=jet();ncolor=80; cmap=jet(ncolor);cmap(ncolor-10:ncolor,:)=[]; cmap(1:10,:)=[];colormap(cmap);
    h1=colorbar;
    xlabel('X position (m)','fontsize',14); ylabel('Y position (m)','fontsize',14);zlabel('Z position (m)','fontsize',14); 
    colormap(jet);    
    a = get(h,'title');
    set(a,'String','老(次﹞m)');
    view(-44,9); 
a = get(h1,'title');
if(dc==0)
    rhoscale=[D D1];
    caxis(rhoscale);
    yticknum=rhoscale(1):2*(rhoscale(2)-rhoscale(1))/ndec:rhoscale(2);
    set(h1,'YTick',yticknum);set(h1,'YTickLabel',round(power(10,yticknum)));set(a,'String','老(次﹞m)');
end