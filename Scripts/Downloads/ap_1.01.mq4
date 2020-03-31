//+------------------------------------------------------------------+
//|                                                      AP 1.00.mq4 |
//|                                            Fredrich Company 2015 |
//|                                    https://www.vk.com/Fredrich85 |
//+------------------------------------------------------------------+
#property copyright "Fredrich Company 2015"
#property link      "https://www.vk.com/Fredrich85"
#property version   "1.00"
#property strict
extern int   period_slow= 70;                // ������ ��������� ���������� �������
input int   period_fast = 25;                // ������ ������� ���������� �������
input int   period_absalut=1440;             // ������ ������� ���������� �������
input int   shift_min1   = 1;                // ������ ������� �� ���� �����
input int   shift_max1   = 240;              // ����� ����� ��� 6-8 ��������� �������
input int   shift_min2   = 1;                // ������ ������� �� ���� �����
input int   shift_max2= 1440;                // ����� ����� ��� ������� �������
input int   sleep = 5000;

input color    clr_hight = clrBlue;          // ���� ������� �����
input color    clr_low = clrRed;             // ���� ������ �����
input color    clr_med = clrGold;            // ���� ������� �����
input string   name_hight = "HLine";         // ��� �����
input string   name_low = "LLine";           // ��� �����
input string   name_medium = "MLine";        // ��� �����
input string   name_trend= "TrendLine";      // ��� �����
input string   name_fibo = "TrendFibo";      // ��� �����
input string   name_hightL="Year Hight Line";// ��� �����
input string   name_lowL="Year Low Line";    // ��� �����
input string   name_mediumL="Year Medium Line"; // ��� �����
input string   name_mediumY= "Median Year";

bool on_fibo=1;
bool on_year_flat = 1;
bool on_week_flat = 1;
bool on_year_median=1;
bool on_comment=1;

double val_hight;
double val_low;
double val_medium;
datetime val_lowT;
datetime val_hightT;
double val_hightL;
double val_lowL;
double val_mediumL;
//+------------------------------------------------------------------+
//|������ �������                                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- �������� ���� �������� �� �������
   ObjectsDeleteAll();

//--- ����� ��� ����������� 
   Sleep(sleep);

//--- ����� ���������� ��� ������ ������� 
   double Price=iOpen(NULL,PERIOD_D1,0);
   double absalut=iMA(NULL,PERIOD_H4,period_absalut,0,MODE_EMA,PRICE_CLOSE,1);

//--- ������ ������ �� ���������� �������
   double H4_F  = iMA(NULL , PERIOD_H4, period_fast, 0, MODE_EMA, PRICE_CLOSE, 1);
   double H4_S  = iMA(NULL , PERIOD_H4, period_slow, 0, MODE_EMA, PRICE_CLOSE, 1);
   double D1_F  = iMA(NULL , PERIOD_D1, period_fast, 0, MODE_EMA, PRICE_CLOSE, 1);
   double D1_S  = iMA(NULL , PERIOD_D1, period_slow, 0, MODE_EMA, PRICE_CLOSE, 1);

//--- ������ ����������� �� �������� 6-8 ������
   int val_index=iHighest(NULL,PERIOD_H4,MODE_HIGH,shift_max1,shift_min1);
   if(val_index!=-1){ val_hight=High[val_index]; val_hightT=Time[val_index]; }
   else PrintFormat("������ ������ iHighest. ��� ������=%d",GetLastError());

   val_index=iLowest(NULL,PERIOD_H4,MODE_LOW,shift_max1,shift_min1);
   if(val_index!=-1) { val_low=Low[val_index]; val_lowT=Time[val_index]; }
   else PrintFormat("������ ������ iLowest. ��� ������=%d",GetLastError());

   val_medium=(val_hight+val_low)/2;

//--- ���������� � ������ ����
   string  dateWeek_h = TimeToString(val_hightT,TIME_DATE);         // ���� ��������� 6-8 ������
   string  dateWeek_l = TimeToString(val_lowT,TIME_DATE);           // ���� ��������  6-8 ������

//--- ������ ����������� �� ���
   val_index=iHighest(NULL,PERIOD_H4,MODE_HIGH,shift_max2,shift_min2);
   if(val_index!=-1){ val_hightL=High[val_index]; }
   else PrintFormat("������ ������ iHighest. ��� ������=%d",GetLastError());

   val_index=iLowest(NULL,PERIOD_H4,MODE_LOW,shift_max2,shift_min2);
   if(val_index!=-1) { val_lowL=Low[val_index];  }
   else PrintFormat("������ ������ iLowest. ��� ������=%d",GetLastError());

   val_mediumL=(val_hightL+val_lowL)/2;

//--- ���������� ����� �� �������� 6-8 ������
   if(on_week_flat==true)
     {
      ObjectCreate(0,name_hight,OBJ_HLINE,0,0,val_hight);
      ObjectSetInteger(0,name_hight,OBJPROP_COLOR,clr_hight);
      ObjectCreate(0,name_low,OBJ_HLINE,0,0,val_low);
      ObjectSetInteger(0,name_low,OBJPROP_COLOR,clr_low);
      ObjectCreate(0,name_medium,OBJ_HLINE,0,0,val_medium);
      ObjectSetInteger(0,name_medium,OBJPROP_COLOR,clr_med);
     }
   if(on_fibo==true)
     {
      ObjectCreate(0,name_fibo,OBJ_FIBO,0,val_hightT,val_hight,val_lowT,val_low);
      ObjectSetInteger(0,name_trend,OBJPROP_COLOR,clr_low);
     }

//--- ���������� ����� �� �������� �������� �����
   if(on_year_flat==true)
     {
      ObjectCreate(0,name_hightL,OBJ_HLINE,0,0,val_hightL);
      ObjectSetInteger(0,name_hightL,OBJPROP_COLOR,clr_hight);
      ObjectSetInteger(0,name_hightL,OBJPROP_WIDTH,2);
      ObjectCreate(0,name_lowL,OBJ_HLINE,0,0,val_lowL);
      ObjectSetInteger(0,name_lowL,OBJPROP_COLOR,clr_low);
      ObjectSetInteger(0,name_lowL,OBJPROP_WIDTH,2);
      ObjectCreate(0,name_mediumL,OBJ_HLINE,0,0,val_mediumL);
      ObjectSetInteger(0,name_mediumL,OBJPROP_COLOR,clr_med);
      ObjectSetInteger(0,name_mediumL,OBJPROP_WIDTH,2);
     }

//--- ������ �������� ������� �� ���
   if(on_year_median==true)
     {
      ObjectCreate(0,name_mediumY,OBJ_HLINE,0,0,absalut);
      ObjectSetInteger(0,name_mediumY,OBJPROP_COLOR,clrGray);
      ObjectSetInteger(0,name_mediumY,OBJPROP_WIDTH,3);
     }

//--- ������ ������� �������� ���������� ���� 
   double val_h4 = (H4_F - H4_S)/Point();                      // ������� ����� ���������� 4 �������� �������
   double val_D1 = (D1_F - D1_S)/Point();                      // ������� ����� ���������� �������� �������        
   double val_change = (val_hight-val_low)/Point();            // ������ 6-8 ���������� �����
   double val_change_year = (val_hightL-val_lowL)/Point();     // ������ ��������  �����
   double val_absalut = (absalut-Price)/Point();               // ���������� �� ������� ������� 
   double val_absalut_week = (val_medium-Price)/Point();       // ���������� �� ������� ����� �� 6-8 ������
   double val_absalut_year = (val_mediumL-Price)/Point();      // ���������� �� ������� �������� �����

//--- ����� ������ � �����������
   if(on_comment==true)
     {
      Comment(StringFormat("�������� ���������� �4 = %G pips; D1 = %G pips\n������ ������ ����� 6-8 week = %G pips ������� = %G pips\n���������� �� ������� ���������� = %G pips\n���������� �� ������� 6-8 ���������� ����� = %G pips �������� �����  = %G pips",val_h4,val_D1,val_change,val_change_year,val_absalut,val_absalut_week,val_absalut_year));
     }
  }
//+------------------------------------------------------------------+
