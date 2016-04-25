clear;
close all;

global Tu;  % �û�����ϵ
global Tt;  % ��������ϵ
global jointinit;   % ��ʼ��ؽ�ֵ

Ts = 0.002;

% ���Ŀ¼
addpath('../Common/BSpline');
addpath('../Common/Robotics');
addpath('../Common/Dualquaternions');
addpath('../Common/Trajectorygeneration');
addpath('../Data/Input');
addpath('../Common\feedratescheduling/dynamicbasedjerklimited');

% pathfile = fopen('testpath1.txt', 'r');
pathfile = fopen('mypath.txt', 'r');

toolframe = [207.66,0.00,366.73,0.00,60.00,180.00];
uframe = [1695.21,0.00,1050.72,0.00,0.00,0.00];

Tu = enlerangle2rotatemat(toolframe(1:3), toolframe(4:6));
Tt = enlerangle2rotatemat(uframe(1:3), uframe(4:6));

jointinit = [-23, 34, -155, 19, 76, 88];

% ��ȡ��·�ļ�
rownum = 1;
while ~feof(pathfile)

	ch = fscanf(pathfile, '%c', 1);
	while ~strcmp(ch, '(')	% ��Чλ�ô�'('��ʼ
		ch = fscanf(pathfile, '%c', 1);
	end
	pathdata(rownum, :) = fscanf(pathfile, '%f,%f,%f,%f,%f,%f,');	% ��ȡ�����6������������
	rownum = rownum + 1;
	
	ch = fscanf(pathfile, '%c', 1);	
	while double(ch) ~= 13
		ch = fscanf(pathfile, '%c', 1);
	end
end

% �Ե�·�������ǰ���д���һ�£�ȥ��λ�õ㲻�����̬�仯�ĵ�
rownum = 1;
for i = 1:size(pathdata, 1) - 1
    if norm(pathdata(i + 1, 1:3) - pathdata(i, 1:3)) > 0.01
        pathdata2(rownum, :) = pathdata(i, :);
        rownum = rownum + 1;
    end
end
pathdata = pathdata2;

% ���ǰ��ŷ���ǲ���ͻ��ĵط����д���
for i = 2:size(pathdata, 1)
    for j = 4:6
        if pathdata(i, j) - pathdata(i - 1, j) > 180
            pathdata(i, j) = pathdata(i, j) - 360;
        elseif pathdata(i, j) - pathdata(i - 1, j) < -180
            pathdata(i, j) = pathdata(i, j) + 360;
        end
    end
end

% ����·��ϳ�Ϊ������·
splineorder = 3;
[controlp, knotvector] = pathsmooth2(pathdata, splineorder, round(size(pathdata, 1) / 4) ); 
bsplinepath.controlp = controlp;
bsplinepath.knotvector = knotvector;
bsplinepath.splineorder = splineorder;

feedratemax = NurbsScanningRobot(bsplinepath, Ts);