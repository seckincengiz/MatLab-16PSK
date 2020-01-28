%16-PSK Ana Kod
clc; clear; close all; % Bir �nceki kodlardan kalan de�i�kenleri siler, Komut Penceresini temizler.
N=10000; %Kanal �zerinden g�nderilecek toplam bit say�s�. (Parametrik bir de�erdir, de�i�tirilebilir)
EbN0dB=-4:2:20; % SNR i�in -4 dan 16 ya kadar 2 �er artarak de�i�en de�erler sa�lar.
N=N+rem((4-rem(N,4)),4); %16-PSK 4 bit ta��yacak �ekilde ayarlan�r.
x=rand(1,N)>=0.5;%Random 1 ve 0 datalar olu�turur;
%Her sembol� 4 bitlik gray kodlar ile ifade etmek i�in;
inputSymBin=reshape(x,4,N/4)';
g=bin2gray(inputSymBin);
%Her sembol i�in olu�turulan gray kodlar� onluk taban �evirir.
b=bin2dec(num2str(g,'%-1d'))';
%8-PSK Y�ld�z K�mesi Haritalama
%8-PSK Haritalama Tablosu
map=[-1 0;-0.92 0.39;-0.7 0.7;-0.39 0.92;0 1;0.39 0.92;0.7 0.7;0.92 0.39;1 0;0.92 -0.39;0.7 -0.7;0.39 -0.92;0 -1;-0.39 -0.92;-0.7 -0.7;-0.92 -0.39];
s=map(b(:)+1,1)+1i*map(b(:)+1,2);
%Her Eb/N0 de�eri i�in farkl� sim�lasyon yapt�rmak i�in.
M=16; %Sembol say�s�; M=2^k. 16-PSK i�in k=4 olacakt�r.
Rm=log2(M);   %Rm=log2(M). 16-PSK i�in M=16 olacakt�r.
Rc=2;   %Kodlama oran�.

simulatedBER = zeros(1,length(EbN0dB));
theoreticalBER = zeros(1,length(EbN0dB));
count=1;

figure
for i=EbN0dB
    %-------------------------------------------
    %Eb/N0 de�erleri i�in kanal g�r�lt�s�
    %-------------------------------------------
    %Gerekli Eb/N0 de�erleri i�in g�r�lt� ekler.
    EbN0 = 10.^(i/10); %Eb/N0 dB de�erini do�rusal �l�ekler.
    SNR = 10+10*log10(4);
   
    noiseSigma = sqrt(2)*sqrt(1./(2*Rm*Rc*EbN0)); %AWGN g�r�lt�s� i�in standart sapma
    disp('Sembol g�r�lt� oran� �u andaki grafik i�in a�a��daki gibidir');
    disp(noiseSigma);
    %Kompleks g�r�lt� ekler
    n = noiseSigma*(randn(1,length(s))+1i*randn(1,length(s)))';
    y = s + n;
    
    plot(real(y),imag(y),'r*');hold on;
    plot(real(s),imag(s),'ko','MarkerFaceColor','g','MarkerSize',8);hold off;
    title(['Y�ld�z K�mesi  SNR =',num2str(i),' dB']);legend('G�r�lt� eklenmi� y sinyali','16-PSK');
  pause;
    %Demodulasyon
    %�klid teoremini kullanarak en k�sa mesafe i�in MAP tablosundan sinyal noktalar�n� hesaplar.
    demodSymbols = zeros(1,length(y));
    for j=1:length(y)
        [minVal,minindex]=min(sqrt((real(y(j))-map(:,1)).^2+(imag(y(j))-map(:,2)).^2));
        demodSymbols(j)=minindex-1;
    end
    
    demodBits=dec2bin(demodSymbols)-'0'; %Ondal�k de�eri ikilik tabandaki vekt�rlere �evirir.    
   
    xBar=gray2bin(demodBits)'; %Gray kodlar� ikilik tabana �evirir.
    xBar=xBar(:)';
    
    bitErrors=sum(sum(xor(x,xBar)));
    simulatedBER(count) = log10(bitErrors/N);    
    theoreticalBER(count) = log10((1/4)*erfc(sqrt(EbN0*4)*sin(pi/M)));
    
    count=count+1;       
end

figure
plot(EbN0dB,theoreticalBER,'r-*');hold on;
plot(EbN0dB,simulatedBER,'k-o');

title('16-PSK i�in BER - SNR (dB) grafi�i ');legend('Teorik','Sim�lasyon');grid on;
xlabel('SNR dB');
ylabel('BER - Bit Error Rate (Bit Hata Oran�)'); 
grid on;