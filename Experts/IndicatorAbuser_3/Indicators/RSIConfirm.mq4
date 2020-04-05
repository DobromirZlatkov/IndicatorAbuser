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
                     RSIConfirm(ENUM_APPLIED_PRICE applied_price_input, int period_input)
     {
      this.applied_price = applied_price_input;
      this.period = period_input;
     }

   double            GetValue(double shift);
   SIGNAL_TYPE       GetSignal(double shift);
  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RSIConfirm::GetValue(double shift)
  {
   double result =  iRSI(Symbol(), Period(), this.period, this.applied_price, 0);
   return NormalizeDouble(result, 3);
  }
//+------------------------------------------------------------------+
SIGNAL_TYPE RSIConfirm::GetSignal(double shift)
  {
   double rsi = this.GetValue(shift);

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
