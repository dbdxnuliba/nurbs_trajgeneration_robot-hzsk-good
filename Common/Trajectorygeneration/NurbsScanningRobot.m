function feedratemax = NurbsScanningRobot(BSplinepath, interpolationperiod)

global Tu;  % �û�����ϵ
global Tt;  % ��������ϵ
global jointinit;   % ��ʼ��ؽ�ֵ

% �趨Լ������
chorderror = 0.0002;
% F = 100;

axismaxvel = [0.3491, 0.3142, 0.3840, 0.4538, 0.4538, 0.6807] * 0.8;
axismaxacc = [0.2648, 0.2793, 0.2639, 0.1606, 0.1518, 0.2269] * 0.8;
axismaxjerk = [0.6468, 0.7645, 0.8739, 0.2094, 0.1693, 0.2269] * 0.8;

maxfeedrate = 100;

% knotvector = BSplinepath.knotvector;
% controlp = BSplinepath.controlp;
% splineorder = BSplinepath.splineorder;

Ts = interpolationperiod;   % �岹����

stepnum = 1;    % ��¼����

u = 0; du = 0.0005;
uarr = 0:du:1;
Jarr = zeros(6, 6, length(uarr));   % ��������ſ˱Ⱦ��󣬼����ظ�����
TderA = zeros(6, 6, length(uarr));
TderE = zeros(6, 6, length(uarr));
T = zeros(6, 6, length(uarr));
Jder = zeros(6, 6, 6, length(uarr));

feedratemax = zeros(length(uarr));
error = zeros(length(uarr));

scanpders = zeros(length(uarr), 18);
joint = zeros(length(uarr), 6);
               
for u = 0:du:1
   deboorp = DeBoorCoxNurbsCal(u, BSplinepath, 2);
   % ��������
   scanpders(stepnum, 1:6) = deboorp(1, :);
   scanpders(stepnum, 7:12) = deboorp(2, :);
   scanpders(stepnum, 13:18) = deboorp(3, :);
   
   % ���ڵ�·�ļ������ĵ�������ϵ���û�����ϵ�µ���̬���˶�ѧ���ʱ��Ҫת��Ϊ������ĩ���ڻ�����ϵ�е�λ��
    g = Tu * enlerangle2rotatemat(deboorp(1, 1:3), deboorp(1, 4:6)) / Tt;    
    
    theta = inversekinamicsDH2( g); % �˶�ѧ���
    
    % ѡ�⣬��������������һλ�ùؽڱ仯��С�ĵ���Ϊ��
    mindis = 100;
    minindex = 1;
    if u == 0
%         minindex = 64;
        for j = 1:size(theta, 1)
            % ��һ����ѡ���趨�ĳ�ʼλ������ĵ�
            if norm(theta(j, :) - jointinit) < mindis
                minindex = j;
                mindis = norm(theta(j, :) - joint(stepnum - 1, :));
            end
        end
    else
        for j = 1:size(theta, 1)
            % �ڶ����㿪ʼѡ������һλ������ĵ�
            if norm(theta(j, :) - joint(stepnum - 1, :)) < mindis
                minindex = j;
                mindis = norm(theta(j, :) - joint(stepnum - 1, :));
            end
        end
    end
    joint(stepnum, :) = theta(minindex, :); % ���㵱ǰλ�ô��ؽڽǶ�ֵ
    
    % ������ſ˱Ⱦ���
    Jarr(:, :, stepnum) = jacobiananalytical(joint(stepnum, :), deboorp(1, 4), deboorp(1, 5));  
    p = scanpders(stepnum, 1:6);
    % �������T
    T(1:3, 1:3, stepnum) = eye(3);
    T(4:6, 4:6, stepnum) = [0, -sin(p(4)), cos(p(4)) * sin(p(5));
               0, cos(p(4)), sin(p(4)) * sin(p(5));
               1, 0, cos(p(5))];
    
    % ����dT/dA
    TderA(4, 5, stepnum) = -cos(p(4));
    TderA(4, 6, stepnum) = -sin(p(4)) * sin(p(5));
    TderA(5, 5, stepnum) = -sin(p(4));
    TderA(5, 6, stepnum) = cos(p(4)) * sin(p(5));
    
    % ����dT/dE
    TderE(4, 6, stepnum) = -cos(p(4)) * cos(p(5));
    TderE(5, 6, stepnum) = sin(p(4)) * cos(p(5));
    TderE(6, 6, stepnum) = -sin(p(5));
    
    % ��dJ/d theta j
    for j = 1:6
        Jder(:, :, j, stepnum) = Jdifferentiation_j(joint(stepnum, :), j);
    end
    
    pathderunit = deboorp(2, :) / norm(deboorp(2, 1:3));    % �õ���λ�����ٶ���
    pathderunit(4:6) = pathderunit(4:6) / 180 * pi;
        
    temp = Jarr(:, :, stepnum) \ pathderunit';
    v = min(abs(axismaxvel) ./ abs(temp'));  % ������ݸ�������ٶ�Լ����
    v = min(maxfeedrate, v);
    
    while 1
        unext = u + v * Ts / norm(deboorp(2, 1:3));
        deboorpnext = DeBoorCoxNurbsCal(unext, BSplinepath, 1);

        g2 = Tu * enlerangle2rotatemat(deboorpnext(1, 1:3), deboorpnext(1, 4:6)) / Tt;    

        theta2 = inversekinamicsDH2(g2); % �˶�ѧ���
        % ѡ�⣬��������������һλ�ùؽڱ仯��С�ĵ���Ϊ��
        mindis = 100;
        minindex = 1;

        for j = 1:size(theta2, 1)
            % �ڶ����㿪ʼѡ������һλ������ĵ�
            if norm(theta2(j, :) - joint(stepnum, :)) < mindis
                minindex = j;
                mindis = norm(theta2(j, :) - joint(stepnum, :));
            end
        end

        jointnext = theta2(minindex, :); % ���㵱ǰλ�ô��ؽڽǶ�ֵ

        jointmid = (jointnext + joint(stepnum, :)) / 2; % ȡ�ؽ�λ���е�

        gmid = forwardkinamicsDH(jointmid); % ���������˶�ѧ���õ�ĩ��λ�õ�
        pmid = gmid(1:3, 4);

        % ����ؽ�λ���е㵽С�߶εľ���
        pu = g(1:3, 4);
        punext = g2(1:3, 4);
        error(stepnum) = norm(cross(pmid - pu, punext - pu)) / norm(punext - pu);
        
        if error(stepnum) < chorderror
            break;
        end
        v = v * 0.9;
        fprintf([num2str(stepnum) '\n']);
    end    
    feedratemax(stepnum, 1) = u;
    feedratemax(stepnum, 2) = v;
    
    stepnum = stepnum + 1;
end

for i = length(uarr):-1:1
    p = scanpders(i, 1:6);      % �ѿ����ռ�λ��
    pd = scanpders(i, 7:12);    % �ѿ����ռ�·��һ�׵�
    pdd = scanpders(i, 13:18);  % �ѿ����ռ�·�����׵�
    jp = joint(i, :);           % �ؽڿռ�λ��
    Ja = Jarr(:, :, i);         % �����ſ˱�
    
    pdnorm = pd / norm(pd(1:3));    % ��һ�׵���λ��������Ϊ������
    pdnorm(4:6) = pdnorm(4:6) * pi / 180;
    pddnorm = pdd / norm(pdd(1:3)); % �����׵���λ��������Ϊ������
    pddnorm(4:6) = pddnorm(4:6) * pi / 180;
    
    
    
end

aa = 1;
