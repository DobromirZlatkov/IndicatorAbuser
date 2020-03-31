//+------------------------------------------------------------------+
//|                                                 Gap strategy.mq4 |
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
int MAGIC = 53453534;


int SLEEPAGE = 0;
extern double TP_PERCENT = 70;
extern double LOT_SIZE = 0.10;
extern double CANDLE_SHIFT = 0;
extern double MIN_GAP_SIZE = 0;
extern double PERCENT_JUMP = 50;
extern double LOT_SIZE_CLOSE = 2;
extern double SL_DEVIDER = 1;
extern double MAX_RISK_PER_TRADE = 10;

double LotSize = 0;
double createdOrderAt = 0;

int OnInit()
  {
   LotSize = LOT_SIZE;

   return(INIT_SUCCEEDED);
  }
  
void OnDeinit(const int reason)
  {
 
  }
  
   
double pivotUpperValue = 0;
double pivotLowerValue = 0;
  
void OnTick()
  {
  
      double closePrice = iClose(Symbol(), PERIOD_H4, CANDLE_SHIFT + 1);
      double openPrice = iOpen(Symbol(), Period(), CANDLE_SHIFT);
      
      double priceDiff = openPrice - closePrice;
      double gapSize = MathAbs(priceDiff);
      
      
      PossitionStopLosses();
      
      if(!(gapSize > MIN_GAP_SIZE))
        {
          return;
        }
        
      bool isBullGap = priceDiff > 0;
      
      if(isBullGap && createdOrderAt != iLow(Symbol(), Period(), CANDLE_SHIFT))
        {
            double price = iLow(Symbol(), PERIOD_H4, CANDLE_SHIFT);
            double tpPoints = (gapSize * TP_PERCENT) / 100;
            double tp = price - tpPoints;
            double sl = price + (tpPoints * SL_DEVIDER);
           // MAGIC += 1;  
            createdOrderAt = price;
            double lotSize = CalculateLotSize(sl);
            OrderSend(Symbol(), OP_SELLSTOP, lotSize, price, SLEEPAGE, sl, tp, "Strategy", MAGIC);
        }
      else if(!isBullGap && createdOrderAt != iHigh(Symbol(), Period(), CANDLE_SHIFT))
        {
            double price = iHigh(Symbol(), Period(), CANDLE_SHIFT);
            double tpPoints = (gapSize * TP_PERCENT) / 100;
            double tp = price + tpPoints;
            double sl =  price - (tpPoints * SL_DEVIDER);
           // MAGIC += 1;  
            createdOrderAt = price;
            double lotSize = CalculateLotSize(sl);
            OrderSend(Symbol(), OP_BUYSTOP, lotSize, price, SLEEPAGE, sl, tp, "Strategy", MAGIC);
         
        }  
        
  }
  
void PossitionStopLosses()
{
   int totalOrders = OrdersTotal();  
   
   for(int i=0;i < totalOrders; i++)
   {
      if (OrderSelect(i, SELECT_BY_POS))// Selects the order at the current possition
         {
           if(OrderType() == OP_SELL)
             {
               double tpDiff = MathAbs(OrderOpenPrice() - OrderTakeProfit());
               double currTp = MathAbs(OrderOpenPrice() - Ask);
               double filledPercent = (currTp / tpDiff) * 100;
               
               if(filledPercent >= PERCENT_JUMP && OrderOpenPrice() != OrderStopLoss() && OrderProfit() > 0)
                 {
                   OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), OrderExpiration(), Blue);
                   
                   OrderClose(OrderTicket(), (OrderLots() / LOT_SIZE_CLOSE), Ask, 0, Pink);
                 }
             }
       
            if(OrderType() == OP_BUY)
             {
               double tpDiff = MathAbs(OrderOpenPrice() - OrderTakeProfit());
               double currTp = MathAbs(OrderOpenPrice() - Bid);
               double filledPercent = (currTp / tpDiff) * 100;
               
               
               if(filledPercent >= PERCENT_JUMP && OrderOpenPrice() != OrderStopLoss() && OrderProfit() > 0)
                 {
                   OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), OrderExpiration(), Blue);
                   
                   OrderClose(OrderTicket(), (OrderLots() / LOT_SIZE_CLOSE), Bid, 0, Pink);
                 }
             }
         }
   }
}

double CalculateLotSize(double SL){          //Calculate the size of the position size 
   double LotSize = 0;
   //We get the value of a tick
   double nTickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   //If the digits are 3 or 5 we normalize multiplying by 10
   if(Digits == 3 || Digits == 5){
      nTickValue = nTickValue * 10;
   }
   //We apply the formula to calculate the position size and assign the value to the variable
   LotSize=(AccountBalance() * MAX_RISK_PER_TRADE / 100) / (SL * nTickValue);
   Print(MathFloor(LotSize), "LotSize");
   return MathFloor(LotSize);
}
