//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, Toby away |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ExitOnAllIndicatorsConfirm : public IOrderLogic
  {
private:
   ISignalIndicator* confirm_indicators[];
public:
                     ExitOnAllIndicatorsConfirm() {};
                     ExitOnAllIndicatorsConfirm(ISignalIndicator* &confirm_indicators_input[])
     {
      ArrayCopy(this.confirm_indicators, confirm_indicators_input);
     }

   void              Execute();
  };

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ExitOnAllIndicatorsConfirm::Execute(void)
  {
     for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS))
        {
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
          
         // Print(this.confirm_indicators[0].GetSignal(0), this.confirm_indicators[1].GetSignal(0), this.confirm_indicators[2].GetSignal(0));
          
          if(all_sell && OrderType() == OP_BUY)
            {
             if(OrderClose(OrderTicket(), OrderLots(), Bid, 0))
               {
                Print("Order closed ExitOnAllIndicatorsConfirm");
                
                Print(this.confirm_indicators[0].GetSignal(0), this.confirm_indicators[1].GetSignal(0), this.confirm_indicators[2].GetSignal(0));
               }
            }
          if(all_buy && OrderType() == OP_SELL)
             {
               if(OrderClose(OrderTicket(), OrderLots(), Ask, 0))
               {
                Print("Order closed ExitOnAllIndicatorsConfirm");
                
                Print(this.confirm_indicators[0].GetSignal(0), this.confirm_indicators[1].GetSignal(0), this.confirm_indicators[2].GetSignal(0));
               }
             }
        }
     }
  }

//+------------------------------------------------------------------+
