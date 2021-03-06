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
   double                 cmf_up;
   double                 cmf_down;
public:
                     CMFConfirm() {};
                     CMFConfirm(int period_input, double cmf_up_input, double cmf_down_input)
     {
      this.period = period_input;
      this.cmf_up = cmf_up_input;
      this.cmf_down = cmf_down_input;
     }

   double            GetValue(double shift);
   SIGNAL_TYPE       GetSignal(double shift);
  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMFConfirm::GetValue(double shift)
  {
   double result =  iCustom(Symbol(), Period(), "CMF_v1", this.period, 0, 1);
   return NormalizeDouble(result, 3);
  }
//+------------------------------------------------------------------+
SIGNAL_TYPE CMFConfirm::GetSignal(double shift)
  {
   double value = this.GetValue(shift);
   
   if(value > this.cmf_up)
     {
      return BUY;
     }

   if(value < this.cmf_down)
     {
      return SELL;
     }

   return NO_SIGNAL;
  }
//+------------------------------------------------------------------+
