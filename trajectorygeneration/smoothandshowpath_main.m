clear;
close all;

global Tu;
global Tt;

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

% toolframe(4:6) = toolframe(4:6) * pi / 180;
% uframe(4:6) = uframe(4:6) * pi / 180;

toolmat = enlerangle2rotatemat(toolframe(1:3), toolframe(4:6));
umat = enlerangle2rotatemat(uframe(1:3), uframe(4:6));
jointinit = [-23, 34, -155, 19, 76, 88];
Tu = umat;
Tt = toolmat;

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
[controlp, knotvector] = pathsmooth2(pathdata, splineorder, round(size(pathdata, 1) / 3) ); 
bsplinepath.controlp = controlp;
bsplinepath.knotvector = knotvector;
bsplinepath.splineorder = splineorder;

% �鿴���֮��ĵ�·
du = 0.001;
i = 1;
for u = 0:du:1
    % ���в岹����
    deboorp(i, :) = DeBoorCoxNurbsCal(u, bsplinepath, 0);
    
    % ���ڵ�·�ļ������ĵ�������ϵ���û�����ϵ�µ���̬���˶�ѧ���ʱ��Ҫת��Ϊ������ĩ���ڻ�����ϵ�е�λ��
    g = umat * enlerangle2rotatemat(deboorp(i, 1:3), deboorp(i, 4:6)) / toolmat;    
    
    theta = inversekinamicsDH2( g); % �˶�ѧ���
    
    % ѡ�⣬��������������һλ�ùؽڱ仯��С�ĵ���Ϊ��
    mindis = 100;
    minindex = 1;
    if i == 1
%         minindex = 64;
        for j = 1:size(theta, 1)
            % ��һ����ѡ���趨�ĳ�ʼλ������ĵ�
            if norm(theta(j, :) - jointinit) < mindis
                minindex = j;
                mindis = norm(theta(j, :) - joint(i - 1, :));
            end
        end
    else
        for j = 1:size(theta, 1)
            % �ڶ����㿪ʼѡ������һλ������ĵ�
            if norm(theta(j, :) - joint(i - 1, :)) < mindis
                minindex = j;
                mindis = norm(theta(j, :) - joint(i - 1, :));
            end
        end
    end
    joint(i, :) = theta(minindex, :);
    i = i + 1;    
end

bpath = zeros(size(deboorp, 1), 3);
for i = 1:size(deboorp, 1)
    g = umat * enlerangle2rotatemat(deboorp(i, 1:3), deboorp(i, 4:6));
    bpath(i, :) = g(1:3, 4)';
end

figure;subplot(1, 2, 1);
plot3(deboorp(:, 1), deboorp(:, 2), deboorp(:, 3), 'b');
hold on;
plot3(pathdata(:, 1), pathdata(:, 2), pathdata(:, 3), 'r');
subplot(1, 2, 2);
plot3(deboorp(:, 4), deboorp(:, 5), deboorp(:, 6), 'b');
hold on;
plot3(pathdata(:, 4), pathdata(:, 5), pathdata(:, 6), 'r');

figure;
subplot(2, 2, 1);plot(deboorp(:, 4));
subplot(2, 2, 2);plot(deboorp(:, 5));
subplot(2, 2, 3);plot(deboorp(:, 6));

figure;
subplot(2, 3, 1);plot(joint(:, 1));
subplot(2, 3, 2);plot(joint(:, 2));
subplot(2, 3, 3);plot(joint(:, 3));
subplot(2, 3, 4);plot(joint(:, 4));
subplot(2, 3, 5);plot(joint(:, 5));
subplot(2, 3, 6);plot(joint(:, 6));

% velj = joint(2:end, :) - joint(1:end - 1, :);
% figure;
% subplot(2, 3, 1);plot(velj(:, 1));
% subplot(2, 3, 2);plot(velj(:, 2));
% subplot(2, 3, 3);plot(velj(:, 3));
% subplot(2, 3, 4);plot(velj(:, 4));
% subplot(2, 3, 5);plot(velj(:, 5));
% subplot(2, 3, 6);plot(velj(:, 6));
% 
% accj = velj(2:end, :) - velj(1:end - 1, :);
% figure;
% subplot(2, 3, 1);plot(accj(:, 1));
% subplot(2, 3, 2);plot(accj(:, 2));
% subplot(2, 3, 3);plot(accj(:, 3));
% subplot(2, 3, 4);plot(accj(:, 4));
% subplot(2, 3, 5);plot(accj(:, 5));
% subplot(2, 3, 6);plot(accj(:, 6));


% h = figure;
% for i = 1:4:size(joint, 1)
%     drawrobotpos(joint(i, :), h);
%     hold on;
%     plot3(bpath(:, 1), bpath(:, 2), bpath(:, 3) ,'g', 'linewidth', 2);
% end