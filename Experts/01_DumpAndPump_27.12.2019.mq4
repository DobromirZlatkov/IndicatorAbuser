//+------------------------------------------------------------------+
//|                                    01_DumpAndPump_27.12.2019.mq4 |
//|                                        Copyright 2019, Toby-away |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Toby-away"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


extern int GAP_SHIFT = 0;
extern double MIN_GAP_SIZE = 0;
extern double LOT_SIZE = 0.1;
extern double SL_EMPLIFIER = 1;
extern double TP_EMPLIFIER = 1;
extern int SLEEPEGE = 0;
extern double MAX_RISK = 10;
extern int AVERAGE_CANDLE_BACK = 10;
extern bool AUTOMATIC_SL_CALC = false;
extern double SL_INCREASE_FACTOR = 1;

double CurrCandleOpen = 0;
int Magic = 1234321;
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
   TrailOrders();

   double currOpen = iOpen(Symbol(), Period(), 0);
   if(CurrCandleOpen == currOpen)
     {
      return;
     }

   double gap = GetGap();
   if(gap < MIN_GAP_SIZE)
     {
      return;
     }

   bool isBullGap = IsBoolGap();

   double currSlSize = gap * SL_EMPLIFIER;

   if(AUTOMATIC_SL_CALC)
     {
      currSlSize = NormalizeDouble(AverageCandleSize(AVERAGE_CANDLE_BACK), Digits);
     }

   currSlSize *= SL_INCREASE_FACTOR;

   if(isBullGap)
     {
      double price = NormalizeDouble(iLow(Symbol(), Period(), GAP_SHIFT), Digits);
      double sl = NormalizeDouble(price + currSlSize, Digits);
      double tp = NULL;
      double slSize = MathAbs(price - sl);
      double lotSize = CalculateLotSize(sl);

      OrderSend(Symbol(), OP_SELLSTOP, lotSize, price, SLEEPEGE, sl, tp, slSize, Magic);
      CurrCandleOpen = currOpen;
     }
   else
     {
      double price = NormalizeDouble(iHigh(Symbol(), Period(), GAP_SHIFT), Digits);
      double sl = NormalizeDouble(price - currSlSize, Digits);
      double tp = NULL;
      double slSize = MathAbs(price - sl);
      double lotSize = CalculateLotSize(sl);

      OrderSend(Symbol(), OP_BUYSTOP, lotSize, price, SLEEPEGE, sl, tp, slSize, Magic);
      CurrCandleOpen = currOpen;
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetGap()
  {
   double prevClose = iClose(Symbol(), Period(), GAP_SHIFT + 1);
   double currOpen = iOpen(Symbol(), Period(), GAP_SHIFT);

   return MathAbs(prevClose - currOpen);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBoolGap()
  {
   double prevClose = iClose(Symbol(), Period(), GAP_SHIFT + 1);
   double currOpen = iOpen(Symbol(), Period(), GAP_SHIFT);

   if(prevClose < currOpen)
     {
      return true;
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AverageCandleSize(int backInTime)
  {
   double candleSizes = 0;
   for(int i=0; i<backInTime; i++)
     {
      candleSizes += MathAbs(iHigh(Symbol(), Period(), i) - iLow(Symbol(), Period(), i));
     }
   return candleSizes / backInTime;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailOrders()
  {
   int total = OrdersTotal();

   for(int i = 0; i < total; i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if((OrderType() == OP_SELL || OrderType() == OP_BUY) && OrderSymbol()==Symbol())
           {
            TrailOrder(OrderType());
           }
        }
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailOrder(int type)
  {
   double TrailingStop = NormalizeDouble(OrderComment(), Digits);

   if(TrailingStop > 0)
     {
      if(type == OP_BUY)
        {
         double newSl = NormalizeDouble(Bid - TrailingStop, Digits);
         double oldSl = NormalizeDouble(OrderStopLoss(), Digits);
         if(Bid - OrderOpenPrice() > TrailingStop)
           {
            if(oldSl < newSl)
              {
               OrderModify(OrderTicket(), OrderOpenPrice(), newSl, OrderTakeProfit(), OrderExpiration(), Green);
              }
           }
        }
      else
         if(type == OP_SELL)
           {
            double newSl = NormalizeDouble(Ask + TrailingStop, Digits);
            double oldSl = NormalizeDouble(OrderStopLoss(), Digits);
            if((OrderOpenPrice() - Ask) > TrailingStop)
              {
               if(oldSl > newSl)
                 {
                  OrderModify(OrderTicket(), OrderOpenPrice(), newSl, OrderTakeProfit(), OrderExpiration(), Red);
                 }
              }
           }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateLotSize(double SL)           //Calculate the size of the position size
  {
   double LotSize = 0;
//We get the value of a tick
   double nTickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
//If the digits are 3 or 5 we normalize multiplying by 10
   if(Digits == 3 || Digits == 5)
     {
      nTickValue = nTickValue * 10;
     }
//We apply the formula to calculate the position size and assign the value to the variable
   LotSize=(AccountBalance() * MAX_RISK / 100) / (SL * nTickValue);
   return MathFloor(LotSize);
  }
//+------------------------------------------------------------------+
