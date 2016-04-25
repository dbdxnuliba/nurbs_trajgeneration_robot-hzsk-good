clear;
close all;

addpath('../Data/Input');
addpath('../Common');

% pathdata = importdata('toolpath.txt');
pathdata = importdata('pathvol.txt');

F = 20;
Ts = 0.005;

toolcoor = [352.64,0.00,469.28,0.00,60.00,180.00];  % ��������ϵ����
usercoor = [1613.56, 0, 780, 0, 0, 0];              % �û�����ϵ����

Tu = enlerangle2rotatemat(usercoor(1:3), usercoor(4:6));    % ����Ӧ
Tt = enlerangle2rotatemat(toolcoor(1:3), toolcoor(4:6));

lastjointpos = [0, 0, -pi / 2, 0, 0, 0];    % ������һ�ؽڿռ�Ϊλ�ã���������ʱ��ѡ����

maxindex = 1;
maxdis = 1000;

interp = linearconstspeedinterp(pathdata, F, Ts);

h = figure;
for k = 1:size(interp, 1) / 200
    i = k * 200;
    maxindex = 1;
    maxdis = 1000;
    
    Ttpos = enlerangle2rotatemat(interp(i, 1:3), interp(i, 4:6)); % �����û�����ϵ�µ�λ��
    Tbase = Tu * Ttpos / Tt;    % �任��������ϵ�µĻ�����ĩ�˴��������������˶�ѧ���
    
    jp = inversekinamicsDH(Tbase);
    
    for j = 1:size(jp, 1)
        temp = norm(jp(j, :) - lastjointpos);
        if temp < maxdis
            maxindex = j;
            maxdis = temp;
        end
    end
    joint(k, :) = jp(maxindex, :);
    
    drawrobotpos(joint(k, :), h);
%     drawnow;
%     pause(0.3);
    
    lastjointpos = jp(maxindex, :);
end

% ���÷����ؽڿռ��е�λ�ý��й켣�滮
