CREATE OR REPLACE TYPE t_sum_interval AS OBJECT
(

/* type implements oracles data cartridge interface to compute sum of day to second interval values */

   duration INTERVAL DAY TO SECOND, --duration accumulator

   CONSTRUCTOR FUNCTION t_sum_interval RETURN SELF AS RESULT
      PARALLEL_ENABLE,

   STATIC FUNCTION odciaggregateinitialize(ctx IN OUT t_sum_interval) RETURN NUMBER,

   MEMBER FUNCTION odciaggregateiterate
   (
      SELF  IN OUT t_sum_interval,
      VALUE IN INTERVAL DAY TO SECOND
   ) RETURN NUMBER,

   MEMBER FUNCTION odciaggregatedelete
   (
      SELF  IN OUT t_sum_interval,
      VALUE IN INTERVAL DAY TO SECOND
   ) RETURN NUMBER,

   MEMBER FUNCTION odciaggregateterminate
   (
      SELF        IN t_sum_interval,
      returnvalue OUT INTERVAL DAY TO SECOND,
      flags       IN NUMBER
   ) RETURN NUMBER,

   MEMBER FUNCTION odciaggregatemerge
   (
      SELF IN OUT t_sum_interval,
      ctx  IN t_sum_interval
   ) RETURN NUMBER
)
/

