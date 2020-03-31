//+------------------------------------------------------------------+
//|                                                 Indicator Abuser |
//|                                  Copyright 2020, Tobi-away Corp. |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include "Enums.mq4"

interface ISignalIndicator
  {
   SIGNAL_TYPE GetSignal();

   double GetValue();
  };
//+------------------------------------------------------------------+
