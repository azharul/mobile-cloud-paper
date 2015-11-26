clc
clear all
close all


%% This is a mobile cloud offloading framework simulation. The user have to 
% input two Images and set the network parameters. Then the program will 
% decide whether it should offload or not, and calculate time required to 
% execute the app in the cloud


%% two images to compare

% NOTE: to change one input file, you have to change both "pic1" variable  
% name and name of file in the directory in the variable "xx". Same for
% pic2
pic1 = imread('flower.jpg');  
xx=dir('D:\study\Spring 15\EE 6953 independent study\mobile cloud computing\my paper\flower.jpg');
filesize1=xx.bytes;
pic2 = imread('flower 2.jpg'); 
yy=dir('D:\study\Spring 15\EE 6953 independent study\mobile cloud computing\my paper\flower 7.jpg');
filesize2=yy.bytes;
totalsize=filesize1+filesize2;
[x1,y1,z1]=size(pic1);
[x2,y2,z2]=size(pic2);

if(z1==1)      
    ; 
else
    pic1 = rgb2gray(pic1); 
end
[x2,y2,z2] = size(pic2); 
if(z2==1)     
    ; 
else
    pic2 = rgb2gray(pic2); 
end
edge_det_pic1 = edge(pic1,'canny');
edge_det_pic2 = edge(pic2,'canny');
iter=x1*y1+x2*y2;

%% loading the fuzzy logic and taking inputs 
fismat=readfis('my_paper');

% bw= represents the available bandwidth in the network,
% 0=smallest bw, 1=largest bw
disp('Bandwidth represents the data rate of a communication channel.');
disp('It is the amount of data that can be transmitted per second.');
bw=input('please enter available BW between 0.01-1(0.01=smallest, 1=largest): ');
if (bw>1) || (bw<0)
   bw=input('Wrong input! please enter available BW between 0.01-1(0.01=smallest, 1=largest):');
end

% device= represents the energy level of the mobile device
% 0=lowest energy, 100=highest energy
disp('The energy in your mobile device, which generally ranges between 0 to 100.')
device=input('please enter device energy between 0-100(0=lowest, 100=highest):');
if (device>100) || (device<0)
   device=input('Wrong input! please enter device energy between 0-100(0=lowest, 100=highest):');
elseif(device==0)
        disp('device is dead, please recharge!!!');
end

% cost= represents the energy required to execute the app
% 0=smallest cost, 1=largest cost
% assuming cost is proportional to no of iterations, and max no of
% iterations 50,000,000=( pixel size of img 1+pixel size of img 2)(
cost=iter/50000000; 

 % ratio of Intel XEOn processor and ARm Cortex A7 processor 
 % clock speed. We assume that all performace
 % characteristics will be proportional to this ratio
 XEON_ARM=2; 
 
% assuming execution time per iteration in ARM processor is 1ns
l_arm=iter*1e-9;

% gaussian distribution to select network latency
y=25*randn(1000,1)+80;
figure;histfit(y), title('gaussian distribution to select network latency'),
xlabel('latency(in ns)')

% selecting a random data from the gaussian distribution to calculate
% network latency. Also considering the value of BW, as low BW means the
% data have to be sent by partitioning the total data into more than one
% streams
l_network= datasample(y,1)*1e-9;
% execution time in xeon processor in cloud is proportional to their clock
% speed. first part of the equation denotes upload time, which will depend
% onavailable BW and file size. 14.63 MB is the avg upload speed for
% Verizon LTE. 2nd part is the download time, and final part is the
% execution time in cloud
l_xeon=l_network*totalsize/(bw*14.63*1048576)+l_network+iter*1e-9/XEON_ARM;

% calculating latency difference, and normalizing it, assuming maximum no
% of iteration=50,000,000
latency=(l_xeon-l_arm)/0.025;

% putting all the data in the fuzzy algorithm
out=evalfis([device cost latency],fismat);

if out>0.5
    disp('application will be executed in cloud, and sending data to the cloud for image comparison')
    [similarity,time, iteration]=corner_detect_A(pic1,pic2);
else
    disp('application will now be executed in the device');
    [similarity,time,iteration]=corner_detect_A(pic1,pic2);
end
bw 
device
cost 
latency
l_xeon
l_arm
disp('total no of iterations(pixel size of the two images combined)='),disp(iteration);
disp('similarity between the two images ='), disp(similarity);
disp('execution time for my shitty pc(sec)='),disp(time);
