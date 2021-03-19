1]

1. TEMP 에서 자기와 같은 직급의 평균 SALARY 보다 많은 급여를 받는 직원의 급여 검색


SELECT EMP_ID, SALARY
FROM TEMP A
WHERE A.SALARY > (SELECT AVG(SALARY)
                  FROM TEMP B
                  WHERE  A.LEV = B.LEV)
ORDER BY LEV;



2. 1번을  PL/SQL 익명 블록으로 구현

SET SERVEROUTPUT ON;
DECLARE
    V_SAL NUMBER;
    V_NO NUMBER :=0; --:=뜻은  A에 10을 넣는다 >> A:=10 과 같은 말 여기서는 V_NO 변수에 0을 넣는다.

BEGIN
    FOR I IN (SELECT * FROM TEMP)
    LOOP      
        SELECT AVG(SALARY)
        INTO V_SAL
        FROM TEMP
        WHERE LEV = I.LEV;
        
        IF I.SALARY > V_SAL THEN
            V_NO := V_NO +1;
            DBMS_OUTPUT.PUT_LINE('NO:'||V_NO||'EMP_ID:'||I. EMP_ID||', SALARY :' ||I.SALARY);
        END IF;
    END LOOP;
END;



3. TCOM에 최근년도 자료를 기반으로 해당 사번에 속하지 않는 사번만 DISPLAY 해주는 쿼리 작성

SELECT EMP_iD
FROM TEMP
WHERE EMP_ID NOT IN (SELECT EMP_ID
                    FROM TCOM
                    WHERE WORK_YEAR = '2020');


4. 3번을  PL/SQL 익명블록 작성

SET SERVEROUTPUT ON;
DECLARE
    V_NOTIN VARCHAR2(2);
    V_NO NUMBER :=0;

BEGIN   
    FOR I IN (SELECT * FROM TEMP)
    LOOP
        V_NOTIN :='Y';
        FOR K IN (SELECT EMP_ID FROM TCOM WHERE WORK_YEAR ='2020')
        LOOP
            IF I.EMP_ID = K.EMP_ID THEN       
            V_NOTIN := 'N';
           END IF;
        END LOOP;

        IF V_NOTIN = 'Y' THEN  
            V_NO := V_NO +1;
            DBMS_OUTPUT.PUT_LINE('NO:'||V_NO||'EMP_ID:'||I. EMP_ID||', SALARY :' ||I.SALARY);
        END IF;
    END LOOP;
END;

2]
1. SELECT 절에 EMP_ID, EMP_NAME, DEPT_CODE 와 함께 자신의 BOSS를 보여주고 싶은 경우, BOSS_ID를 보여줄 수 있는 방법을 3가지 이상 제시하고 이를 구현 하시오..
   주의 : 자신이 최상위 부서의 부서장이 아닌 하위부서 부서장인 경우 자신의 보스는 상위부서 부서장임 
VIEW생성, 스칼라 서브쿼리이용, FUNCTION 이용, 조인, ALTER TABLE 중 3가지 선택
-스칼러 서브쿼리

SELECT EMP_ID, EMP_NAME,
    (SELECT DECODE(B.BOSS_ID,A.EMP_ID,B.BOSS_ID,C.BOSS_ID) --DECODE에서 TDEPT(B)의 BOSS_ID가 TEMP(A) EMP_ID와 같다면, B의 BOSS_ID를 출력, 그렇지 않는다면, C의 BOSS_ID를 출력
        FROM TDEPT B, TDEPT C
     WHERE B.DEPT_CODE = A.DEPT_CODE --TDEPT의 DEPT_CODE = TEMP의 DEPT_CODE와 같고
        AND C.DEPT_CODE = B.PARENT_DEPT) BOSS_ID --TDEPT(C) 의 DEPT_CODE는 
FROM TEMP A;



-FUNCTION 구현

CREATE OR REPLACE FUNCTION F_BOSS(P_DEPT VARCHAR2, P_EMP NUMBER) RETURN NUMBER AS 
V_BOSS NUMBER;
BEGIN 
    SELECT DECODE(B.BOSS_ID, P_EMP, B.BOSS_ID, C.BOSS_ID)
    INTO V_BOSS
    FROM TDEPT B, TDEPT C 
    WHERE B.DEPT_CODE = P_DEPT
    AND C.DEPT_CODE = B.PARENT_DEPT;

    RETURN V_BOSS;
    
END;

--함수 호출
SELECT EMP_ID EMP_NAME,
    F_BOSS(DEPT_CODE, EMP_ID) BOSS_ID
    FROM TEMP A;


3]

1. 사번,성명, 부서코드를 구해오되 부서장 사번이 빠른 순으로 정렬 (JOIN 없이 서브쿼리 사용)

SELECT EMP_ID, EMP_NAME, DEPT_CODE
FROM TEMP A
ORDER BY (
            SELECT BOSS_ID
            FROM TDEPT B
            WHERE A.DEPT_CODE = B.DEPT_CODE
            );
            
            



2. 소속된 부서의 평균 봉급보다 많은 봉급을 받는 직원의 이름, 급여, 부서코드 


SELECT EMP_ID, EMP_NAME, SALARY, DEPT_CODE
FROM TEMP A
WHERE SALARY > (SELECT AVG(SALARY)
                FROM TEMP B
                WHERE A.DEPT_CODE = B.DEPT_CODE)
ORDER BY 4;



3. 부서가 3개보다 많이 위치해 있는 지역에 위치한 부서에 근무하는 사원의 사번,이름,부서코드  


SELECT EMP_ID, EMP_NAME, DEPT_CODE
FROM TEMP
WHERE DEPT_CODE IN (SELECT DEPT_CODE FROM TDEPT A
                    WHERE 3 < (SELECT COUNT(*) FROM TDEPT
                        WHERE AREA = A.AREA));



4. 이순신의 SALARY를 현재 직급의 상하한 평균으로 변경하는 쿼리 작성 후 COMMIT;


UPDATE TEMP A
SET SALARY =   (SELECT (FROM_SAL + TO_SAL)/2 SALARY
                FROM EMP_LEVEL B                
                WHERE A.LEV = B.LEV)
WHERE EMP_NAME = '이순신';

--------
SELECT EMP_NAME, SALARY
FROM TEMP
WHERE EMP_NAME = '이순신';



5 근무지가 인천이면 10%, 서울이면 7%, 나머지는 5% 인상하여 UPDATE

UPDATE TEMP A

SET SALARY
        = 
         CASE
            WHEN DEPT_CODE IN (SELECT DEPT_CODE
                              FROM TDEPT
                              WHERE AREA = '인천') THEN SALARY*1.1
            WHEN DEPT_CODE IN (SELECT DEPT_CODE
                              FROM TDEPT
                              WHERE AREA = '서울') THEN SALARY*1.07
            ELSE SALARY*1.05
            END;


---다른 답안

UPDATE TEMP A 
SET SALARY = SALARY*
                (SELECT DECODE(AREA, '인천',1.1,'서울',1.07,1.05)
                FROM TDEPT B
                WHERE B.DEPT_CODE = A.DEPT_CODE)




6. 자신을 제외하고 자신과 직급이 같은 직원 누구보다도 더 많은 급여를 받는 직원 삭제

--내답안(틀림 ㅠㅠ)
DELETE FROM TEMP A
WHERE 

LEV   = (SELECT LEV
        FROM TEMP B
        WHERE EMP_ID = '20050404')
        
AND SALARY > (SELECT SALARY
             FROM TEMP
             WHERE EMP_ID = '20050404')
            

AND EMP_ID NOT IN '20050404';



--정식답안
SELECT *
FROM TEMP1 A
WHERE SALARY > ALL (SELECT SALARY
                    FROM TEMP B
                    WHERE B.LEV=A.LEV
                    AND A.EMP_ID <>B.EMP_ID)


7. TCOM에 존재하는 사번의 사원정보 

SELECT EMP_ID, EMP_NAME
FROM TEMP A
WHERE EMP_ID IN (SELECT EMP_ID
                FROM TCOM B
                WHERE A.EMP_ID = B.EMP_ID
                AND WORK_YEAR='2020');

--EXISTS로 썼을시

SELECT *
FROM TEMP A
WHERE EXISTS (SELECT * FROM TCOM WHERE EMP_ID = A.EMP_ID AND WORK_YEAR = '2020');