clear
clc
format long

prefix1='00000';
suffix='.txt';
gravity=9.80952307;                                                        %Gravity

%Set your data path
ts_dir='C:/Users/word/Desktop/RESIDENTIAL/corrected/2011_09_26_drive_0022_extract/oxts'; 
path=[ts_dir,'/data/'];

%read time stamps
ts = loadTimestamps(ts_dir);
N=length(ts);                                                              % data num


%Parameter
coordinate=zeros(N,3);                                                     %WGS-84
gyroscope=zeros(N,3);                                                      
Accelerometer=zeros(N,3);                                                 
rawGyroscope=zeros(N,3); 
rawAccelerometer=zeros(N,3); 
xyz=zeros(N,3);
Cen=zeros(3,3);                                                            %WGS-84 to NED
NED=zeros(N,3);
abNED=zeros(N,3);
Cnb=zeros(3,3);

seconds=zeros(N,1);
acc_ned=zeros(N,3);
vb=zeros(N,3);
pb=zeros(N,3);
pn=zeros(N,3);
vn=zeros(N,3);
pn_ned=zeros(N,3);

bias=zeros(N,12);

%Need saved
saved_data=zeros(N,21);


distance=0;
alltime=0;
averagev=0;

%reading loop
num=-1;
for i=1:N
    
    num=num+1;
    for j=1:N
        if(num<10)
            prefix2='0000';
        end
        if((9<num)&&(num<100))
            prefix2='000';
        end
        if((99<num)&&(num<1000))
            prefix2='00';
        end
        if((999<num)&&(num<10000))
            prefix2='0';
        end
        if(num>9999)
            prefix2='';
        end
        
        Numstr=num2str(num);
        filename=[path,prefix1,prefix2,Numstr,suffix];
        fid=fopen(filename);
        if(fid==-1)
            num=num+1;
            continue;
        end
        if(fid~=-1)
            str = fgetl(fid); 
            break;
        end
    end
    s=strsplit(str);  
    
    for j=1:3
        coordinate(i,j)=str2double(s(j));
        gyroscope(i,j)=str2double(s(j+3));
        rawGyroscope(i,j)=str2double(s(j+3));
        Accelerometer(i,j)=str2double(s(j+11));
        rawAccelerometer(i,j)=str2double(s(j+11));
        
        saved_data(i,j)=rawAccelerometer(i,j);
        saved_data(i,j+3)=rawGyroscope(i,j);
      
        
    end
    fclose(fid);
    
    gyroscope(i,3)=-pi/2-gyroscope(i,3);
    
    coordinate(i,1)=coordinate(i,1)*pi/180.0;
    coordinate(i,2)=coordinate(i,2)*pi/180.0;
    xyz(i,:)=BLH2XYZ(coordinate(i,:));%blh to xyz
    
    seconds(i)=ts(i,4)*3600+ts(i,5)*60+ts(i,6);
    
    if(i>1)
        saved_data(i,7)=seconds(i)-seconds(1);
    end
end
alltime=seconds(N)-seconds(1);

Cen=[-cos(coordinate(1,2))*sin(coordinate(1,1)), -sin(coordinate(1,2))*sin(coordinate(1,1)), cos(coordinate(1,1)); ...
    -sin(coordinate(1,2)), cos(coordinate(1,2)), 0; ...
    -cos(coordinate(1,2))*cos(coordinate(1,1)), -sin(coordinate(1,2))*cos(coordinate(1,1)), -sin(coordinate(1,1))];

deltaNED0=Cen*xyz(1,:)';                                                   %Relative position

NED1=Cen*xyz(2,:)'-deltaNED0;
NED2=Cen*xyz(3,:)'-deltaNED0;
NED3=Cen*xyz(4,:)'-deltaNED0;
NED4=Cen*xyz(5,:)'-deltaNED0;
NED5=Cen*xyz(6,:)'-deltaNED0;

vb0=[0 0 0];
vn1=[NED2(2);NED2(1);-NED2(3)]/(seconds(3)-seconds(1));

pb0=[0 0 0];
pn1=[NED1(2);NED1(1);-NED1(3)];

rx=gyroscope(1,1);
ry=gyroscope(1,2);
rz=-pi/2-gyroscope(1,3);

Rx = [1 0 0; 0 cos(rx) -sin(rx); 0 sin(rx) cos(rx)];                       % base => nav  (level oxts => rotated oxts)
Ry = [cos(ry) 0 sin(ry); 0 1 0; -sin(ry) 0 cos(ry)];                       % base => nav  (level oxts => rotated oxts)
Rz = [cos(rz) -sin(rz) 0; sin(rz) cos(rz) 0; 0 0 1];                       % base => nav  (level oxts => rotated oxts)

R0=Rz*Ry*Rx;                                                               %base to nav



acc_ned(1,:)=(R0*Accelerometer(1,:)')'-[0 0 gravity];
Accelerometer(1,:)=(R0'*acc_ned(1,:)')';



saved_data(1,8:10)=Accelerometer(1,:);
saved_data(1,11:13)=Accelerometer(1,:);




vnx=zeros(N,3);
blvb=zeros(N,3);
blab=zeros(N,3);
blpb=zeros(N,3);

%Main loop
for i=2:N
    
    NED(i,:)=(Cen*xyz(i,:)'-deltaNED0)';
    blpb(i,:)=(R0'*[NED(i,2),NED(i,1),-NED(i,3)]')';
    if i==3
        blvb(2,:)=blpb(3,:)/(seconds(3)-seconds(1));
        blvb(1,:)=(-blpb(3,:)+4*blpb(2,:)-3*blpb(1,:))/(seconds(3)-seconds(1));
    end
    if i==4
        blvb(3,:)=(blpb(4,:)-blpb(2,:))/(seconds(4)-seconds(2));
        blab(2,:)=(blvb(3,:)-blvb(1,:))/(seconds(3)-second(1));
        blab(1,:)=(-blvb(3,:)+4*blvb(2,:)-3*blvb(1,:))/(seconds(3)-seconds(1));
    end
    if i>4
        blvb(i-1,:)=(blpb(i,:)-blpb(i-2,:))/(seconds(i)-seconds(i-2));
        blab(i-2,:)=(blvb(i-1,:)-blvb(i-3,:))/(seconds(i-1)-seconds(i-3));
    end
    if i==N
        blvb(i,:)=(3*blpb(i,:)-4*blpb(i-1,:)+blpb(i-2,:))/(seconds(i)-seconds(i-2));
        blab(i-1,:)=(blvb(i,:)-blvb(i-2,:))/(seconds(i)-seconds(i-2));
        blab(i,:)=(3*blvb(i,:)-4*blvb(i-1,:)+blvb(i-2,:))/(seconds(i)-seconds(i-2));
    end
    
    rx=gyroscope(i,1);
    ry=gyroscope(i,2);
    rz=-pi/2-gyroscope(i,3);
    
    Rx = [1 0 0; 0 cos(rx) -sin(rx); 0 sin(rx) cos(rx)]; % base => nav  (level oxts => rotated oxts)
    Ry = [cos(ry) 0 sin(ry); 0 1 0; -sin(ry) 0 cos(ry)]; % base => nav  (level oxts => rotated oxts)
    Rz = [cos(rz) -sin(rz) 0; sin(rz) cos(rz) 0; 0 0 1]; % base => nav  (level oxts => rotated oxts) 
    R=Rz*Ry*Rx;
    
    acc_ned(i,:)=(R*Accelerometer(i,:)')'-[0 0 gravity];
    Accelerometer(i,:)=(R'*acc_ned(i,:)')';  
    saved_data(i,8:10)=Accelerometer(i,:);
    
    Accelerometer(i,:)=(R0'*R*Accelerometer(i,:)')';
    saved_data(i,11:13)= Accelerometer(i,:);
    if(i==2)
        vb(1,:)=0;                                                         %Initial velocity

        vb(2,:)=(R'*vn1)';
        pb(2,:)=(R'*pn1)';
        vnx(2,:)=vn1';
        pn_ned(2,:)=pn1';
    end
    if(i>2)
        vb(i,:)=vb(i-1,:)+(seconds(i)-seconds(i-1))*(Accelerometer(i,:)+Accelerometer(i-1,:))/2.0;
        pb(i,:)=pb(i-1,:)+(seconds(i)-seconds(i-1))*(vb(i,:)+vb(i-1,:))/2.0; 

        vnx(i,:)=vnx(i-1,:)+(seconds(i)-seconds(i-1))*(acc_ned(i,:)+acc_ned(i-1,:))/2.0;
        pn_ned(i,:)=pn_ned(i-1,:)+(seconds(i)-seconds(i-1))*(vnx(i,:)+vnx(i-1,:))/2.0;
    end
   
    distance=distance+sqrt((NED(i,1)-NED(i-1,1))^2+(NED(i,2)-NED(i-1,2))^2);       
end
averagev=distance/alltime;
for i=1:N
    if i==1
        vb(1,:)=blvb(1,:);
    end
    bias(i,1)=pb(i,2)-blpb(i,2);
    bias(i,2)=-pb(i,1)+blpb(i,1);
    bias(i,3)=vb(i,2)-blvb(i,2);
    bias(i,4)=-vb(i,1)+blvb(i,1);
    bias(i,5)=NED(i,2)-pn_ned(i,1);
    bias(i,6)=NED(i,1)-pn_ned(i,2);
    
    saved_data(i,14:19)=bias(i,1:6);
    saved_data(i,20)=-pb(i,2);
    saved_data(i,21)=pb(i,1);
end


p1=plot(-blpb(:,2),blpb(:,1),'g.','LineWidth',2);
hold on
p2=plot(-pb(:,2),pb(:,1),'r.','LineWidth',2);

xlabel('X');
ylabel('Y');
title('vehicle trajectory (b system)');
