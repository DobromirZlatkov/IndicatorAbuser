//+------------------------------------------------------------------+
//|                                                MyFirstExpert.mq4 |
//|                                                        Toby-away |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Toby-away"
#property link      ""
#property version   "1.00"
#property strict

//int a = 45;
//double b = 1.32;
//string c = "My name is bialal";
// int someArray[10] - {1,2,3,4,5,6,7,8,9,10};


extern double OPEN_PIPS_COUNT = 0.005;
extern double TAKE_PROFIT_PIPS_COUNT = 0.003;
extern double AVERAGING_STOP_LOSS = 0.001;
extern double AVERAGING_PROFIT_PIPS_COUNT = 0.0015;
extern double LOT_SIZE = 0.01;
extern double AVERAGING_LOT_SIZE = 0.01;
extern double ALLOWED_REMAINDER_FOR_ORDER = 0.00005;
extern int SLEEPEGE = 1;
extern int NUMBER_OF_DAYS_BACK_TO_COUNT_HIGHEST_PRICE = 30;
extern int MAGIC = 32435674576;
extern int EVARAGING_MAGIC = 564321435;
extern int ALLOWED_NUMBER_OF_OPEN_ORDERS_PER_DAY = 2;
extern int ALLOWED_EVARAGING_NUMBER_OF_OPEN_ORDERS_PER_DAY = 1;
extern double STOCK_HASTIC_UPPER_BOUND = 70;
extern double STOCK_HASTIC_LOWER_BOUND = 20;
extern double STOP_LOSS = 0.06;
extern double ALLOWED_AVERAGING_PER_DAY = 3;

int averaging_emplifier[4] = {10, 5, 2, 1};

int OnInit()
  {
      Print("Successfuly Started...");
      return(INIT_SUCCEEDED);
  }
  
void OnDeinit(const int reason)
  {
   Print("Successfuly Stopped...");
  }
  
void OnTick()
  {
      double sellCurrentProfitPrice = Bid - TAKE_PROFIT_PIPS_COUNT; // if sell
      double buyCurrentProfitPrice = Ask + TAKE_PROFIT_PIPS_COUNT; // if buy
      double buyAveragingProfitPrice = Ask + AVERAGING_PROFIT_PIPS_COUNT;
      double sellAveragingProfitPrice = Bid - AVERAGING_PROFIT_PIPS_COUNT;
      double currentPrice = Ask;
      double stopLoss = 0;
      if(placeBuy())
      {
         currentPrice = Ask;
         stopLoss = currentPrice - STOP_LOSS;
      }
      else
      {
         currentPrice = Bid;
         stopLoss = currentPrice + STOP_LOSS;
      }
       
   
      int emplifier = digitsEmplifier();
      double emplifiedCurrentPrice = currentPrice * emplifier;
      double emplifiedTakeProfitPips = OPEN_PIPS_COUNT * emplifier;
      double allowedRemainderForPlacingOrder = ALLOWED_REMAINDER_FOR_ORDER * emplifier;
      
      double stochHasticValue = stockHasticValue();
      double remainder = MathMod(emplifiedCurrentPrice, emplifiedTakeProfitPips);
      
      if(numberOfOpenOrdersForCurrentDayByMagic(MAGIC) < ALLOWED_NUMBER_OF_OPEN_ORDERS_PER_DAY)
      {
         if(remainder <= allowedRemainderForPlacingOrder)
         {
            // TODO find if the trend is up or down
           
            if(!isThereOpenOrderInTheRangeOfPipsCountForToday(currentPrice))
            {
               if(placeBuy())
                 {
                    OrderSend(Symbol(), OP_BUY, LOT_SIZE, currentPrice, NULL, stopLoss, buyCurrentProfitPrice, "Sell trade by my expert advisor", MAGIC);
                 }
               else
                 {
                    OrderSend(Symbol(), OP_SELL, LOT_SIZE, currentPrice, NULL, stopLoss, sellCurrentProfitPrice, "Sell trade by my expert advisor", MAGIC);
                 }  
               
            }
               
         } 
      }
   

     if(isOrderTakeProfitIsReached(currentPrice) &&
         numberOfOpenOrdersForCurrentDayByMagic(EVARAGING_MAGIC) < ALLOWED_EVARAGING_NUMBER_OF_OPEN_ORDERS_PER_DAY &&
         numberOfPastOrdersForCurrentDayByMagic(EVARAGING_MAGIC) < ALLOWED_AVERAGING_PER_DAY
      )
     {
        if(!isThereOpenOrderInTheRangeOfPipsCountForToday(currentPrice))
        {
            double averagingLotSize = AVERAGING_LOT_SIZE;
            
            if(numberOfPastOrdersForCurrentDayByMagic(EVARAGING_MAGIC) < 3)
              {
                  averagingLotSize = averaging_emplifier[numberOfPastOrdersForCurrentDayByMagic(EVARAGING_MAGIC)] * AVERAGING_LOT_SIZE;
              }
           
            
           if(placeBuy())
            {
               OrderSend(Symbol(), OP_BUY, averagingLotSize, currentPrice, NULL, stopLoss, buyAveragingProfitPrice, "Osrednqvane", EVARAGING_MAGIC);
            }
            else
            {
               OrderSend(Symbol(), OP_SELL, averagingLotSize, currentPrice, NULL, stopLoss, sellAveragingProfitPrice, "Osrednqvane", EVARAGING_MAGIC);
            }
         }
     }     
  }
  
//+------------------------------------------------------------------+

void closeAllLeftOrdersOnTrendChange()
{
   int totalOrders = OrdersTotal();  
   
   for(int i=0;i < totalOrders; i++)
   {
      if (OrderSelect(i, SELECT_BY_POS))// Selects the order at the current possition
      {
         if(placeBuy())
           {
              if(OrderType() == OP_SELL)
                {
                  OrderClose(OrderTicket(), LOT_SIZE, Ask, SLEEPEGE, Red);
                }
           }
          else
           {
               if(OrderType() == OP_BUY)
                {
                  OrderClose(OrderTicket(), LOT_SIZE, Bid, SLEEPEGE, Red);
                }
           }
      }
   }
}


int digitsEmplifier()
{
   int result = 1;
   for(int i = 0; i < Digits; i++)
     {
         result *= 10;
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

bool isOrderTakeProfitIsReached(double price)
{
   int totalOrders = OrdersTotal();
   
   for(int i=0; i<totalOrders; i++)
   {
         if(OrderSelect(i, SELECT_BY_POS))
         {
              if(OrderType() == OP_BUY)
              {
                   double currentOrderTakeProfitPrice = OrderTakeProfit();
                   if( price + ALLOWED_REMAINDER_FOR_ORDER + 0.001 >= currentOrderTakeProfitPrice)
                     {
                        return True;
                     }
              }
              if(OrderType() == OP_SELL)
                {
                    double currentOrderTakeProfitPrice = OrderTakeProfit();
                    if(price - ALLOWED_REMAINDER_FOR_ORDER - 0.001 <= currentOrderTakeProfitPrice)
                       {
                          return True;
                       }
                }
          }
    }
     
    return False;
}

bool isThereOpenOrderInTheRangeOfPipsCountForToday(double price)
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
            if(OrderOpenTime() > currentDay)
            {
               double currentOrderOpenPrice = OrderOpenPrice();
               
               if(currentOrderOpenPrice <= price + ALLOWED_REMAINDER_FOR_ORDER &&
                  currentOrderOpenPrice >= price - ALLOWED_REMAINDER_FOR_ORDER
               )
                 {
                     return True;
                 }
            }
         }
      }
   }
   
   return False;
}

bool placeBuy()
{
  if(twentyPeriodMovingAverageValue() > fiftyPeriodMovingAverageValue())
    {
      return True;
    }  
   return False;
}

//bool isOverSold()
//{
//   double stockHastic =  iStochastic(Symbol(), PERIOD_D1, );
//}

bool isPriceHighestForTheLastNumberOfDays(double price, int numberOfDays)
{
   double highest = 0;
   double current = 0;
   for(int i=0; i<numberOfDays; i++)
     {
        if(High[i] > highest)
          {
            highest = High[i];
          }
     }
    
    
    if(current > highest)
      {
        return True;
      }
      
    return False;
}


bool isThisBarBULLISH( int aBarPTR = 0 ){
     return ( Close[aBarPTR] > Open[aBarPTR] );
}

bool isThisBarBEARISH( int aBarPTR = 0 ){
     return ( Close[aBarPTR] < Open[aBarPTR] );
}

double twentyPeriodMovingAverageValue()
{
   return iMA(Symbol(),0,20,0,MODE_SMA,PRICE_CLOSE,0);
}


double fiftyPeriodMovingAverageValue()
{
   return iMA(Symbol(),0,50,0,MODE_SMA,PRICE_CLOSE,0);
}

void closeOrdersOlderThanNumberOfDays(int daysPivot)
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
            if(OrderOpenTime())
            {
               result++;
            }
         }
      }
   }
   
}

double stockHasticValue()
{
   string symbol = Symbol(); // current
   int timeFrame = 0; // current
   int k_period = 5;
   int d_period = 3;
   int slowing = 6;
   int stop_price_field = 0;
   
   //Print(iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,0), "iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,0)");
   
  // Print(iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_SIGNAL,0), "iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_SIGNAL,0)");
   
   double result = iStochastic(symbol, timeFrame, k_period, d_period, slowing, MODE_SMA, stop_price_field, MODE_MAIN, 0);

   return result;
}