function drawjointcyl(xc, yc, zc, g, facecolor, pathcolor)
% ���ƴ���ؽڵ�Բ����xc, yc, zcΪ���ĵ���ԭ�㴦��Բ��
% gΪ�任����facecolorΪ������ɫ��pathcolorΪ��������ɫ

cylinderp1 = ones(4, size(xc, 2));
cylinderp2 = ones(4, size(xc, 2));

cylinderp1(1, :) = xc(1, :);
cylinderp1(2, :) = yc(1, :);
cylinderp1(3, :) = zc(1, :);

cylinderp2(1, :) = xc(2, :);
cylinderp2(2, :) = yc(2, :);
cylinderp2(3, :) = zc(2, :);

% ����任
cylinderp1rotated = g * cylinderp1;
cylinderp2rotated = g * cylinderp2;

x(1, :) = cylinderp1rotated(1, :);
x(2, :) = cylinderp2rotated(1, :);
y(1, :) = cylinderp1rotated(2, :);
y(2, :) = cylinderp2rotated(2, :);
z(1, :) = cylinderp1rotated(3, :);
z(2, :) = cylinderp2rotated(3, :);

surf(x, y, z, 'facecolor', facecolor, 'EdgeColor', 'none');  % ��������
patch(x', y', z', pathcolor, 'EdgeColor', 'none');     % ���ƶ���
