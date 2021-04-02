clc; clear all; close all;
warning off all;
%% �����ܣ�Part3ʶ��
I = imread('photo_3.bmp');

%% ͼ���С��������Աȶ���ǿ 
if size(I, 1) > 2000
    I = imresize(I, 0.2, 'bilinear');
end
% �Աȶ���ǿ ��
I1 = imadjust(I, [0 0.6], [0 1]); 
figure 
subplot(2, 1, 1); imshow(I, []); title('ԭͼ��', 'FontWeight', 'Bold');
subplot(2, 1, 2); imshow(I1, []); title('�Աȶ���ǿ ', 'FontWeight', 'Bold');
 
%% ͼ���˲�
% ��˹�˲����ڴ�С��
hsize = [3 3];
% ��˹�˲���׼���С ��
sigma = 0.5; 
h = fspecial('gaussian', hsize, sigma);
I2 = imfilter(I1, h, 'replicate');
 
figure 
subplot(2,2, 1); imshow(I1, []); title('�˲�ǰͼ��', 'FontWeight', 'Bold');
subplot(2,2, 2); imshow(I2, []); title('��˹��ͼ��', 'FontWeight', 'Bold');
 % ��ֵ�˲���
image1(:,:,1) = medfilt2(I1(:,:,1));   
image1(:,:,2) = medfilt2(I1(:,:,2));  
image1(:,:,3) = medfilt2(I1(:,:,3));  
subplot(223)
imshow(image1, []);
title('��ֵ�˲�') 

% ��ֵ�˲���
a = [1 1 1                                
    1 1 1
    1 1 1];
a = a./9;
image2   = imfilter(I1, a, 'replicate');  
subplot(224)
imshow(image2, []);
title('��ֵ�˲�')
 
%%  �ҶȻ�
I3 = rgb2gray(I2);
figure;
subplot(221);imshow(I2);title('ԭͼ��') 
subplot(222);imshow(I3);title('�ҶȻ�') 

%% ��ֵ��
% bw1 = im2bw(I3, graythresh(I3));
bw1 = im2bw(I3,0.72);
bw2 = ~bw1;
subplot(223);imshow(bw2);title('��ֵ��') 

%% ��Ե
edgebw = edge(I3);
subplot(224);imshow(edgebw);title('��Եͼ��') 

%% hough�任��ֱ��   
[H, T, R] = hough(edgebw);
P = houghpeaks(H, 4, 'threshold', ceil(0.1*max(H(:))));
lines = houghlines(edgebw, T, R, P, 'FillGap', 20, 'MinLength', 200);
% �����ֱ�ߣ�
max_len = 0;
for k = 1 : length(lines)
    xy = [lines(k).point1; lines(k).point2]; 
    len = norm(lines(k).point1-lines(k).point2); 
    Len(k) = len;
    if len > max_len
        max_len = len;
        xy_long = xy;
    end
    XY{k} = xy; % �洢��Ϣ��
end
% ��ʾ�����
figure 
subplot(2, 2, 1); imshow(edgebw); title('��Եͼ��', 'FontWeight', 'Bold');
subplot(2, 2, 2); imshow(H, [], 'XData', T, 'YData', R, 'InitialMagnification', 'fit');
xlabel('\theta'); ylabel('\rho');
axis on; axis normal; title('����任��', 'FontWeight', 'Bold')
subplot(2, 2, 3); imshow(I1); title('ԭͼ��', 'FontWeight', 'Bold');
subplot(2, 2, 4); imshow(I1); title('�ֱ�߱��', 'FontWeight', 'Bold');
hold on;
plot(xy_long(:,1), xy_long(:,2), 'LineWidth', 2, 'Color', 'b');
 
%%  ����ֱ�߼�����б�Ƕ�
x1 = xy_long(:, 1);
y1 = xy_long(:, 2);
K1 = -(y1(2)-y1(1))/(x1(2)-x1(1));
angle = atan(K1)*180/pi;
angle = 0;

%%  ������б�Ƕ�У��ͼ��
I4 = imrotate(I1,  1*angle, 'bilinear');
bw3 = imrotate(bw2,1*angle, 'bilinear'); 
figure 
subplot(2, 2, 1); imshow(I1, []); title('ԭͼ��', 'FontWeight', 'Bold');
subplot(2, 2, 3); imshow(bw2, []); title('ԭ��ֵͼ��', 'FontWeight', 'Bold');
subplot(2, 2, 2); imshow(I4, []); title('У��ͼ��', 'FontWeight', 'Bold');
subplot(2, 2, 4); imshow(bw3, []); title('У����ֵͼ��', 'FontWeight', 'Bold');
 
%%  ��̬ѧ�˲�
% ȥ��С�������
bw4 = bwareaopen(bw3, round(0.011*numel(bw3)/100));
% ȥ����������� ��
bw4 = removelarge(bw4, round(0.035*numel(bw3)/100));

figure 
subplot(1, 2, 1); imshow(bw3, []); title('������ͼ��', 'FontWeight', 'Bold');
subplot(1, 2, 2); imshow(bw4, []); title('�˲�ͼ��', 'FontWeight', 'Bold');
 


%% ��ͨ����
[L1, num1] = bwlabel(bw4);
stats1 = regionprops(L1);

[r1, c1] = find(bw4);
Loc2 = max(c1)+5;
% ���˵��ߣ�
Line1 = [1 mean(xy_long(:, 2)); size(bw4, 2) mean(xy_long(:, 2))];
% �Ҳ���ߣ�
% Line2 = [Loc2 1; Loc2 size(bw4, 1)];
Line2 = [Loc2 1; Loc2 750];
 
figure 
imshow(I4, []); title('���ͼ��', 'FontWeight', 'Bold');
hold on;
for i = 1 : num1
    temp = stats1(i).Centroid;
    plot(temp(1), temp(2), 'y.','markersize',22);
end
plot(Line1(:,1), Line1(:,2), 'LineWidth', 2, 'Color', 'y');
plot(Line2(:,1), Line2(:,2), 'LineWidth', 2, 'Color', 'y');
hold off;


%%  ����
%% ���ŵ������ߵ��� 
stepdist = 8;
ym1_4 = Line1(1, 2)+stepdist;
ym2_4 = Line1(1, 2)+stepdist+25*1;
ym3_4 = Line1(1, 2)+stepdist+25*2;
ym4_4 = Line1(1, 2)+stepdist+25*3;
ym5_4 = Line1(1, 2)+stepdist+25*4;
ym6_4 = Line1(1, 2)+stepdist+25*5;
stepdist = 186;
ym7_4 = Line1(1, 2)+stepdist;
ym8_4 = Line1(1, 2)+stepdist+25*1;
ym9_4 = Line1(1, 2)+stepdist+25*2;
ym10_4 = Line1(1, 2)+stepdist+25*3;
ym11_4 = Line1(1, 2)+stepdist+25*4;
ym12_4 = Line1(1, 2)+stepdist+25*5;
stepdist = 366;
ym13_4 = Line1(1, 2)+stepdist;
ym14_4 = Line1(1, 2)+stepdist+25*1;
ym15_4 = Line1(1, 2)+stepdist+25*2;
ym16_4 = Line1(1, 2)+stepdist+25*3;
ym17_4 = Line1(1, 2)+stepdist+25*4;
ym18_4 = Line1(1, 2)+stepdist+25*5;
stepdist = 540;
ym19_4 = Line1(1, 2)+stepdist;
ym20_4 = Line1(1, 2)+stepdist+25*1;
ym21_4 = Line1(1, 2)+stepdist+25*2;
ym22_4 = Line1(1, 2)+stepdist+25*3;
ym23_4 = Line1(1, 2)+stepdist+25*4;
ym24_4 = Line1(1, 2)+stepdist+25*5;


% ���ŵ������ߣ�
Linem1_4 = [Line1(1, 1) ym1_4; Line1(2, 1) ym1_4];
Linem2_4 = [Line1(1, 1) ym2_4; Line1(2, 1) ym2_4];
Linem3_4 = [Line1(1, 1) ym3_4; Line1(2, 1) ym3_4];
Linem4_4 = [Line1(1, 1) ym4_4; Line1(2, 1) ym4_4];
Linem5_4 = [Line1(1, 1) ym5_4; Line1(2, 1) ym5_4];
Linem6_4 = [Line1(1, 1) ym6_4; Line1(2, 1) ym6_4]; 
Linem7_4 = [Line1(1, 1) ym7_4; Line1(2, 1) ym7_4];
Linem8_4 = [Line1(1, 1) ym8_4; Line1(2, 1) ym8_4];
Linem9_4 = [Line1(1, 1) ym9_4; Line1(2, 1) ym9_4];
Linem10_4 = [Line1(1, 1) ym10_4; Line1(2, 1) ym10_4];
Linem11_4 = [Line1(1, 1) ym11_4; Line1(2, 1) ym11_4];
Linem12_4 = [Line1(1, 1) ym12_4; Line1(2, 1) ym12_4];
Linem13_4 = [Line1(1, 1) ym13_4; Line1(2, 1) ym13_4];
Linem14_4 = [Line1(1, 1) ym14_4; Line1(2, 1) ym14_4]; 
Linem15_4 = [Line1(1, 1) ym15_4; Line1(2, 1) ym15_4]; 
Linem16_4 = [Line1(1, 1) ym16_4; Line1(2, 1) ym16_4]; 
Linem17_4 = [Line1(1, 1) ym17_4; Line1(2, 1) ym17_4]; 
Linem18_4 = [Line1(1, 1) ym18_4; Line1(2, 1) ym18_4]; 
Linem19_4 = [Line1(1, 1) ym19_4; Line1(2, 1) ym19_4]; 
Linem20_4 = [Line1(1, 1) ym20_4; Line1(2, 1) ym20_4]; 
Linem21_4 = [Line1(1, 1) ym21_4; Line1(2, 1) ym21_4]; 
Linem22_4 = [Line1(1, 1) ym22_4; Line1(2, 1) ym22_4]; 
Linem23_4 = [Line1(1, 1) ym23_4; Line1(2, 1) ym23_4]; 
Linem24_4 = [Line1(1, 1) ym24_4; Line1(2, 1) ym24_4]; 

%% ���ŵ�������
stepdist = - 18;
xm2_0 = Line2(1, 1) -stepdist;
xm2_1 = Line2(1, 1) -stepdist-26*1;
xm2_2 = Line2(1, 1) -stepdist-26*2;
xm2_3 = Line2(1, 1) -stepdist-26*3;
xm2_4 = Line2(1, 1) -stepdist-26*4;
xm2_5 = Line2(1, 1) -stepdist-26*5;
xm2_6 = Line2(1, 1) -stepdist-26*6;
xm2_7 = Line2(1, 1) -stepdist-26*7;
xm2_8 = Line2(1, 1) -stepdist-26*8;
xm2_9 = Line2(1, 1) -stepdist-26*9;
xm2_10 = Line2(1, 1) -stepdist-26*10;

Linem2_0_2 = [xm2_0 Line2(1, 2); xm2_0 Line2(2, 2)];
Linem2_1_2 = [xm2_1 Line2(1, 2); xm2_1 Line2(2, 2)];
Linem2_2_2 = [xm2_2 Line2(1, 2); xm2_2 Line2(2, 2)];
Linem2_3_2 = [xm2_3 Line2(1, 2); xm2_3 Line2(2, 2)];
Linem2_4_2 = [xm2_4 Line2(1, 2); xm2_4 Line2(2, 2)];
Linem2_5_2 = [xm2_5 Line2(1, 2); xm2_5 Line2(2, 2)];
Linem2_6_2 = [xm2_6 Line2(1, 2); xm2_6 Line2(2, 2)];
Linem2_7_2 = [xm2_7 Line2(1, 2); xm2_7 Line2(2, 2)];
Linem2_8_2 = [xm2_8 Line2(1, 2); xm2_8 Line2(2, 2)];
Linem2_9_2 = [xm2_9 Line2(1, 2); xm2_9 Line2(2, 2)];
Linem2_10_2 = [xm2_10 Line2(1, 2); xm2_10 Line2(2, 2)];

figure 
imshow(I4, []); title('����ͼ��', 'FontWeight', 'Bold');
hold on;
plot(Linem1_4(:, 1), Linem1_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_4(:, 1), Linem2_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem3_4(:, 1), Linem3_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem4_4(:, 1), Linem4_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem5_4(:, 1), Linem5_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem6_4(:, 1), Linem6_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem7_4(:, 1), Linem7_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem8_4(:, 1), Linem8_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem9_4(:, 1), Linem9_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem10_4(:, 1), Linem10_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem11_4(:, 1), Linem11_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem12_4(:, 1), Linem12_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem13_4(:, 1), Linem13_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem14_4(:, 1), Linem14_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem15_4(:, 1), Linem15_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem16_4(:, 1), Linem16_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem17_4(:, 1), Linem17_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem18_4(:, 1), Linem18_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem19_4(:, 1), Linem19_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem20_4(:, 1), Linem20_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem21_4(:, 1), Linem21_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem22_4(:, 1), Linem22_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem23_4(:, 1), Linem23_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem24_4(:, 1), Linem24_4(:, 2), 'b-', 'LineWidth', 1);

plot(Linem2_0_2(:, 1), Linem2_0_2(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_1_2(:, 1), Linem2_1_2(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_2_2(:, 1), Linem2_2_2(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_3_2(:, 1), Linem2_3_2(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_4_2(:, 1), Linem2_4_2(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_5_2(:, 1), Linem2_5_2(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_6_2(:, 1), Linem2_6_2(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_7_2(:, 1), Linem2_7_2(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_8_2(:, 1), Linem2_8_2(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_9_2(:, 1), Linem2_9_2(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_10_2(:, 1), Linem2_10_2(:, 2), 'b-', 'LineWidth', 1);



%% ��Ӧ����ĺ������귶Χ
Loc = [ym1_4 ym24_4];
y = [ym24_4 ym23_4 ym22_4 ym21_4 ym20_4 ym19_4...
     ym18_4 ym17_4 ym16_4 ym15_4 ym14_4 ym13_4 ym12_4 ym11_4 ym10_4...
     ym9_4 ym8_4 ym7_4 ym6_4 ym5_4 ym4_4 ...
     ym3_4 ym2_4 ym1_4];
y = sort(y);
xt{1} = [xm2_10 xm2_9 xm2_8 xm2_7 xm2_6 xm2_5 xm2_4 xm2_3 xm2_2 xm2_1 xm2_0];
x = xt;
% part 3 ����ʶ��
aw = ['A' 'B' 'C' 'D','E','F','G','H','I','J'];
for i = 1: length(stats1)  
    Answer(i).Loc = [];
    Answer(i).no = [];
    Answer(i).aw = []; 
end
i_n = 1;
for i = 1 : length(stats1)
    temp = stats1(i).Centroid; 
    flag1 = 0;
    flag2 = 0;
    i_x = 1;
    i_y = 1;
    hold on
    plot(temp(1), temp(2), 'r*');
        if temp(2) >= Loc(1) && temp(2) <= Loc(2)
            i_y = 20;
            for i2 = 1 : length(x)
                xt = x{i2};
                for i3 = 1 : length(xt)-1
                    if temp(1) >= xt(i3) && temp(1) <= xt(i3+1)
                        i_x = (i2-1)*5 + i3;
                        i_a = aw(i3);
                        flag1 = 1;
                        break;
                    end
                end
            end
            for i4 = 1 : length(y)-1
                if temp(2) >= y(i4) && temp(2) <= y(i4+1)
                     flag2 = 1;
                    break;
                end
            end
             if  flag1 == 1 &&  flag2 == 1
                Answer(i_n).Loc = [Answer(i_n).Loc; temp];
                Answer(i_n).aw = [Answer(i_n).aw i_a];
                i_n = i_n + 1;
             end
        end
end

 %% ����÷�
% ��׼�𰸣�
 biaozhundaan = {'A' 'B' 'B' 'B' 'B'   'B' 'B' 'B' 'C' 'B'    'B' 'B' 'C' 'C' 'C'   'C' 'D' 'D' 'D' 'D'};   
score = 0;     
count = 1;
 for i = 1 : length(Answer)
        if ~isempty(Answer(i).Loc)
            tempi = Answer(i).Loc; 
            awi = Answer(i).aw;
            for j = 1 : size(tempi, 1)
                tempij = tempi(j, :);
                awij = awi(j);
                if strcmp(awij,biaozhundaan{1,count}) 
                    % ÿ��2�� ���˼ӷ֣�
                    score = score + 2;
                    text(tempij(1), tempij(2), awij, 'color', 'b');
                else
                   text(tempij(1), tempij(2), [ awij '������ȷ��Ϊ' biaozhundaan{1,count}], 'color', 'r');
                end
                count = count+1;
            end
        end
 end
 
%% ��һ���ֵ���Ŀ
%%���ŵ������ߵ��� ��
stepdist = 715;
ym1_4 = Line1(1, 2)+stepdist;
ym2_4 = Line1(1, 2)+stepdist+25*1;
ym3_4 = Line1(1, 2)+stepdist+25*2;
ym4_4 = Line1(1, 2)+stepdist+25*3;
ym5_4 = Line1(1, 2)+stepdist+25*4;
ym6_4 = Line1(1, 2)+stepdist+25*5;
% ���ŵ������ߣ�
Linem1_4 = [Line1(1, 1) ym1_4; Line1(2, 1) ym1_4];
Linem2_4 = [Line1(1, 1) ym2_4; Line1(2, 1) ym2_4];
Linem3_4 = [Line1(1, 1) ym3_4; Line1(2, 1) ym3_4];
Linem4_4 = [Line1(1, 1) ym4_4; Line1(2, 1) ym4_4];
Linem5_4 = [Line1(1, 1) ym5_4; Line1(2, 1) ym5_4];
Linem6_4 = [Line1(1, 1) ym6_4; Line1(2, 1) ym6_4]; 

%% ���ŵ�������
stepdist = - 22;
xm2_0 = Line2(1, 1) -stepdist;
xm2_1 = Line2(1, 1) -stepdist-26*1;
xm2_2 = Line2(1, 1) -stepdist-26*2;
xm2_3 = Line2(1, 1) -stepdist-26*3;
xm2_4 = Line2(1, 1) -stepdist-26*4;
xm2_5 = Line2(1, 1) -stepdist-26*5;
xm2_6 = Line2(1, 1) -stepdist-26*6;
xm2_7 = Line2(1, 1) -stepdist-26*7;
xm2_8 = Line2(1, 1) -stepdist-26*8;
xm2_9 = Line2(1, 1) -stepdist-26*9;
xm2_10 = Line2(1, 1) -stepdist-26*10;

Linem2_0_2 = [xm2_0 750; xm2_0 size(bw4, 1)];
Linem2_1_2 = [xm2_1 750; xm2_1 size(bw4, 1)];
Linem2_2_2 = [xm2_2 750; xm2_2 size(bw4, 1)];
Linem2_3_2 = [xm2_3 750; xm2_3 size(bw4, 1)];
Linem2_4_2 = [xm2_4 750; xm2_4 size(bw4, 1)];
Linem2_5_2 = [xm2_5 750; xm2_5 size(bw4, 1)];
Linem2_6_2 = [xm2_6 750; xm2_6 size(bw4, 1)];
Linem2_7_2 = [xm2_7 750; xm2_7 size(bw4, 1)];
Linem2_8_2 = [xm2_8 750; xm2_8 size(bw4, 1)];
Linem2_9_2 = [xm2_9 750; xm2_9 size(bw4, 1)];
Linem2_10_2 = [xm2_10 750; xm2_10 size(bw4, 1)];
 
plot(Linem1_4(:, 1), Linem1_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_4(:, 1), Linem2_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem3_4(:, 1), Linem3_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem4_4(:, 1), Linem4_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem5_4(:, 1), Linem5_4(:, 2), 'b-', 'LineWidth', 1);
plot(Linem6_4(:, 1), Linem6_4(:, 2), 'b-', 'LineWidth', 1);
 
plot(Linem2_0_2(:, 1), Linem2_0_2(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_1_2(:, 1), Linem2_1_2(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_2_2(:, 1), Linem2_2_2(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_3_2(:, 1), Linem2_3_2(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_4_2(:, 1), Linem2_4_2(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_5_2(:, 1), Linem2_5_2(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_6_2(:, 1), Linem2_6_2(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_7_2(:, 1), Linem2_7_2(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_8_2(:, 1), Linem2_8_2(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_9_2(:, 1), Linem2_9_2(:, 2), 'b-', 'LineWidth', 1);
plot(Linem2_10_2(:, 1), Linem2_10_2(:, 2), 'b-', 'LineWidth', 1);



%% ��Ӧ����ĺ������귶Χ
Loc = [ym1_4 ym6_4];
y = [ym6_4 ym5_4 ym4_4 ...
     ym3_4 ym2_4 ym1_4];
y = sort(y);
xt = [];
xt{1} = [xm2_10 xm2_9 xm2_8 xm2_7 xm2_6];
xt{2} = [xm2_4 xm2_3 xm2_2 xm2_1 xm2_0];
x = xt;
% part 3 ����ʶ��
aw = ['A' 'B' 'C' 'D','E','F','G','H','I','J'];
for i = 1: length(stats1)  
    Answer(i).Loc = [];
    Answer(i).no = [];
    Answer(i).aw = []; 
end
i_n = 1;
for i = 1 : length(stats1)
    temp = stats1(i).Centroid; 
    flag1 = 0;
    flag2 = 0;
    i_x = 1;
    i_y = 1;
    hold on
    plot(temp(1), temp(2), 'r*');
        if temp(2) >= Loc(1) && temp(2) <= Loc(2)
            i_y = 20;
            for i2 = 1 : length(x)
                xt = x{i2};
                for i3 = 1 : length(xt)-1
                    if temp(1) >= xt(i3) && temp(1) <= xt(i3+1)
                        i_x = (i2-1)*5 + i3;
                        i_a = aw(i3);
                        flag1 = 1;
                        break;
                    end
                end
            end
            for i4 = 1 : length(y)-1
                if temp(2) >= y(i4) && temp(2) <= y(i4+1)
                     flag2 = 1;
                    break;
                end
            end
             if  flag1 == 1 &&  flag2 == 1
                Answer(i_n).Loc = [Answer(i_n).Loc; temp];
                Answer(i_n).aw = [Answer(i_n).aw i_a];
                i_n = i_n + 1;
             end
        end
end
%% ����÷�
% ��׼�𰸣�
 biaozhundaan = {'B' 'B' 'B' 'C' 'D'   'A' 'B' 'B' 'B' 'C' };      
count = 1;
 for i = 1 : length(Answer)
        if ~isempty(Answer(i).Loc)
            tempi = Answer(i).Loc; 
            awi = Answer(i).aw;
            for j = 1 : size(tempi, 1)
                tempij = tempi(j, :);
                awij = awi(j);
                if strcmp(awij,biaozhundaan{1,count}) 
                    % ÿ��2�� ���˼ӷ֣�
                    score = score + 2;
                    text(tempij(1), tempij(2), awij, 'color', 'b');
                else
                   text(tempij(1), tempij(2), [ awij '������ȷ��Ϊ' biaozhundaan{1,count}], 'color', 'r');
                end
                count = count+1;
            end
        end
 end
  disp(['�ܷ֣�' num2str(score)])
 