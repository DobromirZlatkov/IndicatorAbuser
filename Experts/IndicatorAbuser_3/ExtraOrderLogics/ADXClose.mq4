//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, Toby away |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ADXClose : public IOrderLogic
  {
private:
   double                    close_above;
   double                    close_above_top;
public:
                     ADXClose() {};
                     ADXClose(double close_above_input, double close_above_top_input)
     {
      this.close_above = close_above_input;
      this.close_above_top = close_above_top_input;
     }

   void              Execute();
  };

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ADXClose::Execute(void)
  {
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS))
       {
        double prev_1 = iADX(Symbol(), Period(), 14, PRICE_CLOSE, MODE_MAIN, 1);
        double prev_2 = iADX(Symbol(), Period(), 14, PRICE_CLOSE, MODE_MAIN, 2);
        double prev_3 = iADX(Symbol(), Period(), 14, PRICE_CLOSE, MODE_MAIN, 3);

        if(prev_1 > this.close_above)
         {
            double price = Bid;
            if(OrderType() == OP_SELL)
             {
               price = Ask;
             }
              
            if(OrderClose(OrderTicket(), OrderLots(), price, 0))
             {
              Print("Order closed");
             }
         }
         
         if(prev_2 > this.close_above_top)
           {
            if(prev_3 < prev_2 && prev_1 < prev_2)
              {
                  double price = Bid;
                  if(OrderType() == OP_SELL)
                   {
                     price = Ask;
                   }
                    
                  if(OrderClose(OrderTicket(), OrderLots(), price, 0))
                   {
                     Print("Order closed top");
                   }
              }
           }   
       }
     }
  }

//+------------------------------------------------------------------+
