function drawrobotpos(theta, h)
% ���ݸ����ĹؽڽǶȻ��ƻ�����
% thetaΪ�ؽڽǶ�ֵ��hΪҪ����ͼ�ε�figure����������� h = figure ����


global Tu;
global Tt;

% ����DHģ��
a1 = 400;
d0 = 830;
a2 = 1175;
a3 = 250;
d4 = -1125.33;
d6 = -230;

alpha0 = 180 / 180 * pi;
alpha1 = 90 / 180 * pi;
alpha2 = 180 / 180 * pi;
alpha3 = -90 / 180 * pi;
alpha4 = -90 / 180 * pi;
alpha5 = 90 / 180 * pi;
alpha6 = 180 / 180 * pi;


% ���ؽڵı任����
Ab = DHmatrix(0, d0, 0, alpha0); 
A1 = DHmatrix(theta(1), 0, a1, alpha1);
A2 = DHmatrix(theta(2) - pi / 2, 0, a2, alpha2);
A3 = DHmatrix(theta(3) + theta(2) + pi/ 2, 0, a3, alpha3);
A4 = DHmatrix(theta(4), d4, 0, alpha4);
A5 = DHmatrix(theta(5), 0, 0, alpha5);
A6 = DHmatrix(theta(6) + pi, d6, 0, alpha6);

% Ϊͳһ����������α�ʾ
p0 = [0, 0, 0]';
p1 = [0, 0, d0]';
p2 = Ab * A1 * [0, 0, 0, 1]';
p3 = Ab * A1 * A2 * [0, 0, 0, 1]';
p4 = Ab * A1 * A2 * A3 * A4 * [0, 0, 0, 1]';
p5 = Ab * A1 * A2 * A3 * A4 * A5 * [0, 0, 0, 1]';
p6 = Ab * A1 * A2 * A3 * A4 * A5 * A6 * [0, 0, 0, 1]';
pt = Ab * A1 * A2 * A3 * A4 * A5 * A6 * Tt * [0, 0, 0, 1]';

p41 = Ab * A1 * A2 * A3 * A4 * [0, d4, 0, 1]';

figure(h);



cla(gca);   % ���ԭfigure�ϵ�ͼ��

% t1 = tic;

linewidth = 3;  % �������˵��߿�

% ��������
plot3([p0(1), p1(1)], [p0(2), p1(2)], [p0(3), p1(3)], 'b', 'linewidth', linewidth);
hold on;
plot3([p1(1), p2(1)], [p1(2), p2(2)], [p1(3), p2(3)], 'k', 'linewidth', linewidth);

plot3([p2(1), p3(1)], [p2(2), p3(2)], [p2(3), p3(3)], 'k', 'linewidth', linewidth);

plot3([p2(1), p3(1)], [p2(2), p3(2)], [p2(3), p3(3)], 'k', 'linewidth', linewidth);

plot3([p3(1), p41(1)], [p3(2), p41(2)], [p3(3), p41(3)], 'k', 'linewidth', linewidth);

plot3([p41(1), p4(1)], [p41(2), p4(2)], [p41(3), p4(3)], 'k', 'linewidth', linewidth);

plot3([p4(1), p5(1)], [p4(2), p5(2)], [p4(3), p5(3)], 'k', 'linewidth', linewidth);

plot3([p5(1), p6(1)], [p5(2), p6(2)], [p5(3), p6(3)], 'k', 'linewidth', linewidth);

plot3([pt(1), p6(1)], [pt(2), p6(2)], [pt(3), p6(3)], 'color', [0.5 0.5 0.5], 'linewidth', linewidth);

% ���ƹؽ�
h = 250;    % �ؽ�Բ���ĳ���
R = 70;     % �ؽ�Բ���İ뾶

[xc, yc, zc] = cylinder(R, 20);
zc = zc * h - h / 2;    % ��Բ��ƽ�Ƶ�ԭ��Ϊ���ĸ߶ȴ�

facecolor = [0.7, 0, 0];    % ������ɫ
pathcolor = [0.4, 0, 0];    % ��������ɫ

% ���Ƶ�һ�ؽ�
drawjointcyl(xc, yc, zc, Ab, facecolor, pathcolor);

% ���Ƶڶ��ؽ�
drawjointcyl(xc, yc, zc, Ab * A1, facecolor, pathcolor);

% ���Ƶ����ؽ�
drawjointcyl(xc, yc, zc, Ab * A1 * A2, facecolor, pathcolor);

% ���Ƶ��Ĺؽ�
drawjointcyl(xc, yc, zc, Ab * A1 * A2 * A3, facecolor, pathcolor);

% ���Ƶ���ؽ�
drawjointcyl(xc, yc, zc, Ab * A1 * A2 * A3 * A4, facecolor, pathcolor);

% ���Ƶ����ؽ�
drawjointcyl(xc, yc, zc, Ab * A1 * A2 * A3 * A4 * A5, facecolor, pathcolor);

% ��������ϵ
len = 500;  % ��������ϵ���߶γ���
axiswidth = 1.5;    % ����ϵ�߿�
axisfontsize = 12;  % �ֺ�
% ���ƻ�����ϵ
plot3([0, len], [0, 0], [0, 0], 'r', 'linewidth', axiswidth);
text(len, 0, 0, 'Xb', 'fontsize', axisfontsize);

plot3([0, 0], [0, len], [0, 0], 'b', 'linewidth', axiswidth);
text(0, len, 0, 'Yb', 'fontsize', axisfontsize);

plot3([0, 0], [0, 0], [0, len], 'g', 'linewidth', axiswidth);
text(0, 0, len, 'Zb', 'fontsize', axisfontsize);


len = 200;  % ��������ϵ���߶γ���
% ����ĩ�˹�������ϵ
ptx = [len, 0, 0, 1]';
pty = [0, len, 0, 1]';
ptz = [0, 0, len, 1]';

ptxb = Ab * A1 * A2 * A3 * A4 * A5 * A6 * Tt * ptx;
ptyb = Ab * A1 * A2 * A3 * A4 * A5 * A6 * Tt * pty;
ptzb = Ab * A1 * A2 * A3 * A4 * A5 * A6 * Tt * ptz;


plot3([pt(1), ptxb(1)], [pt(2), ptxb(2)], [pt(3), ptxb(3)], 'r', 'linewidth', axiswidth);
text(ptxb(1), ptxb(2), ptxb(3), 'Xt', 'fontsize', axisfontsize);

plot3([pt(1), ptyb(1)], [pt(2), ptyb(2)], [pt(3), ptyb(3)], 'b', 'linewidth', axiswidth);
text(ptyb(1), ptyb(2), ptyb(3), 'Yt', 'fontsize', axisfontsize);

plot3([pt(1), ptzb(1)], [pt(2), ptzb(2)], [pt(3), ptzb(3)], 'g', 'linewidth', axiswidth);
text(ptzb(1), ptzb(2), ptzb(3), 'Zt', 'fontsize', axisfontsize);

len = 500;  % ��������ϵ���߶γ���
% ����ĩ�˹�������ϵ
ptx = [len, 0, 0, 1]';
pty = [0, len, 0, 1]';
ptz = [0, 0, len, 1]';


puxb = Tu * ptx;
puyb = Tu * pty;
puzb = Tu * ptz;

puo = Tu * [0, 0, 0, 1]';

plot3([puo(1), puxb(1)], [puo(2), puxb(2)], [puo(3), puxb(3)], 'r', 'linewidth', axiswidth);
text(ptxb(1), ptxb(2), ptxb(3), 'Xt', 'fontsize', axisfontsize);

plot3([puo(1), puyb(1)], [puo(2), puyb(2)], [puo(3), puyb(3)], 'b', 'linewidth', axiswidth);
text(ptyb(1), ptyb(2), ptyb(3), 'Yt', 'fontsize', axisfontsize);

plot3([puo(1), puzb(1)], [puo(2), puzb(2)], [puo(3), puzb(3)], 'g', 'linewidth', axiswidth);
text(ptzb(1), ptzb(2), ptzb(3), 'Zt', 'fontsize', axisfontsize);

% toc(t1)
% ���û�ͼ����
xlim([-(a1 - d4 - d6) - 300  a1 - d4 - d6 + 300]);
ylim([-(a1 - d4 - d6) - 300  a1 - d4 - d6 + 300]);
zlim([0  d0 + a2 - a3 - d4 - d6 + 300]);

grid on;

xlabel('X');
ylabel('Y');
zlabel('Z');
