CREATE OR REPLACE TYPE BODY t_sum_interval IS

   -------------------------------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION t_sum_interval RETURN SELF AS RESULT
      PARALLEL_ENABLE IS
   BEGIN
      RETURN;
   END t_sum_interval;

   -------------------------------------------------------------------------------------------------
   STATIC FUNCTION odciaggregateinitialize(ctx IN OUT t_sum_interval) RETURN NUMBER IS
   BEGIN
      ctx := t_sum_interval();
      RETURN odciconst.success;
   END odciaggregateinitialize;

   -------------------------------------------------------------------------------------------------
   MEMBER FUNCTION odciaggregateiterate
   (
      SELF  IN OUT t_sum_interval,
      VALUE IN INTERVAL DAY TO SECOND
   ) RETURN NUMBER IS
   BEGIN
      IF SELF.duration IS NULL THEN
         SELF.duration := VALUE;
      ELSE
         SELF.duration := SELF.duration + VALUE;
      END IF;
      RETURN odciconst.success;
   END odciaggregateiterate;

   -------------------------------------------------------------------------------------------------
   MEMBER FUNCTION odciaggregateterminate
   (
      SELF        IN t_sum_interval,
      returnvalue OUT INTERVAL DAY TO SECOND,
      flags       IN NUMBER
   ) RETURN NUMBER IS
   BEGIN
      returnvalue := SELF.duration;
      RETURN odciconst.success;
   END odciaggregateterminate;

   -------------------------------------------------------------------------------------------------
   MEMBER FUNCTION odciaggregatedelete
   (
      SELF  IN OUT t_sum_interval,
      VALUE IN INTERVAL DAY TO SECOND
   ) RETURN NUMBER IS
   BEGIN
      SELF.duration := SELF.duration - VALUE;
      RETURN odciconst.success;
   END odciaggregatedelete;

   -------------------------------------------------------------------------------------------------
   MEMBER FUNCTION odciaggregatemerge
   (
      SELF IN OUT t_sum_interval,
      ctx  IN t_sum_interval
   ) RETURN NUMBER IS
   BEGIN
      IF ctx.duration IS NULL THEN
         NULL;
      ELSE
         SELF.duration := SELF.duration + ctx.duration;
      END IF;
      RETURN odciconst.success;
   END odciaggregatemerge;

END;
/

