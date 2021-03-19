추가문제

--VEMP_BOSS VIEW에 SALALRY COLUMN을 추가해서 계층 검색을 통해 상위 코드로 SALARY수치 집계
--마지막 컬럼은 자신과 자신의 하위조직 구성 인원들의 SALARY SUM 입니다. 예를 들어 사장은 전직원 부서장은 부서 소속직원의 급여 SUM

  
SELECT * FROM  
  (
    SELECT LPAD(EMP_NAME, LENGTH(EMP_NAME)+(LEVEL*5)-2,'_')AS E_ID,
        EMP_ID, BOSS_NAME, BOSS_ID, SALARY
    FROM VEMP_BOSS
    START WITH EMP_NAME ='김유니'
    CONNECT BY PRIOR EMP_ID = BOSS_ID
    ) A,
    TEMP B
WHERE B.EMP_ID = (SELECT A.EMP_ID           --(A의 EMP_ID 에서 하향검색한 결과 사번들 FROM VEMP_BOSS);
                  FROM VEMP_BOSS
                  START WITH EMP_ID = A.EMP_ID
                  CONNECT BY EMP_ID = BOSS_ID);





--강사님 답안


SELECT A.NO, A.E_ID, A.EMP_ID, A.BOSS_NAME, A.SALARY, A.DEPT_CODE, SUM(B.SALARY)
FROM (SELECT ROWNUM NO, LPAD(EMP_NAME, LENGTH(EMP_NAME) + (LEVEL*5)-2,'_') AS E_ID,
EMP_ID, BOSS_NAME, BOSS_ID, DEPT_CODE, SALARY
FROM VEMP_BOSS
START WITH DEPT_CODE = 'CEO001'
CONNECT BY PRIOR EMP_ID = BOSS_ID
) A, TEMP B
WHERE B.EMP_ID IN (SELECT EMP_ID
                   FROM VEMP_BOSS C
                   CONNECT BY PRIOR C.EMP_ID = C.BOSS_ID
                   START WITH C.EMP_ID = A.EMP_ID)
GROUP BY A.NO, A.E_ID, A.EMP_ID, A.BOSS_NAME, A.DEPT_CODE, A.SALARY
ORDER BY 1;


---SUM SAL값을 VIEW에 추가 그룹함수를 사용했을 경우 해당 그룹함수는 별칭을 지정해줘야 한다. 


CREATE OR REPLACE VIEW VEMP_BOSS 

       AS SELECT A.NO, A.E_ID, A.EMP_ID, A.BOSS_NAME, A.SALARY, A.DEPT_CODE, SUM(B.SALARY) SUMSAL
        FROM (SELECT ROWNUM NO, LPAD(EMP_NAME, LENGTH(EMP_NAME) + (LEVEL*5)-2,'_') AS E_ID,
        EMP_ID, BOSS_NAME, BOSS_ID, DEPT_CODE, SALARY
        FROM VEMP_BOSS1
        START WITH DEPT_CODE = 'CEO001'
        CONNECT BY PRIOR EMP_ID = BOSS_ID
        ) A, TEMP B
        WHERE B.EMP_ID IN (SELECT EMP_ID
                           FROM VEMP_BOSS1 C
                           CONNECT BY PRIOR C.EMP_ID = C.BOSS_ID
                           START WITH C.EMP_ID = A.EMP_ID)
        GROUP BY A.NO, A.E_ID, A.EMP_ID, A.BOSS_NAME, A.DEPT_CODE, A.SALARY
        ORDER BY 1;






                  
--내답안----------------------------------------------------------------------------------

SELECT 
    LPAD(EMP_NAME,LENGTH(EMP_NAME) + (LEVEL*5)-2,'_') LEVELDEPP,
    EMP_ID,
    DEPT_NAME,
    SALARY,
    BOSS_ID,

    (SELECT SUM(SALARY)
    FROM VEMP_BOSS
    START WITH EMP_ID = A.EMP_ID --자기 자신을 비교하여 계층 검색 시작
    CONNECT BY PRIOR EMP_ID = BOSS_ID) SUMSAL

FROM VEMP_BOSS A
START WITH EMP_NAME = '최유미'
CONNECT BY PRIOR EMP_ID = BOSS_ID
ORDER SIBLINGS BY EMP_ID;
                  
                  