function Qi = getQi2(pi, i)
% �����ż��Ԫ��

global lastEigVector;   % ���������ϴε����������������ж�������������
global EigVectorSign;   % �����������ŵ�ѡ���־
global p0;
global V1;

p1 = [p0 V1];
% ������ת��
k = cross(p1(4:6), pi(4:6));
k = k / norm(k);

% ������ת�Ƕ�
sita = asin(norm(cross(p1(4:6), pi(4:6))));

% ����Ҫ�����жϣ����Ƿ���Ҫ���б��
if EigVectorSign == 1
	k = -k;
    sita = -sita;
end

% ����Ҫע�⣬�������������ķ��ſ����ɸ�����ȡֵ��ʱ��Ҫע�⣬����ѡȡ����һ����ı任��������������������
if norm(k - lastEigVector) > norm(k + lastEigVector)
	k = -k;
    sita = -sita;
end
lastEigVector = k;

Qi(1:4) = [cos(sita / 2), sin(sita / 2) * k];   % ������ת��Ԫ��

Qi(5:8) = (quatmultiply(Qi(1 : 4), [0, p1(1:3)]) - quatmultiply([0, pi(1:3)], Qi(1 : 4))) / 2;  % �����ż�� R = (Q*p1 - pi*Q) / 2;

% �ж�
if i == 1
	Q1(1:4) = Qi(1:4);
    Q1(2:4) = -Q1(2:4);
    
    Q1(5:8) = (quatmultiply(Q1(1 : 4), [0, p1(1:3)]) - quatmultiply([0, pi(1:3)], Q1(1 : 4))) / 2;
%     Q1(5:8) = -quatmultiply(D, Q1(1:4)) / 2;
	
	p11 = TransformViaQ(p1, Qi);
    p12 = TransformViaQ(p1, Q1);
	
	dis1 = norm(p11(1:3) - pi(1:3));
    dis2 = norm(p12(1:3) - pi(1:3));
    
    if dis1 > dis2
        EigVectorSign = 1;
        Qi = Q1;
        lastEigVector = -lastEigVector;
    end
end