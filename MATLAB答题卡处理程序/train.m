clear
clc
%%  ѵ���ַ�
%%  ��ȡ��������
DATADIR='.\��ĸ��\';                                   % ������ͼ��Ŀ¼ 
dirinfo=dir(DATADIR);                                  % ��ȡͼ��Ŀ¼�����ļ���Ϣ
Name={dirinfo.name};                                   % ��ȡ�ļ���
Name(1:2)=[];                                          % ȥ���ļ��й�����Ϣ
[nouse num_of_char]=size(Name);                        % ��ȡ�������
count = 1;
images = [];
labels = [];
for  cnt=1  :num_of_char                               % for ѭ����ȡ�����ļ���
      cnt
      pathname=horzcat(DATADIR, Name{cnt},'\');        % ��·���������ں�һ��
      sub_dirinfo=dir(pathname);                       % ��ȡͼ��Ŀ¼�����ļ���Ϣ
      sub_Name={sub_dirinfo.name};                     % ��ȡ�ļ���
      sub_Name(1:2)=[];  
      [nouse num_of_image]=size(sub_Name); 
      for i = 1: num_of_image
      image = imread(horzcat(pathname,sub_Name{i}));
%       �ҶȻ�
      if size(image,3) >1 
          image = rgb2gray(image);
      end
      bw  = im2bw(image,graythresh(image));
      %   ��С����ӿ� 
      [bw2,BoundingBox1,im0] = edu_imgcrop3(bw,bw,image);
      bw = imresize(bw2,[28 28], 'bilinear');
%       ��ͼ����������
      bw1 = double(reshape(bw,28*28,1));
      images = [images,bw1];
%       �ַ���Ӧ�ı�ǩ
      labels(count) = cnt;
      count = count +1;
      end
end
 
% d*n
%% ����ֵ��һ��
[input,settings] = mapminmax(images);

 
%% �����������
s = length(labels) ;
output = zeros(s,num_of_char) ;
for i = 1 : s
   output(i,labels(i)) = 1;
end
output = output';

%% ���������������ѵ��
% Create a Pattern Recognition Network
hiddenLayerSize = 200;
net = patternnet(hiddenLayerSize, 'trainscg');
%����ѵ������
net.trainparam.show = 50;
net.trainparam.epochs = 100 ;
net.trainparam.goal = 0.01 ;
net.trainParam.lr = 0.01 ;
 
%��ʼѵ��
%����� input ������б�ʾ������ά�ȣ��д���һ��������
%       output'ÿһ�б�ʾһ�������ı�ǩ��
[net,tr] = train(net,input,output) ;  
% ��ʾ����
% view(net)

y = net(input);
% ��ʾѵ��cost���͵Ĺ���
figure, plotperform(tr)
% ��ʾ�����������
figure, plotconfusion(output,y) 
    
%% ��������ģ��
save model.mat settings net Name
%% ����    
  Y = net(input);
[value,pred] = max(Y);
                    
aa = find(pred ==labels);
acc = length(aa)/length(labels)     
 
             
             