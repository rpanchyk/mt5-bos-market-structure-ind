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
#property indicator_plots 4
#property indicator_buffers 4

// types
enum ENUM_ARROW_SIZE
  {
   SMALL_ARROW_SIZE = 1, // Small
   REGULAR_ARROW_SIZE = 2, // Regular
   BIG_ARROW_SIZE = 3, // Big
   HUGE_ARROW_SIZE = 4 // Huge
  };

// buffers
double ExtHighPriceBuffer[]; // Higher price
double ExtLowPriceBuffer[]; // Lower price
double ExtCalcHighPriceBuffer[]; // Calculated higher price (between lows)
double ExtCalcLowPriceBuffer[]; // Calculated lower price (between highs)

// config
input group "Section :: Main";
input int InpPeriod = 10; // Period
input bool InpCalcHighLowEnabled = false; // Separate calculated High/Low

input group "Section :: Style";
input int InpArrowShift = 10; // Arrow shift
input ENUM_ARROW_SIZE InpArrowSize = REGULAR_ARROW_SIZE; // Arrow size
input color InpHigherHighColor = clrGreen; // Higher high color
input color InpLowerLowColor = clrRed; // Lower low color
input color InpCalcHigherHighColor = clrYellowGreen; // Calculated higher high color
input color InpCalcLowerLowColor = clrLightCoral; // Calculated lower low color

input group "Section :: Dev";
input bool InpDebugEnabled = true; // Enable debug (verbose logging)

// runtime
int highIdx;
int lowIdx;

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

   ArrayInitialize(ExtHighPriceBuffer, EMPTY_VALUE);
   SetIndexBuffer(0, ExtHighPriceBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(0, PLOT_LABEL, "High");
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(0, PLOT_ARROW, 159);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, -InpArrowShift);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, InpArrowSize);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, InpHigherHighColor);

   ArrayInitialize(ExtLowPriceBuffer, EMPTY_VALUE);
   SetIndexBuffer(1, ExtLowPriceBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(1, PLOT_LABEL, "Low");
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(1, PLOT_ARROW, 159);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, InpArrowShift);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, InpArrowSize);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, InpLowerLowColor);

   ArrayInitialize(ExtCalcHighPriceBuffer, EMPTY_VALUE);
   SetIndexBuffer(2, ExtCalcHighPriceBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(2, PLOT_LABEL, "Calculated High");
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(2, PLOT_ARROW, 159);
   PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, -InpArrowShift - InpArrowShift);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, InpArrowSize);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, InpCalcHigherHighColor);

   ArrayInitialize(ExtCalcLowPriceBuffer, EMPTY_VALUE);
   SetIndexBuffer(3, ExtCalcLowPriceBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(3, PLOT_LABEL, "Calculated Low");
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(3, PLOT_ARROW, 159);
   PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, InpArrowShift + InpArrowShift);
   PlotIndexSetInteger(3, PLOT_LINE_WIDTH, InpArrowSize);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, InpCalcLowerLowColor);

   highIdx = 0;
   lowIdx = 0;

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
   ArrayResize(ExtHighPriceBuffer, 0);
   ArrayFree(ExtHighPriceBuffer);

   ArrayFill(ExtLowPriceBuffer, 0, ArraySize(ExtLowPriceBuffer), EMPTY_VALUE);
   ArrayResize(ExtLowPriceBuffer, 0);
   ArrayFree(ExtLowPriceBuffer);

   ArrayFill(ExtCalcHighPriceBuffer, 0, ArraySize(ExtCalcHighPriceBuffer), EMPTY_VALUE);
   ArrayResize(ExtCalcHighPriceBuffer, 0);
   ArrayFree(ExtCalcHighPriceBuffer);

   ArrayFill(ExtCalcLowPriceBuffer, 0, ArraySize(ExtCalcLowPriceBuffer), EMPTY_VALUE);
   ArrayResize(ExtCalcLowPriceBuffer, 0);
   ArrayFree(ExtCalcLowPriceBuffer);

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

   int limit = rates_total - (prev_calculated == 0 ? 1 : prev_calculated);
   if(InpDebugEnabled)
     {
      PrintFormat("RatesTotal: %i, PrevCalculated: %i, Limit: %i", rates_total, prev_calculated, limit);
     }

   for(int i = (prev_calculated == 0 ? 1 : prev_calculated); i < rates_total; i++)
     {
      if(high[i] > high[highIdx])
        {
         SetHigh(time, high, low, i);
        }
      if(low[i] < low[lowIdx])
        {
         SetLow(time, high, low, i);
        }
     }

   return rates_total;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetHigh(const datetime &time[], const double &high[], const double &low[], int i)
  {
   if(i - highIdx >= InpPeriod)
     {
      lowIdx = highIdx;
      for(int j = highIdx + 1; j <= i; j++)
        {
         if(low[j] < low[lowIdx])
           {
            lowIdx = j;
           }
        }

      if(ExtLowPriceBuffer[lowIdx] == EMPTY_VALUE || ExtLowPriceBuffer[lowIdx] <= 0.0)
        {
         if(InpCalcHighLowEnabled)
           {
            ExtCalcLowPriceBuffer[lowIdx] = low[lowIdx];
           }
         else
           {
            ExtLowPriceBuffer[lowIdx] = low[lowIdx];
           }
         if(InpDebugEnabled)
           {
            Print("Calculated Low on ", lowIdx, " bar at ", time[lowIdx], " in range: ", highIdx, "-", i);
           }
        }
     }
   else
     {
      if(lowIdx < highIdx)
        {
         ExtHighPriceBuffer[highIdx] = EMPTY_VALUE;
        }
     }

   highIdx = i;
   ExtHighPriceBuffer[highIdx] = high[highIdx];
   if(InpDebugEnabled)
     {
      Print("High on ", highIdx, " bar at ", time[highIdx]);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetLow(const datetime &time[], const double &high[], const double &low[], int i)
  {
   if(i - lowIdx >= InpPeriod)
     {
      highIdx = lowIdx;
      for(int j = lowIdx + 1; j <= i; j++)
        {
         if(high[j] > high[highIdx])
           {
            highIdx = j;
           }
        }
      if(ExtHighPriceBuffer[highIdx] == EMPTY_VALUE || ExtHighPriceBuffer[highIdx] <= 0.0)
        {
         if(InpCalcHighLowEnabled)
           {
            ExtCalcHighPriceBuffer[highIdx] = high[highIdx];
           }
         else
           {
            ExtHighPriceBuffer[highIdx] = high[highIdx];
           }
         if(InpDebugEnabled)
           {
            Print("Calculated High on ", highIdx, " bar at ", time[highIdx], " in range: ", lowIdx, "-", i);
           }
        }
     }
   else
     {
      if(highIdx < lowIdx)
        {
         ExtLowPriceBuffer[lowIdx] = EMPTY_VALUE;
        }
     }

   lowIdx = i;
   ExtLowPriceBuffer[lowIdx] = low[lowIdx];
   if(InpDebugEnabled)
     {
      Print("Low on ", lowIdx, " bar at ", time[lowIdx]);
     }
  }
//+------------------------------------------------------------------+
