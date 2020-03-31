
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class PartialCloseOnPips : public IOrderLogic
  {
private:
   double                    lots_to_close;
   double                    pips;
   int                       modified;
public:
                     PartialCloseOnPips() {};
                     PartialCloseOnPips(double lots_to_close, double pips)
     {
      this.lots_to_close = lots_to_close;
      this.pips = pips;
      this.modified = 0;
     }

   void            Execute();
  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PartialCloseOnPips::Execute(void)
  {
   
    for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS))
        {
         if(OrderType() == OP_BUY)
           {
            double profit = OrderProfit();
            printf(profit);
            if(profit >= this.pips && this.modified != OrderTicket())
              {
               OrderClose(OrderTicket(), lots_to_close, Bid, clrBlueViolet);
               OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), NULL, clrNavy);
               
               this.modified = OrderTicket();
              }
           }

         if(OrderType() == OP_SELL)
           {
            double profit = OrderProfit();
            
            printf(profit);
            
            if(profit >= this.pips && this.modified != OrderTicket())
              {
               OrderClose(OrderTicket(), lots_to_close, Ask, clrBlueViolet);
               OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), NULL, clrNavy);
               
               this.modified = OrderTicket();
              }
           }
        }
     }
  }

