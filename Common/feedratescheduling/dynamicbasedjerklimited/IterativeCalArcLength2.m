function IterativeCalArcLength2(startPoint, endPoint)
% ���������Ӷλ���

global arcLength;

global simpsonVector;       % ��������������ɭ��ʽ�������������(u, l)ֵ
global simpsonVectorIndex;  % �˱���Ϊ�����ݵ������

simpsonErr = 10^(-4);

% ��������ɭ���ֵ����ϰ��
midPoint = (startPoint + endPoint) / 2;
subStartPoint = startPoint;
subEndPoint = midPoint;
subMidPoint = (subStartPoint + subEndPoint) / 2;

subArcLengthUpHalf = ArcLengthSimpson(subStartPoint, subMidPoint);
subArcLengthLowerHalf = ArcLengthSimpson(subMidPoint, subEndPoint);
subArcToltal = ArcLengthSimpson(subStartPoint, subEndPoint);

if (abs(subArcLengthUpHalf + subArcLengthLowerHalf - subArcToltal) < simpsonErr)
	arcLength = arcLength + subArcToltal;	% �������Ҫ�����ۼ����γ���
    simpsonVector(simpsonVectorIndex, 1) = subEndPoint;
    
    if simpsonVectorIndex == 1
        simpsonVector(simpsonVectorIndex, 2) = subArcToltal;
    else
        simpsonVector(simpsonVectorIndex, 2) = simpsonVector(simpsonVectorIndex - 1, 2) + subArcToltal;
    end
    simpsonVectorIndex = simpsonVectorIndex + 1;
else
	IterativeCalArcLength2(subStartPoint, subEndPoint);	%������������Ҫ����������ֽ��е���
end

% ��������ɭ���ֵ����°��
subStartPoint = midPoint;
subEndPoint = endPoint;
subMidPoint = (midPoint + endPoint) / 2;

subArcLengthUpHalf = ArcLengthSimpson(subStartPoint, subMidPoint);
subArcLengthLowerHalf = ArcLengthSimpson(subMidPoint, subEndPoint);
subArcToltal = ArcLengthSimpson(subStartPoint, subEndPoint);

if (abs(subArcLengthUpHalf + subArcLengthLowerHalf - subArcToltal) < simpsonErr)
	arcLength = arcLength + subArcToltal;	% �������Ҫ�����ۼ����γ���
	simpsonVector(simpsonVectorIndex, 1) = subEndPoint;
	simpsonVector(simpsonVectorIndex, 2) = simpsonVector(simpsonVectorIndex - 1, 2) + subArcToltal;
else
	IterativeCalArcLength2(subStartPoint, subEndPoint);	%������������Ҫ����������ֽ��е���
end