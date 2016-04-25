clear;
close all;

Ts = 0.002;

addpath('../Common/BSpline');
addpath('../Common/Robotics');
addpath('../Common/Dualquaternions');
addpath('../Common/Trajectorygeneration');
addpath('../Data/Input');
addpath('../Common\feedratescheduling/dynamicbasedjerklimited');
data = importdata('results5.txt');
data = data * pi / 180;

span = 16;
data(:, 1) = smooth(data(:, 1), span);
data(:, 2) = smooth(data(:, 2), span);
data(:, 3) = smooth(data(:, 3), span);
data(:, 4) = smooth(data(:, 4), span);
data(:, 5) = smooth(data(:, 5), span);
data(:, 6) = smooth(data(:, 6), span);

vforward = zeros(size(data, 1) - 1, 3);
point = zeros(size(data, 1), 3);
angles = zeros(size(data, 1), 3);

for i = 1:size(data, 1)
    g = forwardkinamicsDH(data(i, :));
    point(i, :) = g(1:3, 4)';
    aa = rotatemat2enlerangle(g);
    angles(i, :) = aa(1, :);
    if i > 1
        
        vforward(i - 1, :) = (point(i, :) - point(i - 1, :)) / Ts;
        vforwardabs(i) = norm(vforward(i - 1, :));
    end
end

vel = zeros(size(data, 1) - 1, 6);
velcart = zeros(size(data, 1) - 1, 6);
v = zeros(size(data, 1) - 1, 1);

for i = 1:size(data, 1) - 1
    vel(i, :) = (data(i + 1, :) - data(i, :)) / Ts;
    Jac = jacobiangeometric(data(i, :));
    velcart(i, :) = (Jac * vel(i, :)')';
    v(i) = norm(velcart(i, 1:3));    
end
verr = vforward - velcart(:, 1:3);

vel(:, 1) = smooth(vel(:, 1), span);
vel(:, 2) = smooth(vel(:, 2), span);
vel(:, 3) = smooth(vel(:, 3), span);
vel(:, 4) = smooth(vel(:, 4), span);
vel(:, 5) = smooth(vel(:, 5), span);
vel(:, 6) = smooth(vel(:, 6), span);

figure;

subplot(2, 2, 1);plot(v, 'b');title('�ѿ����ռ��ٶȴ�С');hold on;plot(vforwardabs, 'r');
subplot(2, 2, 2);plot(velcart(:, 1), 'b');title('�ѿ����ռ�X�����ٶ�');hold on;plot(vforward(:, 1), 'r');
subplot(2, 2, 3);plot(velcart(:, 2), 'b');title('�ѿ����ռ�Y�����ٶ�');hold on;plot(vforward(:, 2), 'r');
subplot(2, 2, 4);plot(velcart(:, 3), 'b');title('�ѿ����ռ�Z�����ٶ�');hold on;plot(vforward(:, 3), 'r');

% acc = zeros(size(data, 1) - 2, 6);
% for i = 1:size(data, 1) - 2
%     acc(i, :) = (vel(i + 1, :) - vel(i, :)) / Ts;
% end
acc = (vel(2:end, :) - vel(1:end - 1, :)) / Ts;

span = 7;
acc(:, 1) = smooth(acc(:, 1), span);
acc(:, 2) = smooth(acc(:, 2), span);
acc(:, 3) = smooth(acc(:, 3), span);
acc(:, 4) = smooth(acc(:, 4), span);
acc(:, 5) = smooth(acc(:, 5), span);
acc(:, 6) = smooth(acc(:, 6), span);
% 
% 
% figure;
% plot3(point(:, 1), point(:, 2), point(:, 3));
% title('�ѿ����ռ�켣');
% 
% figure;
% 
% subplot(2, 3, 1);
% plot(data(:, 1));
% title('�ؽڿռ�켣1��');
% 
% subplot(2, 3, 2);
% plot(data(:, 2));
% title('�ؽڿռ�켣2��');
% 
% subplot(2, 3, 3);
% plot(data(:, 3));
% title('�ؽڿռ�켣3��');
% 
% subplot(2, 3, 4);
% plot(data(:, 4));
% title('�ؽڿռ�켣4��');
% 
% subplot(2, 3, 5);
% plot(data(:, 5));
% title('�ؽڿռ�켣5��');
% 
% subplot(2, 3, 6);
% plot(data(:, 6));
% title('�ؽڿռ�켣6��');
% 
figure;
subplot(2, 3, 1);plot(vel(:, 1));title('�ؽڿռ��ٶ�1��');
subplot(2, 3, 2);plot(vel(:, 2));title('�ؽڿռ��ٶ�2��');
subplot(2, 3, 3);plot(vel(:, 3));title('�ؽڿռ��ٶ�3��');
subplot(2, 3, 4);plot(vel(:, 4));title('�ؽڿռ��ٶ�4��');
subplot(2, 3, 5);plot(vel(:, 5));title('�ؽڿռ��ٶ�5��');
subplot(2, 3, 6);plot(vel(:, 6));title('�ؽڿռ��ٶ�6��');
% 
figure;
subplot(2, 3, 1);plot(acc(:, 1));title('�ؽڿռ���ٶ�1��');
subplot(2, 3, 2);plot(acc(:, 2));title('�ؽڿռ���ٶ�2��');
subplot(2, 3, 3);plot(acc(:, 3));title('�ؽڿռ���ٶ�3��');
subplot(2, 3, 4);plot(acc(:, 4));title('�ؽڿռ���ٶ�4��');
subplot(2, 3, 5);plot(acc(:, 5));title('�ؽڿռ���ٶ�5��');
subplot(2, 3, 6);plot(acc(:, 6));title('�ؽڿռ���ٶ�6��');