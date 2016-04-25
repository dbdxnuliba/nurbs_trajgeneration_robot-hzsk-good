clear;
close all;

addpath('../Data/Input');
addpath('../Common');
addpath('../trajectorygeneration');

pathdata = importdata('toolpath.txt');
% pathdata = importdata('pathvol.txt');

pathdata = approximateanddensify(pathdata);

pathdata(:, 7:12) = pathdata(:, 7:12) * 20 / 10;    % ֮ǰ�������ٶ�ֵ̫С�ˣ�����Ĵ�һ�㡣


Ts = 0.002;

global Tu;
global Tt;

toolcoor = [352.64,0.00,469.28,0.00,60.00,180.00];  % ��������ϵ����
usercoor = [1613.56, 0, 780, 0, 0, 0];              % �û�����ϵ����

Tu = enlerangle2rotatemat(usercoor(1:3), usercoor(4:6));    % ����Ӧ
Tt = enlerangle2rotatemat(toolcoor(1:3), toolcoor(4:6));

% �ο�Liu H, Lai X, Wu W. Time-Optimal and Jerk-Continuous Trajectory
% Planning for Robot Manipulators with Kinematic Constraints. Robot Cim-Int
% Manuf, 2013, 2: 309-317�е�����
% vmax = [100, 95, 100, 150, 130, 110];
% amax = [45, 40, 75, 70, 90, 80];
% jmax = [60, 60, 55, 70, 75, 70];      % �����е�Ծ��̫С�����²���˫S�͹滮ʱ������ѭ��

% vmax = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2];
% amax = [20, 20, 20, 20, 20, 20];
% jmax = [600, 600, 650, 600, 650, 600];

vmax = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2];
amax = [80, 80, 80, 80, 80, 80];
jmax = [1000, 1000, 1000, 1000, 1000, 1000];

lastjointpos = [0, 0, -pi / 2, 0, 0, 0];    % ������һ�ؽڿռ�Ϊλ�ã���������ʱ��ѡ����

maxindex = 1;
maxdis = 1000;


% �����˶�ѧ���⣬��ؽ�λ�ú��ٶ�
% h = figure;
for k = 1:size(pathdata, 1)
    i = k;
    maxindex = 1;
    maxdis = 1000;
    
    Ttpos = enlerangle2rotatemat(pathdata(i, 1:3), pathdata(i, 4:6)); % �����û�����ϵ�µ�λ��
    Tbase = Tu * Ttpos / Tt;    % �任��������ϵ�µĻ�����ĩ�˴��������������˶�ѧ���
    
    jp = inversekinamicsDH(Tbase);
    
    % ѡ�⣬ʹ������һ�������С
    for j = 1:size(jp, 1)
        temp = norm(jp(j, :) - lastjointpos);
        if temp < maxdis
            maxindex = j;
            maxdis = temp;
        end
    end
    joint(i, :) = jp(maxindex, :);
    
    Jaco = jacobian(joint(i, :));   % ���ſ˱Ⱦ���
    
    vjoint(i, :) = Jaco \ pathdata(i, 7:12)';   % ����ؽ��ٶ�ֵ
    
    lastjointpos = jp(maxindex, :);
end

aa = 1;

% ���÷����ؽڿռ��е�λ�ý��й켣�滮
traj = jointtrajectorygeneration(joint, vjoint, vmax, amax, jmax);

% �岹����켣
[jointq, jointv, jointa, jointj] = caltrajectorypoints(traj, joint, vjoint, Ts, jmax, pathdata);



% h = figure;
% k = 1;
% for i = 1:size(jointq, 1) / k
%     jointmove = jointq(i * k, :);
%     drawrobotpos(jointmove, h);
% end