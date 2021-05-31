%wgs84

function xyz=BLH2XYZ(BLH)

%BLH(1)=BLH(1)*pi/180.0;
%BLH(2)=BLH(2)*pi/180.0;

xyz=[];
a=6378137;
per_alpha=298.257223563;%扁率分之一
b=a-a/per_alpha;
e2=(a*a-b*b)/(a*a);
N=a/(sqrt(1-e2*sin(BLH(1))*sin(BLH(1))));

xyz(1)=(N+BLH(3))*cos(BLH(1))*cos(BLH(2));
xyz(2)=(N+BLH(3))*cos(BLH(1))*sin(BLH(2));
xyz(3)=(N*(1-e2)+BLH(3))*sin(BLH(1));
end