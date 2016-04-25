function [curvature, chordErr] = CurrentStepCurvature(currentStepFeed, deBoorP)
% ���㵱ǰ������ֵ���������

global interpolationPeriod;

curvature = norm(cross(deBoorP(2, 1:3), deBoorP(3, 1:3))) / (norm(deBoorP(2, 1:3)))^3;

chordErr = (currentStepFeed * interpolationPeriod)^2 * curvature / 8;