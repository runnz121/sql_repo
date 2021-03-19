향상된 GROUP BY 절

SELECT
FROM
WHERE
GROUP BY ROLLUP(중간합계 값)
HAVING
ORDER BY



SELECT DECODE(NO,1,TO_CHAR(SALE_DATE),2,TO_CHAR(SALE_DATE),'합계'),
       DECODE(NO,1,SALE_SITE,2,'소계'),
       SUM(SALE_AMT)
FROM SALE_HIST,
    (SELECT NO FROM T1_DATA WHERE NO<=2)
GROUP BY DECODE(NO,1,TO_CHAR(SALE_DATE),2,TO_CHAR(SALE_DATE),'합계'),
       DECODE(NO,1,SALE_SITE,2,'소계')
ORDER BY 1,2;




>>ROLLUP(위 문장을 ROLLUP을 통해 구현할 수 있다))

SELECT SALE_DATE, SALE_SITE, SUM(SALE_AMT)
FROM SALE_HIST
GROUP BY ROLLUP(SALE_DATE, SALE_SITE);

--NVL 로 NULL 값을 나오게 지정할 수 있음

SELECT SALE_DATE, NVL(SALE_SITE,'소계'), SUM(SALE_AMT)
FROM SALE_HIST
GROUP BY ROLLUP(SALE_DATE, SALE_SITE);


>>CUBE
SELECT 



SELECT SALE_DATE, SALE_SITE, SUM(SALE_AMT)
FROM SALE_HIST
GROUP BY ROLLUP(SALE_DATE, SALE_SITE);



>>GROUPING(해당 자료가 소계용인지 합계용인지 알아 볼수 있게하기위해)

SELECT SALE_DATE, SALE_SITE, SUM(SALE_AMT),
       GROUPING(SALE_DATE),
       GROUPING(SALE_SITE)
FROM SALE_HIST
GROUP BY ROLLUP(SALE_DATE, SALE_SITE) ;


>>GROPUING SETS

GROUPING SETS (
(COL1, COL2),(COL3,COL2))
=
GROUP BY COL1,COL2
UNION ALL
GROUP BY COL3,COL2


>>연쇄 GROUPING



>>RANK

SELECT EMP_ID, EMP_NAME, SALARY,
        DENSE_RANK() OVER(ORDER BY SALARY DESC) AS C1, --중복 순위가 존재해도 순차적으로 다음 순위값 표현
              RANK() OVER(ORDER BY SALARY DESC) AS C2, --중복 순위 개수만큼 다음 순위값도 증가시킴
              RANK() OVER(ORDER BY SALARY) AS C3

FROM TEMP;



>>PARTITON BY

--부서별로 사원별 연봉의 순위를 매길 수 있다.
SELECT DEPT_CODE, EMP_ID, EMP_NAME, SUM(SALARY), --SELECT >> PARTITION >> RANK 순서로 작동

       RANK() OVER --SELECT문의 DATA SET을 저장한 상태에서 RANK() 가 작동한다. SELECT문이랑 같이 작동되는게 아님
       (PARTITION BY DEPT_CODE --DEPT_CODE 별로 나눈 후 SUM(SALARY) 로 DESC 한 후 순위를 매김
       ORDER BY SUM(SALARY) DESC) AS C1

FROM TEMP
GROUP BY DEPT_CODE, EMP_ID, EMP_NAME;



>>

SELECT DEPT_CODE, EMP_ID, SUM(SALARY),
        RANK() OVER
            (PARTITION BY GROUPING(DEPT_CODE),
                GROUPING(EMP_ID)
            ORDER BY SUM(SALARY) DESC) C1
FROM TEMP
GROUP BY ROLLUP(DEPT_CODE, EMP_ID);


>>CUME_DIST

SELECT EMP_ID, EMP_NAME, SALARY, C0, C1,C2,C1*48
FROM (SELECT EMP_ID, EMP_NAME, SALARY,
        RANK() OVER(ORDER BY SALARY) AS C0, --RANKING 표시
        CUME_DIST() OVER(ORDER BY SALARY) AS C1, --누적분포 수치(내가 상위 몇프로인지)...(지정된 순서를 기준으로 자신의 값과 동일한 값의 이전값들의 수 / 동일작용범위 SIZE)
        COUNT(SALARY) OVER (ORDER BY SALARY
                            RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS C2--SALARY를 기준으로 자신과 동일한 값을 포함한 수 (자신을 포함 몇명이 있는지 )
                                                                                    --SALARY별로 순위 정렬하는데 범위를 줌(범위 : (UNBOUNDED PRECDEING =나포함 + 내위의 있는 열 모두 ) ~ 현재 나의 열(순위)) 
                                                                                    --EX)박종빈의 경우 나보다 연봉이 낮은 사람은 없음으로 1번의 순위이고  위에 아무도 없음으로 COUNT도 1이되는것
        FROM TEMP);






SELECT EMP_ID, EMP_NAME, SALARY,
       RANK()            OVER(ORDER BY SALARY) AS C1,
       CUME_DIST()       OVER(ORDER BY SALARY) AS C1,
       PERCENT_RANK()    OVER(ORDER BY SALARY) AS C2,--(자신이 속한 PARTITION내의 자신의 RANK-1) / (자신이 속한 PARTITION내의 ROW 숫자 -1)
       NTILE(10)         OVER(ORDER BY SALARY) AS C3,--전체를 10분위로 보고 순의를 매김
       ROW_NUMBER()      OVER(ORDER BY SALARY) AS C4
FROM TEMP;


사번의 앞 4자리를 입사년도라고 가정하고 동일 입사년도 내에서 각 ROW가 가지는 SALARY 순의 CUME_DIST, PERCENT_RANK,
NTILE(N), ROW_NUMBER의 값을 각각 구해보자

SELECT SUBSTR(EMP_ID,0,4),


CUME_DIST()     OVER(PARTITION BY SUBSTR(EMP_ID,0,4)
                     ORDER BY SALARY DESC) AS CUMEDIST,
PERCENT_RANK()  OVER(PARTITION BY SUBSTR(EMP_ID,0,4)
                     ORDER BY SALARY) AS PERCENTRANK,
NTILE(48)       OVER(PARTITION BY SUBSTR(EMP_ID,0,4)
                     ORDER BY SALARY) AS NTILE48,
ROW_NUMBER()     OVER(PARTITION BY SUBSTR(EMP_ID,0,4)
                     ORDER BY SALARY) AS ROWNUMBER



FROM TEMP;

--정답

SELECT SUBSTR(EMP_ID,1,4), EMP_ID,EMP_NAME, SUM(SALARY),

CUME_DIST()     OVER(PARTITION BY SUBSTR(EMP_ID,1,4)
                     ORDER BY SUM(SALARY) DESC) AS CUMEDIST,
                     
PERCENT_RANK()  OVER(PARTITION BY SUBSTR(EMP_ID,1,4)
                     ORDER BY SUM(SALARY)DESC) AS PERCENTRANK,
                     
NTILE(48)       OVER(PARTITION BY SUBSTR(EMP_ID,1,4)
                     ORDER BY SUM(SALARY)DESC) AS NTILE48,
                     
ROW_NUMBER()     OVER(PARTITION BY SUBSTR(EMP_ID,1,4)
                     ORDER BY SUM(SALARY)DESC) AS ROWNUMBER



FROM TEMP
GROUP BY SUBSTR(EMP_ID,0,4),EMP_ID,EMP_NAME;


>>WINDOWING 함수

SELECT SALE_DATE, SALE_SITE, SALE_ITEM, SALE_AMT, --SELECT 문에서 해당 데이터들을 먼저 추출해서 메모리에 저장해놓은 상태

    SUM(SALE_AMT) OVER (PARTITION BY SALE_ITEM ORDER BY SALE_ITEM ROWS UNBOUNDED PRECEDING) AS C1 --SELECT문의 추출되어 저장된 DATA SET을 SALE_ITEM 으로 그룹지어 SALE_ITEM으로
                                                                                                  --순서 정렬 하는데, 이때 자기보다 위에있는 것이다.
                                                                                                  --위 조건에 해당되게끔 SALE_AMT를 모두 더해서 출력한 컬럼이 C1

FROM SALE_HIST
WHERE SALE_SITE = '01';

SALE_DAT SALE_SITE  SALE_ITEM    SALE_AMT         C1
-------- ---------- ---------- ---------- ----------
01/05/02 01         ERASER           5500       5500
01/05/03 01         ERASER           6500      12000
01/05/04 01         ERASER           3500      15500
01/05/01 01         ERASER           4500      20000
01/05/02 01         NOTEBOOK         5000       5000
01/05/03 01         NOTEBOOK         6000      11000
01/05/04 01         NOTEBOOK         6500      17500
01/05/01 01         NOTEBOOK         9000      26500
01/05/04 01         PENCIL           5500       5500
01/05/03 01         PENCIL           7000      12500
01/05/02 01         PENCIL           6000      18500

SALE_DAT SALE_SITE  SALE_ITEM    SALE_AMT         C1
-------- ---------- ---------- ---------- ----------
01/05/01 01         PENCIL           5000      23500



일자별 사업장별 매출액과 사업장별 매출액의 3일 이동 평균을 구해보자

SELECT SALE_DATE, SALE_SITE, SUM(SALE_AMT),

    AVG(SUM(SALE_AMT)) OVER (PARTITION BY SALE_SITE ORDER BY SALE_DATE RANGE INTERVAL '2' DAY PRECEDING) AS S_SUM --

FROM SALE_HIST
GROUP BY SALE_DATE, SALE_SITE;


TEMP 자료를 이용하여 자신의 급여와 바로 이전 사번 3명의 급여를 이용하여 합계, COUNT, 평균을 구해보자 (ROWS N PRECEDING)



SELECT EMP_ID, SALARY, 
    SUM(SALARY) OVER (ORDER BY EMP_ID ROWS 3 PRECEDING) AS SUM1, --ROWS는 ORDER BY 와 써야함 //사번을 순서대로 나열하였을때 나를 기준으로 이전 3번 사원의 연봉 합을  표현
    COUNT(SALARY) OVER (ORDER BY EMP_ID ROWS 3 PRECEDING) AS COUNT1, --나를 포함해서 위로 3열을 COUNT 한 값이 나옴으로 MAX N + 1 값이 나오기 되는것 따라서 여기선 4가 최대값
    AVG(SALARY) OVER (ORDER BY EMP_ID ROWS 3 PRECEDING) AS AVG1

FROM TEMP;


각 ROW의 판매액, 동일일자/동일품목의 최대판매액, 최대판매액사업장, 해당사업장 최소판매액, 최소판매액사업장 구하기

        --  ROW : 부분집합인 윈도우 크기를 물리적인 단위로 행 집합을 지정

        --  RANGE : 논리적인 주소에 의해 행 집합을 지정

        --  UNBOUNDED PRECEDING : 윈도우의 시작 위치가 첫번째 ROW

        --  UNBOUNDED FOLLOWING : 윈도우의 마지막 위치가 마지막 ROW

        --  CURRENT ROW : 윈도우의 시작 위치가 현재 ROW


SELECT SALE_DATE, SALE_ITEM, SALE_SITE, SALE_AMT,

    FIRST_VALUE(SALE_AMT) --3번 아래의 조건에서 가장 큰 값을 가져오겠다.
                                 OVER (PARTITION BY SALE_DATE, SALE_ITEM --1번 SALE_DATE, SALE_ITEM 으로 GROUP 지은 후
                                 ORDER BY SALE_AMT ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FIRST_AMT_최대판매액, --2번 SALE_AMT로 정렬한 후 나를 기준으로 위모두 포함 아래모두 포함 (즉 모든 열을 범위로 지정)
                                                                                                                                     --PARTITION BY 로 나눠진 범위안에서 다시 적용되는 범위
    
    FIRST_VALUE(SALE_SITE) OVER (PARTITION BY SALE_DATE, SALE_ITEM 
                                 ORDER BY SALE_AMT ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FIRST_SITE_최대판매액사업장,

    LAST_VALUE(SALE_AMT)   OVER (PARTITION BY SALE_DATE, SALE_ITEM
                                 ORDER BY SALE_AMT ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LAST_AMT_최소판매액,

    LAST_VALUE(SALE_SITE)  OVER (PARTITION BY SALE_DATE, SALE_ITEM
                                 ORDER BY SALE_AMT ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LAST_SITE_최소판매액사업장

FROM SALE_HIST;



사업장별 품목의 매출액과 함께 동일사업장 동일 품목의 전일 매출액 과 다음날 매출액을 구해보자(LAG, LEAD)

SELECT SALE_DATE, SALE_SITE, SALE_ITEM, SALE_AMT,

    LAG(SALE_AMT,1) OVER (PARTITION BY SALE_SITE, SALE_ITEM  --LAG : 자신기준 바로 이전값 참조 >> 자기 기준 바로 1 앞의 ROW를 참조
                          ORDER BY SALE_DATE, SALE_SITE, SALE_ITEM) AS LAG_AMT,

    LEAD(SALE_AMT,1) OVER (PARTITION BY SALE_SITE, SALE_ITEM --LEAD : 자신 기준 바로 이후 값 참조 >>자기 기준 바로 1 뒤의 ROW를 참조
                          ORDER BY SALE_DATE, SALE_SITE, SALE_ITEM) AS LEAD_AMT

                                                    
    /*COUNT(SALE_DATE) OVER        (PARTITION BY SALE_SITE, SALE_ITEM
                            ORDER BY SALE_DATE, SALE_SITE, SALE_ITEM) AS CC*/ --같이 실행시켜서 순번 확인하면 쉬움
                         

FROM SALE_HIST;
 