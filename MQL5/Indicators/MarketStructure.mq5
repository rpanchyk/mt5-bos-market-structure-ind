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
enum ENUM_ARROW_SIZE
  {
   SMALL_ARROW_SIZE = 1, // Small
   REGULAR_ARROW_SIZE = 2, // Regular
   BIG_ARROW_SIZE = 3, // Big
   HUGE_ARROW_SIZE = 4 // Huge
  };

enum ENUM_TREND_TYPE
  {
   ENUM_TREND_NONE,
   ENUM_TREND_UP,
   ENUM_TREND_DOWN
  };

// buffers
double ExtHighPriceBuffer[]; // higher price
double ExtLowPriceBuffer[]; // lower price

// config
input group "Section :: Main";
//...

input group "Section :: Style";
input int InpArrowShift = 10; // Arrow shift
input ENUM_ARROW_SIZE InpArrowSize = SMALL_ARROW_SIZE; // Arrow size
input color InpHigherHighColor = clrGreen; // Higher high color
input color InpLowerLowColor = clrRed; // Lower low color

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

   ArraySetAsSeries(ExtHighPriceBuffer, true);
   ArrayInitialize(ExtHighPriceBuffer, EMPTY_VALUE);

   SetIndexBuffer(0, ExtHighPriceBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(0, PLOT_LABEL, "Higher High");
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(0, PLOT_ARROW, 159);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, -InpArrowShift);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, InpArrowSize);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, InpHigherHighColor);

   ArraySetAsSeries(ExtLowPriceBuffer, true);
   ArrayInitialize(ExtLowPriceBuffer, EMPTY_VALUE);

   SetIndexBuffer(1, ExtLowPriceBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(1, PLOT_LABEL, "Lower Low");
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(1, PLOT_ARROW, 159);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, InpArrowShift);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, InpArrowSize);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, InpLowerLowColor);

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

   ArrayFill(ExtHighPriceBuffer, 0, ArraySize(ExtHighPriceBuffer), EMPTY_VALUE);
   ArrayFree(ExtHighPriceBuffer);

   ArrayFill(ExtLowPriceBuffer, 0, ArraySize(ExtLowPriceBuffer), EMPTY_VALUE);
   ArrayFree(ExtLowPriceBuffer);

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

   int limit = rates_total - (prev_calculated == 0 ? 1 : prev_calculated);
   //limit = 200;
   if(InpDebugEnabled)
     {
      PrintFormat("RatesTotal: %i, PrevCalculated: %i, Limit: %i", rates_total, prev_calculated, limit);
     }

   int highIdx = limit;
   int lowIdx = limit;
   int bos = 0;

   int InpPeriod = 5;

   Print("High on ", highIdx, " bar at ", time[highIdx]);
   Print("Low on ", lowIdx, " bar at ", time[lowIdx]);

   for(int i = rates_total - 1; i > 0; i--)
     {
      if(high[i] > high[highIdx])
        {
         if(bos == -1 || highIdx - i >= InpPeriod)
           {
            lowIdx = highIdx;
            for(int j = highIdx - 1; j >= i; j--)
              {
               if(low[j] < low[lowIdx])
                 {
                  lowIdx = j;
                 }
              }
            Print("Calculated Low on ", lowIdx, " bar at ", time[lowIdx], " in range: ", i, "-", highIdx);
           }

         highIdx = i;
         bos = 1;
         Print("High on ", i, " bar at ", time[i], " with BOS=", bos);
        }

      if(low[i] < low[lowIdx])
        {
         if(bos == 1 || lowIdx - i >= InpPeriod)
           {
            highIdx = lowIdx;
            for(int j = lowIdx - 1; j >= i; j--)
              {
               if(high[j] > high[highIdx])
                 {
                  highIdx = j;
                 }
              }
            Print("Calculated High on ", highIdx, " bar at ", time[highIdx], " in range: ", i, "-", lowIdx);
           }

         lowIdx = i;
         bos = -1;
         Print("Low on ", i, " bar at ", time[i], " with BOS=", bos);
        }

      ExtHighPriceBuffer[highIdx] = high[highIdx];
      for(int j = lowIdx; j > highIdx; j--)
        {
         ExtHighPriceBuffer[j] = EMPTY_VALUE;
        }

      ExtLowPriceBuffer[lowIdx] = low[lowIdx];
      for(int j = highIdx; j > lowIdx; j--)
        {
         ExtLowPriceBuffer[j] = EMPTY_VALUE;
        }
     }

   return rates_total;
  }
//+------------------------------------------------------------------+
