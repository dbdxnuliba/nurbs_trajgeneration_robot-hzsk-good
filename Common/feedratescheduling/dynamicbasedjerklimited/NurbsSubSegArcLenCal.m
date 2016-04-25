function arcLengthVector = NurbsSubSegArcLenCal(subSegmentUPara, dualquatpath)
% ��������ɭ��ʽ+���ֵ�����ÿ�λ���
% �����arcLengthVector ��ǰ��Ϊÿ�Ӷεĳ��ȣ����һ������Ϊ��·�ܳ�

global KnotVector;  % �ڵ�����
global CP;      % ���Ƶ�
global curveDegree; % ���߽���
global p0;
global V0;

global simpsonVectorIndex;  % �˱���Ϊ�����ݵ������
simpsonVectorIndex = 1;

KnotVector = dualquatpath.knotvector;
CP = dualquatpath.controlp;
curveDegree = dualquatpath.splineorder;

if size(CP, 2) == 8
    p0 = dualquatpath.tip0;
    V0 = dualquatpath.vector0;
end

% ����ȫ�ֱ��������������Ӷλ���ʱ��
global arcLength;
arcLength = 0;

arcLengthWhole = 0;

% �Ӷ���
subSegmentNum = length(subSegmentUPara) - 1;

% ��ʼ��
arcLengthVector = zeros(1, subSegmentNum + 1);

for tempLoopIndex = 1:subSegmentNum
    
    %%
    
	% ��ʼ�����ֶγ��ȼ������õ���ֵ
    startPoint = subSegmentUPara(tempLoopIndex);
    endPoint = subSegmentUPara(tempLoopIndex + 1);
	
	arcLength = 0;	% �ܳ������㣬�Խ�����һ�ε���
    
    IterativeCalArcLength2(startPoint, endPoint);	% ���������Ӷλ���
	
	arcLengthVector(tempLoopIndex) = arcLength;		% �����Ӷλ���
	
	arcLengthWhole = arcLengthWhole + arcLength;	% �ۼ��ܳ���
end

arcLengthVector(subSegmentNum + 1) = arcLengthWhole;