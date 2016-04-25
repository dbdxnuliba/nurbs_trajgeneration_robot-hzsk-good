function [subSegmentUPara, subSegmentFeedPeakSmall, subSegmentFeedPeakBig] = NurbsScanning(dualquatpath)
% �����ٶȼ�ֵɨ�裬�õ��ֶ���Ϣ�����ε��ٶ������Сֵ�Լ���Ӧ�ֶε�u��ֵ

% �岹Ƶ�ʣ����岹����Ts = 0.5ms
global interpolationFrequence;
interpolationFrequence = 500;
global interpolationPeriod;
interpolationPeriod = 1 / interpolationFrequence;

Ts = interpolationPeriod;			% �岹����

global chordErr;
chordErr = 0.005;	% ��������������

global maxAcc;
global maxJerk;

maxAcc = 50;      % ����������ٶ�
maxJerk = 800;    % ��������Ծ��

global blockFeed;
blockFeed = 100; 	% ���ν����ٶ�

curvatureNurbsPreLast = 0;	% ���ϴε�����ֵ;
curvatureNurbsLast = 0; 	% �ϴε�����ֵ
curvatureNurbs = 0;			% ����ֵ
lastFiveStepFeed = zeros(1, 4);	% ǰ���Ĳ�ʱ���ٶȣ�����ʹ��5�������ٶȵ�ʸ
 
oneSubSegmentFlag = 0;	% ֻ��һ���Ӷεı�־λ
subSegmentMaxFeed = 0;	% �Ӷ�������ٶȣ�

uNurbs = 0;	% ���߲���
 
cenAccLimitedCurvature = maxAcc / blockFeed^2;	% ���ļ��ٶ��趨��������ֵ

jerkLimitedCurvature = sqrt(maxJerk / blockFeed^3);	% Ծ���趨������ֵ

% ȡ�������Ƶ���Сֵ;
curvatureLimitMin = min([1, cenAccLimitedCurvature, jerkLimitedCurvature]);

subSegmentNum = 2;
stepNumber = 1;

while uNurbs < 1
    % ������ֵ�㼰һ�����׵�ʸ

    deboorp = DeBoorCoxNurbsCal(uNurbs, dualquatpath, 2);

    % ����ֵ��
    knotCor(stepNumber, :) = deboorp(1, :);
    	
    % ���±��������ֵ;
    curvatureNurbsPreLast = curvatureNurbsLast;
	curvatureNurbsLast = curvatureNurbs;
    
    % ��ǰ�������
	curvatureNurbs = norm(cross(deboorp(2, 1:3), deboorp(3, 1:3))) / norm(deboorp(2, 1:3))^3;                        % �������ʹ�ʽ������
    
    curvetureArr(stepNumber, 1) = uNurbs;
    curvetureArr(stepNumber, 2) = curvatureNurbs;
    
    curvatureRadiusNurbs = 1 / curvatureNurbs;	% �������ʰ뾶
	
	% ����Ts�����ʰ뾶�������������ٶȣ�kcbc���ȼ���Vaf��Vcbf��ȷ��V(ui)
	chordLimitedFeed = 2 / Ts * sqrt(curvatureRadiusNurbs ^ 2 - (curvatureRadiusNurbs - chordErr)^2);
	
	adaptiveAlgorithmFeed = min([blockFeed, chordLimitedFeed]);     % Vaf
	curvatureAlgorithmFeed = 1 * blockFeed / (curvatureNurbs + 1);	% Vcbf
	
	maxAccLimitedFeed = sqrt(maxAcc / curvatureNurbs);					% ������ٶ��ٶ�Լ��	
	maxJerkLimitedFeed = (maxJerk / curvatureNurbs^2)^(1 / 3);	% ����Ծ���ٶ�Լ��
	
	% �õ�Vaf, Vbf, F �Լ����ٶȡ�Ծ��Լ���µ��ٶ���Сֵ
	currentStepFeed = min([adaptiveAlgorithmFeed, curvatureAlgorithmFeed, blockFeed, maxAccLimitedFeed, maxJerkLimitedFeed]);
	
    feedLimitArr(stepNumber) = currentStepFeed;
    
	% ����5�������ٶȵ���
	currentStepFeedDer1 = 1 / (12 * Ts) * (3 * lastFiveStepFeed(1) - 16 * lastFiveStepFeed(2) + 36 * lastFiveStepFeed(3) - 48 * lastFiveStepFeed(4) + 25 * currentStepFeed);
	% ���±����ǰ�����ٶ�
	lastFiveStepFeed = [lastFiveStepFeed(2:4), currentStepFeed];
	
	% ȷ����һ�������������浱ǰ����u
	uNurbsLast = uNurbs;
% 	uNurbs = uNurbs + (currentStepFeed * Ts + Ts^2 * currentStepFeedDer1 / 2) / norm(deboorp(2, 1:3)) - (currentStepFeed * Ts)^2 * (dot(deboorp(2, 1:3), deboorp(3, 1:3))) / (2 * (norm(deboorp(2, 1:3)))^4);
	
	if (uNurbs > uNurbsLast) && (uNurbs > 0.001)
		if (curvatureNurbsLast > curvatureNurbs) && (curvatureNurbsLast > curvatureNurbsPreLast)
			% �����������������ֵ��������ô��������Ϊһ���Ӷδ���������Ӧ�����ݣ�
			if curvatureNurbsLast >= curvatureLimitMin
				oneSubSegmentFlag = 1;
				subSegmentUPara(subSegmentNum) = uNurbsLast;
				subSegmentFeedPeakBig(subSegmentNum) = subSegmentMaxFeed;
				subSegmentFeedPeakSmall(subSegmentNum) = lastStepFeed;
                splitPoints(subSegmentNum, :) = knotCor(stepNumber, :);     % ����ֶε����꣬����鿴��
				subSegmentNum = subSegmentNum + 1;
				subSegmentMaxFeed = 0;
			end
		end
	end	
	% �����Ӷ�������ٶȣ�
	subSegmentMaxFeed = max(subSegmentMaxFeed, currentStepFeed);
	% ���浱ǰ�ٶ�ֵ��
	lastStepFeed = currentStepFeed;
    
    uNurbs = uNurbs + 0.0001;      % �����ã�������Ԥ�岹��ֱ�ӵȾ��ۼӲ���u
    stepNumber = stepNumber + 1;
end

% figure;
% % ���ƶ�ż��Ԫ����õ���������
% plot(curvetureArr(:, 1), curvetureArr(:, 2));
% % readCurvature = importdata('.\data\inputdata\Curvature.txt');
% % hold on;
% % plot(readCurvature(:, 1), readCurvature(:, 2), 'r');
% set(gca, 'fontsize', 25);
% title('Curvature');
% ylim([0 5]);
% hold on;
% % ������VC������õ���������
% curvatureVs = importdata('Curvature.txt');
% plot(curvatureVs(:, 1), curvatureVs(:, 2), 'r');
% % ������Matlabֱ�ӶԵ�����ֵ��õ���������
% load('interpolateCurvature.mat');
% plot(curvatureArr(:, 1), curvatureArr(:, 2), 'g');


if oneSubSegmentFlag == 1
	% ����Ӷε���ʼ�ٶ�Ϊ0 
	subSegmentFeedPeakSmall(1) = 0;
	% ��ĩ�Ӷε���ֹ�ٶ�Ϊ0
	subSegmentUPara(subSegmentNum) = 1;
	subSegmentFeedPeakSmall(subSegmentNum) = 0;
	subSegmentFeedPeakBig(subSegmentNum) = subSegmentMaxFeed;
else
	% ���û���ٶȹյ㣬��ô��ʼ�ٶȺ���ֹ�ٶȾ�Ϊ0����������ٶ�Ϊ���ε�����ٶ�
	subSegmentFeedPeakSmall(1) = 0;
	subSegmentUPara(subSegmentNum) = 1;
	subSegmentFeedPeakSmall(subSegmentNum) = 0;
	subSegmentFeedPeakBig(2) = subSegmentMaxFeed;
end

% figure;
% plot3(knotCor(:, 1), knotCor(:, 2), knotCor(:, 3));
% hold on;
% plot3(splitPoints(:, 1), splitPoints(:, 2), splitPoints(:, 3), '*r');
% title('split points', 'fontsize', 24);
% set(gca, 'fontsize', 25);