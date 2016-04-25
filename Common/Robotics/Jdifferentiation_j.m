function Jder_j = Jdifferentiation_j(theta, j)
% �����ſ˱ȶԦ�i��ƫ��
% ���룺 theta ���ؽڽǶ�, j �Ե�j���ؽ���ƫ��
% ����� Jer_j 6x6��һ��������J��ÿһ�ж��Ԧ�j��ƫ��

% ������ģ�����˳ߴ�ֵ
a1 = 400;
d0 = 830;
a2 = 1175;
a3 = 250;
d4 = 1125.33;
d6 = 230;

w1 = [0 0 -1];
w2 = [0 1 0];
w3 = [0 -1 0];
w4 = [0 0 -1];
w5 = [0 1 0];
w6 = [0 0 -1];

p1 = [0, 0, 0];
p2 = [a1, 0, d0];
p3 = [a1, 0, d0 + a2];
p4 = [a1 - a3, 0, d0 + a2];
p5 = [a1 - a3, 0, d0 + a2 + d4];
p6 = [a1 - a3, 0, d0 + a2 + d4 + d6];
		
A1 = POE(w1, p1, theta(1));
A2 = POE(w2, p2, theta(2));
A3 = POE(w3, p3, theta(3) + theta(2));
A4 = POE(w4, p4, theta(4));
A5 = POE(w5, p5, theta(5));
A6 = POE(w6, p6, theta(6));

gst0 = [1, 0, 0, a1 - a3;
		0, 1, 0, 0;
		0, 0, 1, d0 + a2 + d4 + d6;
		0, 0, 0, 1];

% �����˶��󣬵�ǰʱ�̸���λ��
pb = zeros(4, 6);
pb(:, 1) = [p1, 1]';
pb(:, 2) = A1 * [p2, 1]';
pb(:, 3) = A1 * A2 * [p3, 1]';
pb(:, 4) = A1 * A2 * A3 * [p4, 1]';
pb(:, 5) = A1 * A2 * A3 * A4 * [p5, 1]';
pb(:, 6) = A1 * A2 * A3 * A4 * A5 * [p6, 1]';
pe  = A1 * A2 * A3 * A4 * A5 * A6 * gst0 * [0, 0, 0, 1]';

% ��������˶���ķ���
wb = zeros(4, 6);
wb(:, 1) = [w1, 0]';
wb(:, 2) = [0, 0, 0, 0]';
wb(:, 3) = A1 * [w3, 0]';
wb(:, 4) = A1 * A2 * A3 * [w4, 0]';
wb(:, 5) = A1 * A2 * A3 * A4 * [w5, 0]';
wb(:, 6) = A1 * A2 * A3 * A4 * A5 * [w6, 0]';

% ����ռ��ſ˱ȸ���
% xib = zeros(6, 6);
xis = zeros(6, 6);
xi2b = A1 * A2 * [a2, 0, 0, 0]';

% xis(:, 1) = [cross(wb(1:3, 1), - pb(1 : 3, 1)); wb(1:3, 1)];
% xis(:, 2) = [xi2b(1:3); wb(1:3, 2)];
% xis(:, 3) = [cross(wb(1:3, 3), - pb(1 : 3, 3)); wb(1:3, 3)];
% xis(:, 4) = [cross(wb(1:3, 4), - pb(1 : 3, 4)); wb(1:3, 4)];
% xis(:, 5) = [cross(wb(1:3, 5), - pb(1 : 3, 5)); wb(1:3, 5)];
% xis(:, 6) = [cross(wb(1:3, 6), - pb(1 : 3, 6)); wb(1:3, 6)];

xib(:, 1) = [cross(wb(1:3, 1), pe(1 : 3) - pb(1 : 3, 1)); wb(1:3, 1)];
xib(:, 2) = [xi2b(1:3); wb(1:3, 2)];
xib(:, 3) = [cross(wb(1:3, 3), pe(1 : 3) - pb(1 : 3, 3)); wb(1:3, 3)];
xib(:, 4) = [cross(wb(1:3, 4), pe(1 : 3) - pb(1 : 3, 4)); wb(1:3, 4)];
xib(:, 5) = [cross(wb(1:3, 5), pe(1 : 3) - pb(1 : 3, 5)); wb(1:3, 5)];
xib(:, 6) = [cross(wb(1:3, 6), pe(1 : 3) - pb(1 : 3, 6)); wb(1:3, 6)];

% ���ݡ�Symbolic differentiation of the velocity mapping for a serial
% kinematic chain�����ſ˱Ⱦ���Թؽ�j��ƫ��
Jder_j = zeros(6, 6);


Pj = zeros(6, 6);
Mj = zeros(6, 6);

Pj(1:3, 1:3) = hatm(wb(1:3, j));
Pj(4:6, 4:6) = hatm(wb(1:3, j));

Mj(1:3, 4:6) = hatm(cross(wb(1:3, j), pe(1:3) - pb(1:3, j)));

% ���ڶԦ�2��ƫ��ʱ�е㲻ͬ���������¸���
if j == 2
    % ���ڵڶ��У���Ҫ������㣬���ڵڶ�����ת����Ϊ0����?x/?��2��?y/?��2�õ���ʽ��ֻ���1�ͦ�2�й�
    Jder_j(1, 1) = -cos(theta(2)) * sin(theta(1)) * a2;
    Jder_j(1, 2) = -cos(theta(1)) * sin(theta(2)) * a2;
    
    Jder_j(2, 1) = -cos(theta(2)) * cos(theta(1)) * a2;
    Jder_j(2, 2) = sin(theta(1)) * sin(theta(2)) * a2;
    
    Jder_j(3, 2) = -cos(theta(2)) * a2;    
    
else
    for i = 1:6
        Tempmat = zeros(6, 6);
        if i == 2
            if j == 1
                xi2 = [-cos(theta(2)) * sin(theta(1)) * a2, -cos(theta(2)) * cos(theta(1)) * a2, 0, 0, 0, 0]';
            else
                xi2 = zeros(6, 1);
            end
            Jder_j(:, i) = xi2;
        else
            if i < j
                Jder_j(:, i) = -Mj * xib(:, i);
            else
                Jder_j(:, i) = Pj * xib(:, i);
            end
        end
    end
end