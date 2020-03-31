//+------------------------------------------------------------------+
//|                                                 Indicator Abuser |
//|                                  Copyright 2020, Tobi-away Corp. |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#include "../Indicators/Enums.mq4";
#include "../Indicators/ISignalIndicator.mq4";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ApplyDirectlyStrategy : public IStrategy
  {
private:
   ISignalIndicator* base_line;
   ISignalIndicator* exit_indicator;
   ISignalIndicator* confirm_indicator1;
   ISignalIndicator* confirm_indicator2;

public:
                     ApplyDirectlyStrategy() {}
                     ApplyDirectlyStrategy(ISignalIndicator* base_line, ISignalIndicator* exit_indicator, ISignalIndicator* confirm_indicator1, ISignalIndicator* confirm_indicator2)
     {
      this.base_line = base_line;
      this.exit_indicator = exit_indicator;
      this.confirm_indicator1 = confirm_indicator1;
      this.confirm_indicator2 = confirm_indicator2;
     }

   void              Execute();
   void              CloseOrders(int type);
   bool              IsNewCandle();
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ApplyDirectlyStrategy::IsNewCandle()
  {
   static int BarsOnChart=0;
   if(Bars==BarsOnChart)
      return(false);
   BarsOnChart=Bars;
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ApplyDirectlyStrategy::Execute()
  {
   double base_line_signal = this.base_line.GetSignal();
   double should_exit = this.exit_indicator.GetSignal();

   if(!this.IsNewCandle())
     {
      return;
     }

   if(should_exit == BUY)
     {
      CloseOrders(OP_BUY);
     }
   if(should_exit == SELL)
     {
      CloseOrders(OP_SELL);
     }
     
   double confirm_indicator1_signal = this.confirm_indicator1.GetSignal(); 
   double confirm_indicator2_signal = this.confirm_indicator2.GetSignal(); 

   if(base_line_signal == BUY && confirm_indicator1_signal == BUY && confirm_indicator2_signal == BUY)
     {
      if(OrdersTotal() > 0)
        {
         return;
        }

      OrderSend(Symbol(), OP_BUY, 0.02, Ask, 0, 0, 0, NULL, 1233214);
     }

   if(base_line_signal == SELL && confirm_indicator1_signal == SELL && confirm_indicator2_signal == SELL)
     {
      if(OrdersTotal() > 0)
        {
         return;
        }

      OrderSend(Symbol(), OP_SELL, 0.02, Bid, 0, 0, 0, NULL, 1233214);
     }
  }

//+------------------------------------------------------------------+
void ApplyDirectlyStrategy::CloseOrders(int type)
  {
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS))
        {
         if(OrderType() == type && type == OP_BUY)
           {
            OrderClose(OrderTicket(), OrderLots(), Bid, 0);
           }

         if(OrderType() == type && type == OP_SELL)
           {
            OrderClose(OrderTicket(), OrderLots(), Ask, 0);
           }
        }
     }
  }
//+------------------------------------------------------------------+
