
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
            double priceDiff = Bid - OrderOpenPrice();
            
            if(priceDiff >= this.pips && OrderLots() > lots_to_close)
              {
               OrderClose(OrderTicket(), lots_to_close, Bid, 0, clrBlueViolet);
              
               if(OrderSelect(OrdersTotal() - 1, SELECT_BY_POS))
                 {
                  OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), NULL, clrNavy);
                  this.modified = OrderTicket();
                 }
              }
           }

         if(OrderType() == OP_SELL)
           {
            double priceDiff = OrderOpenPrice() - Ask;
            
            if(priceDiff >= this.pips && OrderLots() > lots_to_close)
              {
               OrderClose(OrderTicket(), lots_to_close, Ask, 0, clrBlueViolet);
               
                if(OrderSelect(OrdersTotal() - 1, SELECT_BY_POS))
                 {
                   OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), NULL, clrNavy);
                   this.modified = OrderTicket();
                 }
              }
           }
        }
     }
     
     for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS))
        {
         if(OrderType() == OP_BUY)
           {
            double priceDiff = Bid - OrderOpenPrice();
            
            if(priceDiff >= this.pips && OrderLots() > lots_to_close)
              {
               OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), NULL, clrNavy);
               
               this.modified = OrderTicket();
              }
           }

         if(OrderType() == OP_SELL)
           {
            double priceDiff = OrderOpenPrice() - Ask;
            
            if(priceDiff >= this.pips && OrderLots() > lots_to_close)
              {
               OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), NULL, clrNavy);
               
               this.modified = OrderTicket();
              }
           }
        }
     }
  }

