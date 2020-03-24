function [pos2] = find_matches(I1, pos1, I2)
    I1_G = rgb2gray(I1);
    I2_G = rgb2gray(I2);

    method = ["BRISK", "FAST", "Harris", "MinEigen", "MSER", "SURF", "KAZE"];

    for i = 1 : length(method)
        eval(strcat('detector1_', method(i), '=detect', method(i), 'Features(I1_G);'));
        eval(strcat('detector2_', method(i), '=detect', method(i), 'Features(I2_G);'));
        eval(strcat('pos1_', method(i), '=detector1_', method(i), ';'));
        eval(strcat('pos2_', method(i), '=detector2_', method(i), ';'));
    end

    for i = 1 : length(method)
        if (i > 1 && i < 5)
            me = 'FREAK';
        elseif (i == 5)
            me = 'SURF';
        else
            me = method(i);
        end
        eval(strcat('[features1_', method(i), ', valid_points1_', method(i), '] = extractFeatures(I1_G, pos1_', method(i), ", 'Method', ", "'", me, "');"));
        eval(strcat('[features2_', method(i), ', valid_points2_', method(i), '] = extractFeatures(I2_G, pos2_', method(i), ", 'Method', ", "'", me, "');"));
    
        eval(strcat('indexPairs_', method(i), ' = matchFeatures(features1_', method(i), ', features2_', method(i), ');'));
        eval(strcat('matchedPoints1_', method(i), ' = valid_points1_', method(i), '(indexPairs_', method(i), '(:,1),:);'));
        eval(strcat('matchedPoints2_', method(i), ' = valid_points2_', method(i), '(indexPairs_', method(i), '(:,2),:);'));

    end

    matchedPoints1 = [matchedPoints1_BRISK.Location; matchedPoints1_FAST.Location; matchedPoints1_Harris.Location; matchedPoints1_MinEigen.Location; matchedPoints1_MSER.Location; matchedPoints1_SURF.Location; matchedPoints1_KAZE.Location];
    matchedPoints2 = [matchedPoints2_BRISK.Location; matchedPoints2_FAST.Location; matchedPoints2_Harris.Location; matchedPoints2_MinEigen.Location; matchedPoints2_MSER.Location; matchedPoints2_SURF.Location; matchedPoints2_KAZE.Location];

    [matchedPoints1, a] = unique(matchedPoints1, 'rows');
    matchedPoints2 = matchedPoints2(a, :);

    [tform, matchedPoints1, matchedPoints2] = estimateGeometricTransform(matchedPoints1, matchedPoints2, 'projective');

    sub_pos1 = [];
    sub_pos2 = [];
    closest1 = [];
    closest2 = [];

    for i = 1 : size(pos1, 1)
        [Lia, Locb] = ismember(pos1(i, :), matchedPoints1, 'rows');
        [minValue, row] = cloest(matchedPoints1, pos1(i, :));
        closest1 = [closest1; matchedPoints1(row, :)];
        closest2 = [closest2; matchedPoints2(row, :)];
        if (Lia == 1)
            sub_pos1 = [sub_pos1; pos1(i, :)];
            sub_pos2 = [sub_pos2; matchedPoints2(Locb, :)];
%         elseif (minValue < 10 && minValue == 10)
%             sub_pos1 = [sub_pos1; pos1(i, :)];
%             sub_pos2 = [sub_pos2; matchedPoints2(row, :)];
        end
    end

    pos2 = zeros(size(pos1, 1), size(pos1, 2));
   
    for i = 1 : size(pos1, 1)
        if (size(sub_pos1, 1) ~= 0)
            [Lia, Locb] = ismember(pos1(i, :), sub_pos1, 'rows');
        end
        if (size(sub_pos1, 1) == 0 || Lia == 0)
            x = pos1(i, 1) + (closest2(i, 1) - closest1(i, 1));
            y = pos1(i, 2) + (closest2(i, 2) - closest1(i, 2));
            pos2(i, :) = [x, y];
        elseif (Lia == 1)
            pos2(i, :) = sub_pos2(Locb, :);
        end
    end

%     figure; showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2);
%     figure; showMatchedFeatures(I1, I2, pos1, pos2);
    
end

function [minValue, row] = cloest(target, source)
    [N, M] = size(target);
    dis = zeros([1, N]);
    dis = sqrt(source.^2 * ones(size(target')) + ones(size(source)) * (target').^2 - 2 * source * target');
    [minValue, row] = min(dis);
end