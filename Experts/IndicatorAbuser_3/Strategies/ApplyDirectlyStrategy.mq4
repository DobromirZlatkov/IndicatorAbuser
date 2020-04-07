//+------------------------------------------------------------------+
//|                                                 Indicator Abuser |
//|                                  Copyright 2020, Tobi-away Corp. |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#include "../Indicators/Enums.mq4";
#include "../Indicators/ISignalIndicator.mq4";
#include "../ExtraOrderLogics/IOrderLogic.mq4";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ApplyDirectlyStrategy : public IStrategy
  {
private:
   ISignalIndicator* base_line;
   ISignalIndicator* exit_indicator;
   
   ISignalIndicator* confirm_indicators[];
   
   //ISignalIndicator* confirm_indicator1;
   //ISignalIndicator* confirm_indicator2;
   
   IOrderLogic*      order_logics[];
   
   int               dont_trade_after;
   int               dont_trade_before;       

public:
                     ApplyDirectlyStrategy() {}
                     ApplyDirectlyStrategy(
                        ISignalIndicator* base_line_input,
                        ISignalIndicator* exit_indicator_input,
                        ISignalIndicator* confirm_indicators_input[],
                        //ISignalIndicator* confirm_indicator1,
                        //ISignalIndicator* confirm_indicator2,
                        IOrderLogic* orderLogics[],
                        int dont_trade_after_input,
                        int dont_trade_before_input)
     {
      this.base_line = base_line_input;
      this.exit_indicator = exit_indicator_input;
      //this.confirm_indicator1 = confirm_indicator1;
      //this.confirm_indicator2 = confirm_indicator2;
      
      this.dont_trade_after = dont_trade_after_input;
      this.dont_trade_before = dont_trade_before_input;
      
      ArrayCopy(this.confirm_indicators, confirm_indicators_input);
      ArrayCopy(this.order_logics, orderLogics);
     }

   void              Execute();
   void              CloseOrders(int type);
   bool              IsNewCandle();
   double            CalculateLot();
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
double ApplyDirectlyStrategy::CalculateLot()
  {
   double lot_size = 0.02;
   return lot_size;
   for(int i = OrdersHistoryTotal() - 1; i > 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderProfit() > 0)
           {
             return lot_size;
           }
         
           lot_size += OrderLots() * 2;
        }
     }
     
    
    return lot_size;  
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ApplyDirectlyStrategy::Execute()
  {
   for (int i = 0; i <= ArraySize(this.order_logics) - 1; i++)
    {
       this.order_logics[i].Execute();
    }
  
   double base_line_signal = this.base_line.GetSignal(0);
   double should_exit = this.exit_indicator.GetSignal(0);

   if(!this.IsNewCandle())
     {
      return;
     }
     
   if(Hour() > this.dont_trade_after || Hour() < this.dont_trade_before)
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
     
   bool all_buy = true;
   bool all_sell = true;
     
   for (int i = 0; i <= ArraySize(this.confirm_indicators) - 1; i++)
    {
      double signal = this.confirm_indicators[i].GetSignal(0);
      
      if(signal == SELL || signal == NO_SIGNAL)
        {
         all_buy = false;
        }
        
      if(signal == BUY || signal == NO_SIGNAL)
        {
         all_sell = false;
        }  
    }  
    
   double lots_size = this.CalculateLot(); 
      
   if(base_line_signal == BUY && all_buy)
     {
      if(OrdersTotal() > 0)
        {
         return;
        }

      OrderSend(Symbol(), OP_BUY, lots_size, Ask, 0, 0, 0, NULL, 1233214);
     }

   if(base_line_signal == SELL && all_sell)
     {
      if(OrdersTotal() > 0)
        {
         return;
        }

      OrderSend(Symbol(), OP_SELL, lots_size, Bid, 0, 0, 0, NULL, 1233214);
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
