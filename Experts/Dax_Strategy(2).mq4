//+------------------------------------------------------------------+
//|                                                 Dax_Strategy.mq4 |
//|                                                        Toby-away |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Toby-away"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

extern double GET_PROFIT_POINTS = 38;
extern double MAX_STOP_LOSS_POINTS = 300;
extern double CLOSE_HOUR = 18;
int PIVOT_MONITOR_START_HOUR = 9;
int MARKET_OPEN_HOUR = 10;
extern double LOT_SIZE = 0.10;
int MAGIC = 53453534;
int SLEEPAGE = 0;

extern double CANDLE_SHIFT = 0;
extern double MIN_GAP_SIZE = 0;

int OnInit()
  {


   return(INIT_SUCCEEDED);
  }
  
void OnDeinit(const int reason)
  {
 
  }
  
   
double pivotUpperValue = 0;
double pivotLowerValue = 0;
  
void OnTick()
  {
  
      double closePrice = iClose(Symbol(), Period(), CANDLE_SHIFT + 1);
      double openPrice = iClose(Symbol(), Period(), CANDLE_SHIFT);
      double priceDiff = closePrice - openPrice;
      double gapSize = MathAbs(priceDiff);
      
      if(!(gapSize > MIN_GAP_SIZE))
        {
          return;
        }
        
      Print(gapSize, "We have a gap");  
  
      // =============== //
     // int currentHour = Hour();   
      //int currentMinute = Minute();
      
      //Print(currentHour, "currentHour");
      //Print(currentMinute, "currentMinute");
      
      //if(currentHour == MARKET_OPEN_HOUR && currentMinute == 0)
      //  {
        //    pivotUpperValue = getPivotUpperValue();
        //    pivotLowerValue = getPivotLowerValue();
              
       // }
        
   
    //  if(numberOfOpenOrdersForCurrentDayByMagic(MAGIC) == 0 && numberOfPastOrdersForCurrentDayByMagic(MAGIC) == 0)
      //  {
        //   if(currentHour == MARKET_OPEN_HOUR && currentMinute < 40)
          // {
            //   double close = iClose(Symbol(), PERIOD_M1, 1);
            
             //  if(close > pivotUpperValue)
              //   {
                   //  OrderSend(Symbol(), OP_BUY, LOT_SIZE, Ask, SLEEPAGE, pivotLowerValue - 1, close + GET_PROFIT_POINTS, "Strategy", MAGIC);
                // }
              // if(close < pivotLowerValue)   
               // {
                  //   OrderSend(Symbol(), OP_SELL, LOT_SIZE, Bid, SLEEPAGE, pivotUpperValue + 1, close - GET_PROFIT_POINTS, "Strategy", MAGIC);
                // } 
          // }
      // }
        
     //  if(currentHour == CLOSE_HOUR)
        // {
         //   closeAllLeftOrdersAtSelectedHour();
        // }
   
  }
  
void closeAllLeftOrdersAtSelectedHour()
{
   int totalOrders = OrdersTotal();  
   
   for(int i=0;i < totalOrders; i++)
   {
      if (OrderSelect(i, SELECT_BY_POS))// Selects the order at the current possition
      {
        if(OrderType() == OP_SELL)
          {
            OrderClose(OrderTicket(), LOT_SIZE, Ask, SLEEPAGE, Red);
          }
    
         if(OrderType() == OP_BUY)
          {
            OrderClose(OrderTicket(), LOT_SIZE, Bid, SLEEPAGE, Red);
          }
      }
   }
}


double getPivotUpperValue()
{
   double highest = 0;
   for(int i=1;i<=60;i++)
     {
         double high  = iHigh(Symbol(), PERIOD_M1, i);
         datetime currentTime = iTime(Symbol(),PERIOD_M1, i);
         
         if(TimeHour(currentTime) == PIVOT_MONITOR_START_HOUR)
           {
               if(high > highest)
                 {
                     highest = high;
                 }
           }
     }
   return highest;
}

double getPivotLowerValue()
{
   double lowest = iLow(Symbol(), PERIOD_M1, 1);
   for(int i=1;i<=60;i++)
     {
         datetime currentTime = iTime(Symbol(),PERIOD_M1, i);
         double low = iLow(Symbol(), PERIOD_M1, i);
         
         if(TimeHour(currentTime) == PIVOT_MONITOR_START_HOUR)
           {
               if(low < lowest)
                 {
                     lowest = low;
                 }
           }
           
     }
   return lowest;
}



int numberOfOpenOrdersForCurrentDayByMagic(int magic)
{
   datetime currentDay = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day()));
   int result = 0;
   int totalOrders = OrdersTotal();  
   
   for(int i=0;i < totalOrders; i++)
   {
      if (OrderSelect(i, SELECT_BY_POS))// Selects the order at the current possition
      {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL)// Check if order is buy or sell
         {
            if(OrderOpenTime() > currentDay && OrderMagicNumber() == magic)
            {
               result++;
            }
         }
      }
   }
   
   return result;
}

int numberOfPastOrdersForCurrentDayByMagic(int magic)
{
   datetime currentDay = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day()));
   int result = 0;
   int totalOrders = OrdersHistoryTotal();  
   
   for(int i=0;i < totalOrders; i++)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))// Selects the order at the current possition
      {
         if(OrderOpenTime() > currentDay && OrderMagicNumber() == magic)
         {
            result++;
         } 
      }
   }
   
 
   return result;
}