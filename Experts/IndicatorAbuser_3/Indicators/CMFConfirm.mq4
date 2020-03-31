//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "Enums.mq4"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMFConfirm : public ISignalIndicator
  {
private:
   int                    period;
public:
                     CMFConfirm() {};
                     CMFConfirm(int period)
     {
      this.period = period;
     }

   double            GetValue();
   SIGNAL_TYPE       GetSignal();
  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMFConfirm::GetValue(void)
  {
   double result =  iCustom(Symbol(), Period(), "CMF_v1", this.period, 0, 1);
   return NormalizeDouble(result, 3);
  }
//+------------------------------------------------------------------+
SIGNAL_TYPE CMFConfirm::GetSignal(void)
  {
   double value = this.GetValue();
   
   if(value > 0)
     {
      return BUY;
     }

   if(value < 0)
     {
      return SELL;
     }

   return NO_SIGNAL;
  }
//+------------------------------------------------------------------+
