function thetad = jointadjustinrange(theta, thetamax, thetamin, cyc)
% ���ݴ�����˶���Χ�����ڣ����е���λ�ã�������ڴ˷�Χ�ڣ��򷵻�2016��ʾ�޽�

while theta > thetamax
    theta = theta - cyc;
end

while theta < thetamin
    theta = theta + cyc;
end

if theta < thetamax && theta > thetamin
    thetad = theta;
else
    thetad = 2016;
end