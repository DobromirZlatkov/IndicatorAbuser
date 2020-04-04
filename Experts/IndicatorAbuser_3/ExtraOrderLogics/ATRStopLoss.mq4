
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ATRStopLoss : public IOrderLogic
  {
private:
   double                    increase_factor;
   int                       modified;
public:
                     ATRStopLoss() {};
                     ATRStopLoss(double increase_factor)
     {
      this.increase_factor = increase_factor;
      this.modified = 0;
     }

   void            Execute();
  };
  
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATRStopLoss::Execute(void)
  {
   Print("executing");
   
  }

