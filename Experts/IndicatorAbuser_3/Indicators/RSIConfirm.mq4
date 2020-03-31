//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "Enums.mq4"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class RSIConfirm : public ISignalIndicator
  {
private:
   ENUM_APPLIED_PRICE     applied_price;
   int                    period;
public:
                     RSIConfirm() {};
                     RSIConfirm(ENUM_APPLIED_PRICE applied_price, int period)
     {
      this.applied_price = applied_price;
      this.period = period;
     }

   double            GetValue();
   SIGNAL_TYPE       GetSignal();
  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RSIConfirm::GetValue(void)
  {
   double result =  iRSI(Symbol(), Period(), this.period, this.applied_price, 0);
   return NormalizeDouble(result, 3);
  }
//+------------------------------------------------------------------+
SIGNAL_TYPE RSIConfirm::GetSignal(void)
  {
   double rsi = this.GetValue();

   if(rsi > 70)
     {
      return BUY;
     }

   if(rsi < 30)
     {
      return SELL;
     }

   return NO_SIGNAL;
  }
//+------------------------------------------------------------------+
