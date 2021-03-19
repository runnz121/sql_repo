SELECT A.YMD,
          A.US_AMOUNT,
          B.EXC_RATE,
          A.US_AMOUNT * B.EXC_RATE
   FROM ( SELECT  A.YMD YMD,MAX(B.YMD) R_YMD
          FROM    TEST04 A,
                  TEST05 B
          WHERE  A.YMD  LIKE '2018%'
           AND   B.YMD < A.YMD
           GROUP BY A.YMD
        ) C,
          TEST05 B,
          TEST04 A
   WHERE  A.YMD  LIKE '2018%'
    AND   C.YMD = A.YMD
    AND   B.YMD = C.R_YMD;


    SELECT A.YMD, A.US_AMOUNT, B.YMD RYMD, B.EXC_RATE
      FROM TEST04 A,
           TEST05 B
    WHERE  A.YMD LIKE '2018%'
      AND  B.YMD =
          (SELECT MAX(YMD)
             FROM TEST05
            WHERE YMD < A.YMD
          );
