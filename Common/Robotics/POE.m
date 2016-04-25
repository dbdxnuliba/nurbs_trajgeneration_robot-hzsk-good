function m = POE(w, p, theta)
% ����ת������w, v = -w x q��theta�����Ӧ����α任����

% ��w, v ��Ϊ������
% wc = zeros(3, 1);
% vc = zeros(3, 1);
% 
% for i = 1:3
%     wc(i) = w(i);
%     vc(i) = v(i);
% end
v = -cross(w, p);
wc = w.';
vc = v.';

R = eye(3) + hatm(w) * sin(theta) + hatm(w) * hatm(w) * (1 - cos(theta));

q = (eye(3) - R) * cross(wc, vc) +  wc * dot(w, v) * theta;


m(1:3, 1:3) = R;
m(1:3, 4) = q;
m(4, 4) = 1;