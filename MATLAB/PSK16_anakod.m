%16-PSK Ana Kod
clc; clear; close all; % Bir önceki kodlardan kalan deðiþkenleri siler, Komut Penceresini temizler.
N=10000; %Kanal üzerinden gönderilecek toplam bit sayýsý. (Parametrik bir deðerdir, deðiþtirilebilir)
EbN0dB=-4:2:20; % SNR için -4 dan 16 ya kadar 2 þer artarak deðiþen deðerler saðlar.
N=N+rem((4-rem(N,4)),4); %16-PSK 4 bit taþýyacak þekilde ayarlanýr.
x=rand(1,N)>=0.5;%Random 1 ve 0 datalar oluþturur;
%Her sembolü 4 bitlik gray kodlar ile ifade etmek için;
inputSymBin=reshape(x,4,N/4)';
g=bin2gray(inputSymBin);
%Her sembol için oluþturulan gray kodlarý onluk taban çevirir.
b=bin2dec(num2str(g,'%-1d'))';
%8-PSK Yýldýz Kümesi Haritalama
%8-PSK Haritalama Tablosu
map=[-1 0;-0.92 0.39;-0.7 0.7;-0.39 0.92;0 1;0.39 0.92;0.7 0.7;0.92 0.39;1 0;0.92 -0.39;0.7 -0.7;0.39 -0.92;0 -1;-0.39 -0.92;-0.7 -0.7;-0.92 -0.39];
s=map(b(:)+1,1)+1i*map(b(:)+1,2);
%Her Eb/N0 deðeri için farklý simülasyon yaptýrmak için.
M=16; %Sembol sayýsý; M=2^k. 16-PSK için k=4 olacaktýr.
Rm=log2(M);   %Rm=log2(M). 16-PSK için M=16 olacaktýr.
Rc=2;   %Kodlama oraný.

simulatedBER = zeros(1,length(EbN0dB));
theoreticalBER = zeros(1,length(EbN0dB));
count=1;

figure
for i=EbN0dB
    %-------------------------------------------
    %Eb/N0 deðerleri için kanal gürültüsü
    %-------------------------------------------
    %Gerekli Eb/N0 deðerleri için gürültü ekler.
    EbN0 = 10.^(i/10); %Eb/N0 dB deðerini doðrusal ölçekler.
    SNR = 10+10*log10(4);
   
    noiseSigma = sqrt(2)*sqrt(1./(2*Rm*Rc*EbN0)); %AWGN gürültüsü için standart sapma
    disp('Sembol gürültü oraný þu andaki grafik için aþaðýdaki gibidir');
    disp(noiseSigma);
    %Kompleks gürültü ekler
    n = noiseSigma*(randn(1,length(s))+1i*randn(1,length(s)))';
    y = s + n;
    
    plot(real(y),imag(y),'r*');hold on;
    plot(real(s),imag(s),'ko','MarkerFaceColor','g','MarkerSize',8);hold off;
    title(['Yýldýz Kümesi  SNR =',num2str(i),' dB']);legend('Gürültü eklenmiþ y sinyali','16-PSK');
  pause;
    %Demodulasyon
    %Öklid teoremini kullanarak en kýsa mesafe için MAP tablosundan sinyal noktalarýný hesaplar.
    demodSymbols = zeros(1,length(y));
    for j=1:length(y)
        [minVal,minindex]=min(sqrt((real(y(j))-map(:,1)).^2+(imag(y(j))-map(:,2)).^2));
        demodSymbols(j)=minindex-1;
    end
    
    demodBits=dec2bin(demodSymbols)-'0'; %Ondalýk deðeri ikilik tabandaki vektörlere çevirir.    
   
    xBar=gray2bin(demodBits)'; %Gray kodlarý ikilik tabana çevirir.
    xBar=xBar(:)';
    
    bitErrors=sum(sum(xor(x,xBar)));
    simulatedBER(count) = log10(bitErrors/N);    
    theoreticalBER(count) = log10((1/4)*erfc(sqrt(EbN0*4)*sin(pi/M)));
    
    count=count+1;       
end

figure
plot(EbN0dB,theoreticalBER,'r-*');hold on;
plot(EbN0dB,simulatedBER,'k-o');

title('16-PSK için BER - SNR (dB) grafiði ');legend('Teorik','Simülasyon');grid on;
xlabel('SNR dB');
ylabel('BER - Bit Error Rate (Bit Hata Oraný)'); 
grid on;