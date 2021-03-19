BONUS 문제
환경
TEST04 는 일자(YMD)별로 보유 달러금액(US_AMOUNT)을 보관하는 테이블 이다
TEST05는 반기 또는 분기별로 당시의 환율을 가지고 있다.
문제




TEST04기준 
각 RECORD별 일자,
달러금액(#1)과 , 


TEST05에서 
TEST04일자보다 작은 일자 중 
최근 일자가 가지고 있는 환율(#2) , 


--(조건 DATE는 작지만 그 중에서 최신)
원화환산금액(=#1*#2) 을 나오도록 쿼리 구성’ --A.YMD*B.EXC_RATE AS 환산금액


(단, 2018년 DATA만 대상) --WHERE SUBSTR(B.YMD,0,4) = '2018';




추출컬럼 : 달러보유일자, 환율기준일자, 보유달러금액, 환율, 환산금액
4-1 서브쿼리 이용 해결(WHERE 절에 작성)



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



4-2 인라인뷰 이용 해결(FROM 절에 작성)





    SELECT A.YMD, A.US_AMOUNT, B.YMD RYMD, B.EXC_RATE
      FROM TEST04 A,
           TEST05 B
    WHERE  A.YMD LIKE '2018%'
      AND  B.YMD =
          (SELECT MAX(YMD)
             FROM TEST05
            WHERE YMD < A.YMD
          );




1.TEST05에서 2018년도 자료만 가져오기
2.TEST04의 2018년도 자료를 GROUP BY 한다
3.TEST04의 해당 날짜와 TEST05를 비교하여 TEST04보다 아래 날짜중 최신을 선택 <<이게문제

