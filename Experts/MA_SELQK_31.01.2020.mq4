//+------------------------------------------------------------------+
//|                                          MA_SELQK_31.01.2020.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Toby-away."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern int MA_1 = 50;
extern int MA_2 = 100;
extern int MA_3 = 150;

extern double LOT_SIZE = 0.1;

extern int MAGIC = 123321;

double createdOrderAt = 0;
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
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      double MA_1_VALUE = iMA(Symbol(), Period(), MA_1, 0, MODE_EMA, PRICE_CLOSE, 0);
      double MA_2_VALUE = iMA(Symbol(), Period(), MA_2, 0, MODE_EMA, PRICE_CLOSE, 0);
      double MA_3_VALUE = iMA(Symbol(), Period(), MA_3, 0, MODE_EMA, PRICE_CLOSE, 0);
      
      if(isBullMarket(MA_1_VALUE, MA_2_VALUE, MA_3_VALUE))
        {
            double twoPrevClose = iClose(Symbol(), Period(), 1);
            double prevClose = iClose(Symbol(), Period(), 0);
            if(twoPrevClose < MA_1_VALUE && prevClose > MA_1_VALUE && createdOrderAt != twoPrevClose)
              {
                  double sl = MA_2_VALUE;
                  double tp = Ask + (MathAbs(Ask - sl) * 2);
                  OrderSend(Symbol(), OP_BUY, LOT_SIZE, Ask, 0, sl, tp, NULL, MAGIC, 0, clrNONE);
                  createdOrderAt = twoPrevClose;
              }
        }
  }
  
bool isBullMarket(double m1, double m2, double m3)
   {
      if(m1 > m2 && m2 > m3)
        {
            return true;
        }
        
      return false;  
   } 
   
bool isBearMarket(double m1, double m2, double m3)
   {
      if(m1 < m2 && m2 < m3)
        {
            return true;
        }
        
      return false;  
   }     
//+------------------------------------------------------------------+

