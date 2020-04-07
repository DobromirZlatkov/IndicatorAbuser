//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MoveSLOnPips : public IOrderLogic
  {
private:
   double                    pips;
public:
                     MoveSLOnPips() {};
                     MoveSLOnPips(double pips_input)
     {
      this.pips = pips_input;
     }

   void              Execute();
  };

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MoveSLOnPips::Execute(void)
  {

   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS))
        {
         if(OrderType() == OP_BUY)
           {
            double priceDiff = Bid - OrderOpenPrice();

            if(priceDiff >= this.pips && !(OrderStopLoss() > 0))
              {
               OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), NULL, clrNavy);
              }
           }

         if(OrderType() == OP_SELL)
           {
            double priceDiff = OrderOpenPrice() - Ask;

            if(priceDiff >= this.pips && !(OrderStopLoss() > 0))
              {
               OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), NULL, clrNavy);
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
