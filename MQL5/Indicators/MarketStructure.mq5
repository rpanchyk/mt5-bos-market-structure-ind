//+------------------------------------------------------------------+
//|                                              MarketStructure.mq5 |
//|                                         Copyright 2024, rpanchyk |
//|                                      https://github.com/rpanchyk |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2024, rpanchyk"
#property link        "https://github.com/rpanchyk"
#property version     "1.00"
#property description "Indicator shows market structure"

#property indicator_chart_window
#property indicator_plots 2
#property indicator_buffers 2

// types
enum ENUM_TREND_TYPE
  {
   ENUM_TREND_NONE,
   ENUM_TREND_UP,
   ENUM_TREND_DOWN
  };

//class ExtPoint
//  {
//public:
//                     ExtPoint(
//      int               index,
//      datetime          time,
//      double            price
//   ) :
//                     m_Index(index),
//                     m_Time(time),
//                     m_Price(price)
//     {};
//                    ~ExtPoint() {};
//   int               GetIndex() { return m_Index; }
//   void              SetIndex(int index) { m_Index = index; }
//   datetime          GetTime() { return m_Time; }
//   void              SetTime(datetime time) { m_Time = time; }
//   double            GetPrice() { return m_Price; }
//   void              SetPrice(double price) { m_Price = price; }
//private:
//   int               m_Index;
//   datetime          m_Time;
//   double            m_Price;
//  };

// buffers
double MarketStructureHighPriceBuffer[]; // higher price
double MarketStructureLowPriceBuffer[]; // lower price

// config
input group "Section :: Main";
//...

input group "Section :: Dev";
input bool InpDebugEnabled = true; // Endble debug (verbose logging)

// constants
//...

// runtime
ENUM_TREND_TYPE trend = ENUM_TREND_NONE;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpDebugEnabled)
     {
      Print("MarketStructure indicator initialization started");
     }

   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   ArraySetAsSeries(MarketStructureHighPriceBuffer, true);
   ArrayInitialize(MarketStructureHighPriceBuffer, EMPTY_VALUE);

   SetIndexBuffer(0, MarketStructureHighPriceBuffer, INDICATOR_DATA);
   PlotIndexSetString(0, PLOT_LABEL, "Higher High");
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(0, PLOT_ARROW, 159);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, -1);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 4);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrGreen);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   ArraySetAsSeries(MarketStructureLowPriceBuffer, true);
   ArrayInitialize(MarketStructureLowPriceBuffer, EMPTY_VALUE);

   SetIndexBuffer(1, MarketStructureLowPriceBuffer, INDICATOR_DATA);
   PlotIndexSetString(1, PLOT_LABEL, "Lower Low");
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(1, PLOT_ARROW, 159);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, 1);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 4);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   if(InpDebugEnabled)
     {
      Print("MarketStructure indicator initialization finished");
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(InpDebugEnabled)
     {
      Print("MarketStructure indicator deinitialization started");
     }

   ArrayFill(MarketStructureHighPriceBuffer, 0, ArraySize(MarketStructureHighPriceBuffer), EMPTY_VALUE);
   ArrayFill(MarketStructureLowPriceBuffer, 0, ArraySize(MarketStructureLowPriceBuffer), EMPTY_VALUE);

   ArrayFree(MarketStructureHighPriceBuffer);
   ArrayFree(MarketStructureLowPriceBuffer);

   if(InpDebugEnabled)
     {
      Print("MarketStructure indicator deinitialization finished");
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(rates_total == prev_calculated)
     {
      return rates_total;
     }

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   int limit = rates_total - (prev_calculated < 1 ? 1 : prev_calculated);
   if(InpDebugEnabled)
     {
      PrintFormat("RatesTotal: %i, PrevCalculated: %i, Limit: %i", rates_total, prev_calculated, limit);
     }

   limit = 100;
//ExtPoint prevHigh(start, time[start], high[start]);
//ExtPoint prevLow(start, time[start], low[start]);
//ExtPoint currHigh(-1, NULL, 0);
//ExtPoint currLow(-1, NULL, 0);

   double max = high[limit];
   int maxIndex = limit;
//double prevMax = 0;
//bool maxSwept = false;

   double min = low[limit];
   int minIndex = limit;
//double prevMin = 0;
//bool minSwept = false;

   MarketStructureHighPriceBuffer[maxIndex] = max;
   MarketStructureLowPriceBuffer[minIndex] = min;
   trend = ENUM_TREND_NONE;

   for(int i = limit - 1; i > 0; i--) // Go from left to right bars
     {
      //Print(i);

      //if(prevHigh.GetIndex() == -1)
      //  {
      //   prevHigh.SetIndex(i);
      //   prevHigh.SetTime(time[i]);
      //   prevHigh.SetPrice(high[i]);
      //  }
      //if(prevLow.GetIndex() == -1)
      //  {
      //   prevLow.SetIndex(i);
      //   prevLow.SetTime(time[i]);
      //   prevLow.SetPrice(low[i]);
      //  }

      if(high[i] > max)
        {
         if(trend == ENUM_TREND_NONE || trend == ENUM_TREND_DOWN)
           {
            MarketStructureLowPriceBuffer[minIndex] = min;
            //min = high[GetPrevMax(i)];
            //Print("BoS UP, i=", i, " min=", min);

            Print("BoS from DOWN to UP, i=", i, " at ", time[i]);
           }

         trend = ENUM_TREND_UP;
         max = high[i];
         maxIndex = i;
         //maxSwept = true;
         //minSwept = false;

         //int prevIdx = ArraySize(MarketStructureLowPriceBuffer) - 1;
         //for(int j = i; j < ArraySize(MarketStructureLowPriceBuffer); j++)
         //  {
         //   if(MarketStructureLowPriceBuffer[j] > 0)
         //     {
         //      prevIdx = j;
         //      break;
         //     }
         //  }
         //int lowestIdx = iLowest(_Symbol, PERIOD_CURRENT, MODE_LOW, prevIdx - i, prevIdx);
         //MarketStructureLowPriceBuffer[lowestIdx] = low[lowestIdx];

         //int lowestIdx = iLowest(_Symbol, PERIOD_CURRENT, MODE_LOW, prevIdx - i, prevIdx);
         //MarketStructureLowPriceBuffer[lowestIdx] = low[lowestIdx];

         //min = 0;

         //Print(i, " = ", lowestIdx);

         //         if(minSwept)
         //           {
         //            //prevMax = max;
         //
         //            // draw LL point
         //            //MarketStructureLowPriceBuffer[minIndex] = min;
         //            //min = 0;
         //           }
         //         //MarketStructureHighPriceBuffer[maxIndex] = 0;
         //         max = high[i];
         //         maxIndex = i;
         //         maxSwept = true;
         //         minSwept = false;
         //         //MarketStructureHighPriceBuffer[i] = high[i];
         //         //Print("high");
        }

      if(low[i] < min)
        {
         if(trend == ENUM_TREND_NONE || trend == ENUM_TREND_UP)
           {
            MarketStructureHighPriceBuffer[maxIndex] = max;
            //max = low[GetPrevMin(i)];
            //Print("BoS DOWN, i=", i, " max=", max);

            Print("BoS from UP to DOWN, i=", i, " at ", time[i]);
           }

         trend = ENUM_TREND_DOWN;
         min = low[i];
         minIndex = i;
         //minSwept = true;
         //maxSwept = false;


         //int prevIdx = ArraySize(MarketStructureHighPriceBuffer) - 1;
         // for(int j = i; j < ArraySize(MarketStructureHighPriceBuffer); j++)
         //   {
         //    if(MarketStructureHighPriceBuffer[j] > 0)
         //      {
         //       prevIdx = j;
         //       Print("==========", prevIdx);
         //       break;
         //      }
         //   }
         //         int highestIdx = iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, prevIdx - i, prevIdx);
         //         MarketStructureHighPriceBuffer[highestIdx] = high[highestIdx];
         //
         //         min = low[i];
         //         max = 0;

         //         if(maxSwept)
         //           {
         //            //prevMin = min;
         //
         //            // draw HH point
         //            //MarketStructureHighPriceBuffer[maxIndex] = max;
         //            //max = 0;
         //           }
         //MarketStructureLowPriceBuffer[minIndex] = 0;
         //min = low[i];
         //minIndex = i;
         //minSwept = true;
         //maxSwept = false;
         //MarketStructureLowPriceBuffer[i] = low[i];
         //Print("low");
        }

      //if(minSwept)
      //  {
      //   MarketStructureHighPriceBuffer[maxIndex] = max;
      //   max = INT_MIN;
      //   minSwept = false;
      //  }
      //if(maxSwept)
      //  {
      //   MarketStructureLowPriceBuffer[minIndex] = min;
      //   min = INT_MAX;
      //   maxSwept = false;
      //  }
     }

   return rates_total;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetPrevMin(int index)
  {
   for(int i = index; i < ArraySize(MarketStructureLowPriceBuffer); i++)
     {
      if(MarketStructureLowPriceBuffer[i] > 0)
        {
         return i;
        }
     }
   return ArraySize(MarketStructureLowPriceBuffer) - 1;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetPrevMax(int index)
  {
   for(int i = index; i < ArraySize(MarketStructureHighPriceBuffer); i++)
     {
      if(MarketStructureHighPriceBuffer[i] > 0)
        {
         return i;
        }
     }
   return ArraySize(MarketStructureHighPriceBuffer) - 1;
  }
//+------------------------------------------------------------------+
