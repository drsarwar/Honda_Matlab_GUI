%Description: Live plots 2d C values for 4x4 sensor for all 16 taxels
%               This has been updated as of Sep 19, 2018 to be less latent
%               than the previous version provided prior to v1.0.0
%Author: Claire Preston
%Date: Sep 19, 2018
%Version: sview2d 1.0.0


%%%%Clear serial port variables, workspace variables
delete(instrfindall);
clear all;close all;
clc;

%%%Open Serial COnnection
%%USER: SPECIFY YOUR SERIAL PORT
SerialPort='/dev/cu.usbmodem14201';
s=serial(SerialPort);
fopen(s);

%%USER: Specify number of values to display/store on each plot
numvalsp=40;
%%USER: Set y range to plot
ylim=[-0.06 0.06];

%
p1 = 5;
p2 = 0;
p3 = 11;
p4 = 10;
p5 = 9;
p6 = 8;
p7 = 7;
p8 = 6;
left = 4;
right = 2;
top = 1;
bottom = 3;
prox = 12;
blank = 15; % any unused number from 0 to 15
%}
%{
p1 = 7;
p2 = 11;
p3 = 10;
p4 = 9;
p5 = 8;
p6 = 5;
p7 = 4;
p8 = 6;
left = 14;
right = 13;
top = 12;
bottom = 15;
prox = 1;
blank = 0; % any unused number from 0 to 15
%}

%%%Maps matrix locations according to board used
%%USER: Uncomment the board version you are using
%matmap=1+ [6 4 5 7; 2 0 1 3; 10 8 9 11; 14 12 13 15]; %Board V1
%matmap=1+[0 1 2 3; 4 5 6 7; 8 9 10 11; 12 13 14 15]; %Board V2
%matmap=1+[3 2 0 1; 7 6 4 5; 15 14 12 13; 11 10 8 9]; %Board V3
%matmap=1+[2 3 1 0; 6 7 5 4; 14 15 13 12; 10 11 9 8]; %Board V4
%matmap=1+[0 1 3 2; 4 5 7 6; 12 13 15 14; 8 9 11 10]; %Board V5
%matmap=1+[3 1 0 2; 7 5 4 6; 15 13 12 14; 11 9 8 10]; %Board V6
%matmap= [1 12 8 4;11 15 13 7;10 16 14 5;2 9 6 3]; %MCDC_FDC
%matmap= [1 12 8 4;11 15 2 7;10 16 14 5;1 9 6 3]; %MCDC_FDC_shearx,sheary,decoupled pressure,proximity
%matmap = 1+[left prox;bottom right]; %pizza sensors
matmap = 1+[prox bottom;left blank]; %pizza sensors
matmap1=matmap(:);

%%%Create cell array to store values for each taxel
vals=cell(16,1);
noise=cell(16,1);
mean=cell(16,1);
for i=1:16
    vals{i,1}=zeros(numvalsp,1);
end
%%%%Creates figure for 4x4 plots
figure(1);
ha=[];%subplot handle array
hl=[];%line plot array
for i=1:4
    ha(i)=subplot(2,2,i);
    hl(i)=line(nan,nan);
    set(ha(i),'YLim',ylim);
    set(hl(i),'linewidth',3)%MSS added for linewidth 
    set(ha(i),'XLim',[0 numvalsp]);
    set(ha(i),'DrawMode','fast');
    set(ha(i),'NextPlot','replacechildren');
end
set(ha(3),'YLim', [-0.5 .7]); % different ylim for normal strain
set(ha(1),'YLim', [7 12]); % different ylim for proximity
set(ha(2), 'YLim', [-0.06, 0.06],'XLim', [-0.06, 0.06], 'XMinorgrid', 'on', 'YMinorgrid', 'on'); % different limits for shear angle
drawnow;

%%%Read in values and plot
%%USER: Ensure figure is active and press any key to terminate
loc=1;%initialize location variable to taxel address 1
count=0;%loop count to ingnore initial values
x_C1 = 0;
x_C2 = 0;
y_C1 = 0;
y_C2 = 0;
x_C1_prime = 0;
x_C2_prime = 0;
y_C1_prime = 0;
y_C2_prime = 0;
x_pos = 0;
y_pos = 0;
rho = 0;
theta = 0;
global KEY_IS_PRESSED
KEY_IS_PRESSED=0;
gcf
set(gcf,'KeyPressFcn',@myKeyPressFcn); %Set keypress listener to figure
while ~KEY_IS_PRESSED
    line=fgetl(s); %get next line
    %store in vals{} 
    if line(1)=='('
        loc=bin2dec(line(2:5));
        val=str2num(line(7:12));
        if (loc==left)
            count = count + 1; %update loop count
        end
        if (count > 10 && count <= 15)
            % left pad
            if (loc==left)
                x_C2 = x_C2 + val;
            % right
            elseif (loc==right)
                x_C1 = x_C1 + val;
            % top
            elseif (loc==top)
                y_C1 = y_C1 + val;
            % bottom
            elseif (loc==bottom)
                y_C2 = y_C2 + val;
            end
        elseif (count==16 && loc==left) % take average of baseline capacitance
            x_C1 = x_C1/5;
            x_C2 = x_C2/5;
            y_C1 = y_C1/5;
            y_C2 = y_C2/5;
        elseif (count > 16)
            %left
            % update x_C1 and calculate normal strain
            if(loc==left)
                x_C2_prime = val;
                val = (x_C1_prime - x_C1 + x_C2_prime - x_C2 + y_C1_prime - y_C1 + y_C2_prime - y_C2)/(x_C1_prime + x_C2_prime + y_C1_prime + y_C2_prime); % decoupled pressure
            %right
            elseif(loc==right)
                loc = bottom;
                x_C1_prime = val;
                x_pos = (x_C2*x_C1_prime-x_C1*x_C2_prime)/(x_C1_prime + x_C2_prime);
                val = x_pos;
            %top
            elseif(loc==top)
                y_C1_prime = val;
                %val = (x_C1_prime - x_C1 + x_C2_prime - x_C2 + y_C1_prime - y_C1 + y_C2_prime - y_C2)/(x_C1_prime + x_C2_prime + y_C1_prime + y_C2_prime); % decoupled pressure
            %bottom
            elseif(loc==bottom)
                loc = right;
                y_C2_prime = val;
                y_pos = (y_C2*y_C1_prime-y_C1*y_C2_prime)/(y_C1_prime + y_C2_prime);
                val = y_pos;
                %rho = linspace(0,(x_pos^2 + y_pos^2)^0.5,10);
                %theta = ones([1,10])*atan2(y_pos,x_pos);
            end
        end
        vals{loc+1}=[val;vals{loc+1}(1:numvalsp-1)];
        %noise{loc+1}=max(vals{loc+1}(1:numvalsp-1)) - min(vals{loc+1}(1:numvalsp-1));
        %mean{loc+1}=mean2(vals{loc+1}(1:numvalsp-1));
    end
    %match with correct address on plot
    tem=matmap';
    tem=tem(:);
    i=find(tem==(loc+1));
    if (i == 2)
        xarray = linspace(0,1,10)*x_pos;
        yarray = linspace(0,1,10)*y_pos;
        set(hl(i), 'XData', xarray, 'YData', yarray, 'linewidth', 4);
    else
        set(hl(i), 'XData',1:numvalsp,'YData',vals{loc+1});
    end
    %draw after all 16 are updated
    %saves on latency rather than plotting every time 1 is updated
    if(i==3)
        drawnow;
    end
end
disp('loop ended')

%Close serial connection
fclose(s);
delete(s);
    
