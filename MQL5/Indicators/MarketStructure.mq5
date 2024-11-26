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
int InpPeriod = 5; // Period

input group "Section :: Style";
input int InpArrowShift = 10; // Arrow shift
input ENUM_ARROW_SIZE InpArrowSize = SMALL_ARROW_SIZE; // Arrow size
input color InpHigherHighColor = clrGreen; // Higher high color
 color InpLowerLowColor = clrRed; // Lower low color

input group "Section :: Dev";
input bool InpDebugEnabled = true; // Endble debug (verbose logging)

// constants
//...

// runtime
int highIdx = 0;
int lowIdx = 0;
int bos = 0;
//ENUM_TREND_TYPE trend = ENUM_TREND_NONE;

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

//ArraySetAsSeries(ExtHighPriceBuffer, true);
   ArrayInitialize(ExtHighPriceBuffer, EMPTY_VALUE);
   SetIndexBuffer(0, ExtHighPriceBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(0, PLOT_LABEL, "Higher High");
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(0, PLOT_ARROW, 159);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, -InpArrowShift);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, InpArrowSize);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, InpHigherHighColor);

//ArraySetAsSeries(ExtLowPriceBuffer, true);
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
//if(prev_calculated == 0)
//  {
//   highIdx = 0;
//   lowIdx = 0;
//   bos = 0;


//Print(high[10]);

//ExtHighPriceBuffer[rates_total-1] = high[rates_total-1];
//ExtLowPriceBuffer[rates_total-1] = low[rates_total-1];
  //}
  
   if(rates_total == prev_calculated)
     {
      return rates_total;
     }

//ArraySetAsSeries(time, true);
//ArraySetAsSeries(high, true);
//ArraySetAsSeries(low, true);

   int limit = rates_total - (prev_calculated == 0 ? 1 : prev_calculated);
   if(InpDebugEnabled)
     {
      PrintFormat("RatesTotal: %i, PrevCalculated: %i, Limit: %i", rates_total, prev_calculated, limit);
     }

//int prevHighIdx = highIdx;
//int prevLowIdx = lowIdx;

//Print("High on ", highIdx, " bar at ", time[highIdx]);
//Print("Low on ", lowIdx, " bar at ", time[lowIdx]);

   for(int i = (prev_calculated == 0 ? 1 : prev_calculated); i < rates_total; i++)
     {
      if(high[i] > high[highIdx])
        {
         if(i - highIdx >= InpPeriod)
           {
            //lowIdx = highIdx;
            //for(int j = highIdx + 1; j <= i; j++)
            //  {
            //   if(low[j] < low[lowIdx])
            //     {
            //      SetLow(high, low, j);
            //      //lowIdx = j;
            //      //Clean(high, low);
            //     }
            //  }

//InpLowerLowColor = clrBlue;
//   PlotIndexSetInteger(1, PLOT_LINE_COLOR, InpLowerLowColor);
            //SetLow(high, low, i);
//InpLowerLowColor = clrRed;
//   PlotIndexSetInteger(1, PLOT_LINE_COLOR, InpLowerLowColor);
            //Print("Calculated Low on ", lowIdx, " bar at ", time[lowIdx], " in range: ", highIdx, "-", i);
            
            
         //SetHigh(high, low, i);
         //Print("High on ", i, " bar at ", time[i]);
           }
         SetHigh(high, low, i);
         Print("High on ", i, " bar at ", time[i]);


         //highIdx = i;
         //bos = 1;
         //Print("High on ", i, " bar at ", time[i], " with BOS=", bos);

         //         ExtHighPriceBuffer[highIdx] = high[highIdx];
         //         for(int j = prevHighIdx + 1; j < highIdx; j++)
         //           {
         //            ExtHighPriceBuffer[j] = EMPTY_VALUE;
         //           }
         //
         //         ExtLowPriceBuffer[lowIdx] = low[lowIdx];
         //         for(int j = prevLowIdx + 1; j < lowIdx; j++)
         //           {
         //            ExtLowPriceBuffer[j] = EMPTY_VALUE;
         //           }

         //Clean(high, low);
        }
      //ExtHighPriceBuffer[highIdx] = high[highIdx];
      //for(int j = prevHighIdx + 1; j < highIdx; j++)
      //  {
      //   ExtHighPriceBuffer[j] = EMPTY_VALUE;
      //  }

      if(low[i] < low[lowIdx])
        {
         if(i - lowIdx >= InpPeriod)
           {
            //highIdx = lowIdx;
            //for(int j = lowIdx + 1; j <= i; j++)
            //  {
            //   if(high[j] > high[highIdx])
            //     {
            //      SetHigh(high, low, j);
            //      //highIdx = j;
            //      //Clean(high, low);
            //     }
            //  }

            //SetHigh(high, low, i);
            //Print("Calculated High on ", highIdx, " bar at ", time[highIdx], " in range: ", lowIdx, "-", i);
            
            
         //SetLow(high, low, i);
         //Print("Low on ", i, " bar at ", time[i]);
           }
         SetLow(high, low, i);
         Print("Low on ", i, " bar at ", time[i]);


         //SetLow(high, low, i);
         //lowIdx = i;
         //bos = -1;
         //Print("Low on ", i, " bar at ", time[i], " with BOS=", bos);

         //         ExtHighPriceBuffer[highIdx] = high[highIdx];
         //         for(int j = prevHighIdx + 1; j < highIdx; j++)
         //           {
         //            ExtHighPriceBuffer[j] = EMPTY_VALUE;
         //           }
         //
         //         ExtLowPriceBuffer[lowIdx] = low[lowIdx];
         //         for(int j = prevLowIdx + 1; j < lowIdx; j++)
         //           {
         //            ExtLowPriceBuffer[j] = EMPTY_VALUE;
         //           }

         //Clean(high, low);
        }
      //ExtLowPriceBuffer[lowIdx] = low[lowIdx];
      //for(int j = prevLowIdx + 1; j < lowIdx; j++)
      //  {
      //   ExtLowPriceBuffer[j] = EMPTY_VALUE;
      //  }

      //ExtHighPriceBuffer[highIdx] = high[highIdx];
      //for(int j = lowIdx; j < highIdx; j++)
      //  {
      //   ExtHighPriceBuffer[j] = EMPTY_VALUE;
      //  }

      //ExtLowPriceBuffer[lowIdx] = low[lowIdx];
      //for(int j = highIdx; j < lowIdx; j++)
      //  {
      //   ExtLowPriceBuffer[j] = EMPTY_VALUE;
      //  }


      //      ExtHighPriceBuffer[highIdx] = high[highIdx];
      //      for(int j = lowIdx; j < highIdx; j++)
      //        {
      //         ExtHighPriceBuffer[j] = EMPTY_VALUE;
      //        }
      //
      //      ExtLowPriceBuffer[lowIdx] = low[lowIdx];
      //      for(int j = highIdx; j < lowIdx; j++)
      //        {
      //         ExtLowPriceBuffer[j] = EMPTY_VALUE;
      //        }


      //prevHighIdx = highIdx;
      //prevLowIdx = lowIdx;

     }

   return rates_total;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//void Clean(const double &high[], const double &low[])
//  {
//   ExtHighPriceBuffer[highIdx] = high[highIdx];
//   for(int j = lowIdx; j < highIdx; j++)
//     {
//      ExtHighPriceBuffer[j] = EMPTY_VALUE;
//     }
//
//   ExtLowPriceBuffer[lowIdx] = low[lowIdx];
//   for(int j = highIdx; j < lowIdx; j++)
//     {
//      ExtLowPriceBuffer[j] = EMPTY_VALUE;
//     }
//  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetHigh(const double &high[], const double &low[], int i)
  {
   //for(int j = lowIdx; j < i; j++)
   //  {
   //   ExtHighPriceBuffer[j] = EMPTY_VALUE;
   //  }

   //for(int j = highIdx; j <= i; j++)
   //  {
   //   //ExtLowPriceBuffer[j] = EMPTY_VALUE;
   //   if(low[j] < low[lowIdx])
   //     {
   //      lowIdx = j;
   //     }
   //  }
   //ExtLowPriceBuffer[lowIdx] = low[lowIdx];
   
   if(i - highIdx >= InpPeriod)
     {
      lowIdx = highIdx;
      for(int j = highIdx + 1; j <= i; j++)
        {
         if(low[j] < low[lowIdx])
           {
            //SetLow(high, low, j);
            lowIdx = j;
            //Clean(high, low);
           }
        }   
        ExtLowPriceBuffer[lowIdx] = low[lowIdx];  
     } else
         {
          ExtHighPriceBuffer[highIdx] = EMPTY_VALUE;
         }

   highIdx = i;
   ExtHighPriceBuffer[highIdx] = high[highIdx];
   //ExtLowPriceBuffer[highIdx] = low[highIdx];
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetLow(const double &high[], const double &low[], int i)
  {
   //for(int j = highIdx; j < i; j++)
   //  {
   //   ExtLowPriceBuffer[j] = EMPTY_VALUE;
   //  }

   //for(int j = lowIdx; j <= i; j++)
   //  {
   //   //ExtHighPriceBuffer[j] = EMPTY_VALUE;
   //   if(high[j] > high[highIdx])
   //     {
   //      highIdx = j;
   //     }
   //  }
   //ExtHighPriceBuffer[highIdx] = high[highIdx];
   
   //for(int j = lowIdx; j <= i; j++)
   //  {
   //   ExtHighPriceBuffer[j] = EMPTY_VALUE;
   //  }


      if(i - lowIdx >= InpPeriod)
        {
         highIdx = lowIdx;
         for(int j = lowIdx + 1; j <= i; j++)
           {
            if(high[j] > high[highIdx])
              {
               //SetHigh(high, low, j);
               highIdx = j;
               //Clean(high, low);
              }
           }
         ExtHighPriceBuffer[highIdx] = high[highIdx];

         //SetHigh(high, low, i);
         //Print("Calculated High on ", highIdx, " bar at ", time[highIdx], " in range: ", lowIdx, "-", i);
         
         
      //SetLow(high, low, i);
      //Print("Low on ", i, " bar at ", time[i]);
        } else
            {
             ExtLowPriceBuffer[lowIdx] = EMPTY_VALUE;
            }

   lowIdx = i;
   ExtLowPriceBuffer[lowIdx] = low[lowIdx];
   //ExtHighPriceBuffer[lowIdx] = high[lowIdx];
  }
//+------------------------------------------------------------------+
