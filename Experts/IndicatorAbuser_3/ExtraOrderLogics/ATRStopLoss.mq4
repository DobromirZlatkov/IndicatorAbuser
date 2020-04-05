//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, Toby away |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ATRStopLoss : public IOrderLogic
  {
private:
   double                    period;
   double                    emplifier;
   int                       modified;
public:
                     ATRStopLoss() {};
                     ATRStopLoss(double periodInput, double emplifierInput)
     {
      this.period = periodInput;
      this.emplifier = emplifierInput;
      this.modified = 0;
     }

   void              Execute();
  };

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATRStopLoss::Execute(void)
  {


   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS))
        {
         if(OrderStopLoss() != NULL)
           {
            continue;
           }

         double atr = iATR(Symbol(), Period(), this.period, 0);

         if(OrderType() == OP_BUY)
           {
            double slDiff = atr * this.emplifier;
            double sl = OrderOpenPrice() - slDiff;
            if(OrderModify(OrderTicket(), OrderOpenPrice(), sl, OrderTakeProfit(), NULL, clrNavy))
              {
               Print("Added sl");
              }
           }

         if(OrderType() == OP_SELL)
           {
            double slDiff = atr * this.emplifier;
            double sl = OrderOpenPrice() + slDiff;
            if(OrderModify(OrderTicket(), OrderOpenPrice(), sl, OrderTakeProfit(), NULL, clrNavy))
              {
               Print("Added sl");
              }
           }
        }
     }

  }

//+------------------------------------------------------------------+
