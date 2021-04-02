clc; clear all; close all;
warning off all;
%% �����ܣ����⿨1ʶ��
I = imread('photo_4.bmp');

%% ͼ���С��������Աȶ���ǿ 
if size(I, 1) > 2000
    I = imresize(I, 0.2, 'bilinear');
end
% �Աȶ���ǿ 
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
bw1 = im2bw(I3,0.62);
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

%%  ������б�Ƕ�У��ͼ��
I4 = imrotate(I1,   angle, 'bilinear');
bw3 = imrotate(bw2, angle, 'bilinear'); 
figure 
subplot(2, 2, 1); imshow(I1, []); title('ԭͼ��', 'FontWeight', 'Bold');
subplot(2, 2, 3); imshow(bw2, []); title('ԭ��ֵͼ��', 'FontWeight', 'Bold');
subplot(2, 2, 2); imshow(I4, []); title('У��ͼ��', 'FontWeight', 'Bold');
subplot(2, 2, 4); imshow(bw3, []); title('У����ֵͼ��', 'FontWeight', 'Bold');
 
%%  ��̬ѧ�˲�
% ȥ��С�������
bw4 = bwareaopen(bw3, round(0.01*numel(bw3)/100));
% ȥ����������� ��
bw4 = removelarge(bw4, round(0.035*numel(bw3)/100));

figure 
subplot(1, 2, 1); imshow(bw3, []); title('������ͼ��', 'FontWeight', 'Bold');
subplot(1, 2, 2); imshow(bw4, []); title('�˲�ͼ��', 'FontWeight', 'Bold');
 
%% ��ͨ����
pic2 = bw4;
[l,mm]=bwlabel(pic2,8);
index = [];
status =[];
test_set = [];
bound_srt = [];
m = 1;

%% ���α�Ƿָ���ַ�bing ʶ��
load model.mat
figure
imshow(I4, []); title('ʶ����', 'FontWeight', 'Bold');
results = [];
for i=1:mm 
%     ��������ȡ�ַ���
      temp = 0*pic2+1;
      [xxx,yyy] = find(l==i);
      for j = 1:length(xxx)
          temp(xxx(j),yyy(j)) = 0;
      end
%    ���ͺ����С����ӿ� ��
     [bw2,BoundingBox1,im0] = edu_imgcrop3(temp,temp,I4);
%    ���յ���С����ӿ�   ��
     BoundingBox = BoundingBox1;
%    ������� 50������ �� ��ɫռ�Ȳ���̫�󡣣�
     if BoundingBox(3)*BoundingBox(4) > 50  && sum(sum(~bw2))/(BoundingBox(3)*BoundingBox(4)) <0.4 
%          imwrite(im0,['./��ĸ��/' strcat(num2str(clock),'.jpg')])��
         status =[status;BoundingBox];
%          �׵׺��֣�
%         figure;imshow(im0)
         rectangle('position',BoundingBox,'edgecolor','b');
          bw = imresize(bw2,[28 28], 'bilinear');
  %       ��ͼ������������
         test_set = double(reshape(bw,28*28,1));
         %         ������Ԥ�⺯��predict��
         testInput = mapminmax('apply',test_set,settings);
         Y = net(testInput);
         [value,pred] = max(Y);
         text(BoundingBox(1),BoundingBox(2)-10, Name{pred}, 'color', 'b','fontsize', 12);
         results = [results ;Name{pred}];
     end
end
 
 daan = num2str(results)
 
  %% ����÷�
% ��׼�𰸣�
 biaozhundaan = {'A' 'A' 'B' 'C' 'D'};   
score = 0;     
count = strcmp(daan,biaozhundaan)
counts = sum(count)
% ÿ���ֵΪ4��
score = counts * 4
disp(['�ܷ֣�' num2str(score)])