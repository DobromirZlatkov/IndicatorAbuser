//+------------------------------------------------------------------+
//|                                            IndicatorAbuser_3.mq4 |
//|                                  Copyright 2020, Tobi-away Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include "StrategyBuilder.mq4"
#include "Strategies/IStrategy.mq4"

#property strict


input STRATEGY_TYPES STRATEGY_TYPE = APPLY_DIRECTLY_STRATEGY;
input BASE_LINE_SIGANAL_TYPES BASE_LINE_SIGANAL_TYPE = MA_CANDLE_CLOSE_IN_DIRECTION;

input ENUM_MA_METHOD BASE_LINE_TYPES = MODE_SMA;
input ENUM_APPLIED_PRICE BASE_LINE_APPLIED_PRICE = PRICE_CLOSE;
extern int BASE_LINE_PERIOD = 50;
extern int BASE_LINE_SHIFT = 0;

input EXIT_SIGNAL_TYPES EXIT_SIGNAL_TYPE = REX_CROSS;
extern int REX_SMOOTHING_LENGHT = 14;
extern int REX_SMOOTHING_METHOD = 0;
extern int REX_SIGNAL_LENGHT = 14;
extern int REX_SIGNAL_METHOD = 0;

input CONFIRMATION_TYPES CONFIRMATION_TYPE = RSI_CONFIRM;
input ENUM_APPLIED_PRICE ENUM_APPLIED_PRICES = PRICE_CLOSE;
extern int RSI_ECONFIRM_PERIOD = 14;

input CONFIRMATION_TYPES CONFIRMATION_2_TYPE = CMF_CONFIRM;
extern int CMF_ECONFIRM_PERIOD = 20;

input EXTRA_ORDER_LOGICS EXTRA_ORDER_LOGIC = PARTIAL_CLOSE_ON_PIPS;
extern double PRICE_DIFF = 0.03;
extern double LOT_TO_CLOSE = 0.01;


IStrategy* strategy;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   StrategyBuilder* strategy_builder = new StrategyBuilder(
      // BASE LINE
      STRATEGY_TYPE,
      BASE_LINE_SIGANAL_TYPE,
      BASE_LINE_TYPES,
      BASE_LINE_APPLIED_PRICE,
      BASE_LINE_PERIOD,
      BASE_LINE_SHIFT,
      
      // EXIT INDICATOR
      EXIT_SIGNAL_TYPE,
      REX_SMOOTHING_LENGHT,
      REX_SMOOTHING_METHOD,
      REX_SIGNAL_LENGHT,
      REX_SIGNAL_METHOD,
      
      // CONFIRM INDICATOR
      CONFIRMATION_TYPE,
      ENUM_APPLIED_PRICES,
      RSI_ECONFIRM_PERIOD,
      
      // COMFIRM 2 INDICATOR
      CONFIRMATION_2_TYPE,
      CMF_ECONFIRM_PERIOD,
      
      // EXTRA ORDER LOGIC
      EXTRA_ORDER_LOGIC,
      PRICE_DIFF,
      LOT_TO_CLOSE
      );

   strategy = strategy_builder.Build();

   delete strategy_builder;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

   delete strategy;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   strategy.Execute();

  }
//+------------------------------------------------------------------+
