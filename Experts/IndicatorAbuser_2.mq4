//+------------------------------------------------------------------+
//|                                            IndicatorAbuser_2.mq4 |
//|                                  Copyright 2020, Tobi-away Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Tobi-away Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

// BASE LINE
input ENUM_MA_METHOD BASE_LINE_TYPES = MODE_SMA;
input ENUM_APPLIED_PRICE BASE_LINE_APPLIED_PRICE = PRICE_CLOSE;
extern int BASE_LINE_PERIOD = 50;
extern int BASE_LINE_SHIFT = 0;




//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
// ATR

// base line - SMA 50 - when crosses with a bigger part of the candle its a signal for possition
//

// G

// confifmation indocator

// volum indicator for sl

// second confirmation


// exit indicator

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double base_line = GetBaseLineValue(0);

   printf(base_line);


  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetBaseLineValue(int shift)
  {
   double val = iMA(Symbol(), Period(), MA_PERIOD, MA_SHIFT, BASE_LINE_TYPES, BASE_LINE_APPLIED_PRICE, shift);
   return NormalizeDouble(val, 3);
  }
//+------------------------------------------------------------------+
