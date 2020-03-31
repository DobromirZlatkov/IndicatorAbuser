//+------------------------------------------------------------------+
//|                      #Momentum onChartSignals Indicator v1.0.mq4 |
//|                  Copyright © 2011, based on ADXcrosses Indicator |
//|                                            http://ForexBaron.net |
//+------------------------------------------------------------------+
/* for iCustom:
   double signal = iCustom(NULL,0,"#Momentum onChartSignals Indicator v1.0","","",0,6,12,7,7,7,"",12,12,50,20,"",-2.0,-1.0, 0,0);
*/

#property copyright "Copyright © 2011, ForexBaron.net"
#property link "http://ForexBaron.net"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//---- input parameters
extern string symbolhint = "Symbol (leave blank for current chart):";
extern string symbol = "";
extern string tfhint = "timeframe (in Minutes, 0 for current):";
extern int timeFrame = 0;
extern int cciPeriod = 6;
extern int atrPeriod = 12;
extern int momentumPeriod = 7;
extern int rsiPeriod = 7;
extern int adxPeriod = 7;
extern string indihint1 = "periods for control:";
extern int rsiControlPeriod = 12;
extern int adxControlPeriod = 12;
extern int rsiTrigger = 50;
extern int adxTrigger = 20;
extern string subtracthint = "default: -2, -1";
extern double subtractFromSignalVal = -2.0;
extern double subtractFromIndiVal = -1.0;
extern string hl0 = "-=------------------------------------------------------=-";
extern bool showBuySignals = true;
extern bool showSellSignals = true;
extern string wingdingshint = "default: 233, 234";
extern int wingdingsUpArrow = 233;
extern int wingdingsDownArrow = 234;
extern string hl1 = "-=------------------------------------------------------=-";
extern string alerthint = "optional settings:";
extern bool Alerts = false;
extern bool PlaySounds = false;
extern string alerthint1 = "Want change sounds for signals?";
extern string alerthint2 = "(must be in MT4\sounds\ directory";
extern string alerthint3 = "and have extension .wav)";
extern string LongSignalSoundFile = "alert.wav";
extern string ShortSignalSoundFile = "alert.wav";
extern bool SignalMail = False;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//----

int    nShift;   
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

//----    
    SetIndexStyle(0, DRAW_ARROW, 0, 1);
    SetIndexArrow(0, wingdingsUpArrow);
    SetIndexBuffer(0, ExtMapBuffer1);
//----
    SetIndexStyle(1, DRAW_ARROW, 0, 1);
    SetIndexArrow(1, wingdingsDownArrow);
    SetIndexBuffer(1, ExtMapBuffer2);
//---- name for DataWindow and indicator subwindow label
    IndicatorShortName("#MomentumChartSignalsIndicator"); // (" + indiName + ")
    SetIndexLabel(0, "BUY SIGNAL");
    SetIndexLabel(1, "SELL SIGNAL"); 
//----
    switch(Period())
      {
        case     1: nShift = 1;   break;    
        case     5: nShift = 3;   break; 
        case    15: nShift = 5;   break; 
        case    30: nShift = 10;  break; 
        case    60: nShift = 15;  break; 
        case   240: nShift = 20;  break; 
        case  1440: nShift = 80;  break; 
        case 10080: nShift = 100; break; 
        case 43200: nShift = 200; break;               
      }
//----
    return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
    return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
    int limit;
    int counted_bars = IndicatorCounted();
//---- check for possible errors
    if(counted_bars < 0) 
        return(-1);
//---- last counted bar will be recounted
    if(counted_bars > 0) 
        counted_bars--;
    limit = Bars - counted_bars;
//----
string signalSentAlready = "NONE";
if (symbol == "0" || symbol == "") symbol = Symbol();
    for(int i = 0; i < limit; i++)
      { // start loop
     
        // current data:
        double momVal = iMomentum(symbol,timeFrame,momentumPeriod,PRICE_TYPICAL,i);
        double atrVal = iATR(symbol,timeFrame,atrPeriod,i);
        double cciVal = iCCI(symbol,timeFrame,cciPeriod,PRICE_TYPICAL,i);
        double rsiVal = iRSI(symbol,timeFrame,rsiPeriod,PRICE_TYPICAL,i);
        double adxVal = iADX(symbol,timeFrame,adxPeriod,PRICE_TYPICAL,MODE_MAIN,i);
        double adxPLUSVal = iADX(symbol,timeFrame,adxPeriod,PRICE_TYPICAL,MODE_PLUSDI,i);
        double adxMINUSVal = iADX(symbol,timeFrame,adxPeriod,PRICE_TYPICAL,MODE_MINUSDI,i);

        double signalVal = (momVal / (atrVal + adxVal)) - subtractFromSignalVal; // -2
        double indiVal = ((atrVal + cciVal + rsiVal) / adxVal) - subtractFromIndiVal; // -1
        
         // triggerData:
         double adx1Val = iADX(symbol,timeFrame,adxControlPeriod,PRICE_CLOSE,MODE_MAIN,i);
         double adx1PLUSVal = iADX(symbol,timeFrame,adxControlPeriod,PRICE_CLOSE,MODE_PLUSDI,i);
         double adx1MINUSVal = iADX(symbol,timeFrame,adxControlPeriod,PRICE_CLOSE,MODE_MINUSDI,i);
         double rsi1Val = iRSI(symbol,timeFrame,rsiControlPeriod,PRICE_CLOSE,i);

        //---- SELL SIGNAL:
        if(signalVal < indiVal && adx1MINUSVal < adx1PLUSVal && rsi1Val > rsiTrigger && adx1Val > adxTrigger)
         {
           if (signalSentAlready != "short")
            {
             if (showSellSignals) ExtMapBuffer2[i] = High[i] + nShift*Point;
              if (Alerts) { Alert("SELL SIGNAL at ", symbol,": ",Close[0]," (TF ",Period(),")"); }
              if (PlaySounds) { PlaySound(ShortSignalSoundFile); }
              if (SignalMail) { SendMail(""+symbol+" SELL SIGNAL","SELL SIGNAL on "+symbol+": "+Close[0]+" (Timeframe: "+Period()+")"); }
             signalSentAlready = "short";
            }
         }
         
        //---- BUY SIGNAL:
        if(signalVal > indiVal && adx1PLUSVal < adx1MINUSVal && rsi1Val < rsiTrigger && adx1Val > adxTrigger)
         {
           if (signalSentAlready != "long")
            {
             if (showBuySignals) ExtMapBuffer1[i] = Low[i] - nShift*Point;
              if (Alerts) { Alert("BUY SIGNAL at ", symbol,": ",Close[0]," (TF ",Period(),")"); }
              if (PlaySounds) { PlaySound(LongSignalSoundFile); }
              if (SignalMail) { SendMail(""+symbol+" BUY SIGNAL","BUY SIGNAL on "+symbol+": "+Close[0]+" (Timeframe: "+Period()+")"); }
             signalSentAlready = "long";
            }
         }
         
      } // end loop
//----
    return(0);
  }
//+------------------------------------------------------------------+