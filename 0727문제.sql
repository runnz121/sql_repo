1]

1.DEPT 의 부서코드와 상위부서코드 정보를 이용해 CEO001에서 시작해 TOP-DOWN 방식의 계층 검색

SELECT DEPT_CODE, PARENT_DEPT, DEPT_NAME
FROM TDEPT
START WITH DEPT_CODE = 'CEO001'
CONNECT BY PRIOR DEPT_CODE = PARENT_DEPT;


----같은걸 밀어넣기한 쿼리

SELECT LPAD(DEPT_CODE, LENGTH(DEPT_CODE)+(LEVEL*2)-2,'_') AS D_CODE, DEPT_NAME, BOSS_ID
FROM TDEPT
START WITH DEPT_CODE = 'CEO001'
CONNECT BY PRIOR DEPT_CODE = PARENT_DEPT;


2.DEPT 의 부서코드와 상위부서코드 정보를 이용해 CD0001에서 시작해 bottom-UP 방식의 계층 검색

SELECT DEPT_CODE, PARENT_DEPT, DEPT_NAME
FROM TDEPT
START WITH DEPT_CODE = 'CD0001'
CONNECT BY PRIOR PARENT_DEPT = DEPT_CODE;


3.CSO001에서 시작하는 TOP-DOWN 방식의 계층검색

SELECT DEPT_CODE, PARENT_DEPT, DEPT_NAME
FROM TDEPT
START WITH DEPT_CODE = 'CSO001'
CONNECT BY PRIOR DEPT_CODE = PARENT_DEPT;



4.1번에서 경영지원(AA0001) 만 조직에서 제외

SELECT DEPT_CODE, PARENT_DEPT, DEPT_NAME
FROM TDEPT
WHERE DEPT_CODE !='AA0001'
START WITH DEPT_CODE = 'CEO001'
CONNECT BY PRIOR DEPT_CODE = PARENT_DEPT
;




5.1번에서 경영지원(AA0001)을 포함한 하위조직 제외

SELECT DEPT_CODE, PARENT_DEPT, DEPT_NAME
FROM TDEPT
START WITH DEPT_CODE = 'CEO001'
CONNECT BY PRIOR DEPT_CODE = PARENT_DEPT
AND DEPT_CODE NOT IN 'AA0001';




2] (일반직원은 자신이 속한 부서장이 자신의 보스이며, 부서장은 자신의 상위부서 부서장이 보스입니다.)

1. 직원정보와 직원의 BOSS 정보를 찾아 직원 계층검색을 지원하는 VEMP_BOSS VIEW 생성하시오


CREATE OR REPLACE VIEW VEMP_BOSS AS

SELECT T.EMP_ID, T.EMP_NAME, D.DEPT_CODE, D.BOSS_ID,
F.EMP_NAME, D.PARENT_DEPT, T.SALARY

FROM TDEPT D, TEMP T, TEMP F

WHERE T.DEPT_CODE = D.DEPT_CODE
AND D.BOSS_ID = F.EMP_ID
ORDER BY EMP_ID;
;




SELECT A.EMP_ID, A.EMP_NAME, A.DEPT_CODE AS DCODE,

DECODE(B.BOSS_ID, A.EMP_ID, /*상위부서 보스*/ C.BOSS_ID, B.BOSS_ID) BOSS_ID



FROM TEMP A, TDEPT B, TDEPT C
WHERE B. DEPT_CODE = A.DEPT_CODE
AND C.DEPT_CODE(+) = B.PARENT_DEPT
ORDER BY A.EMP_ID;





---------------------------------BOSS_NAME도 같이



    CREATE VIEW VEMP_BOSS
            AS 
             SELECT D.EMP_ID, D.EMP_NAME, D.DEPT_CODE, D.DEPT_NAME, D.BOSS_ID, E.EMP_NAME BOSS_NAME,E.SALARY
     FROM( SELECT DISTINCT(A.EMP_ID), A.EMP_NAME, B.DEPT_CODE, B.DEPT_NAME ,B.PARENT_DEPT, 
            DECODE(B.BOSS_ID,A.EMP_ID,C.BOSS_ID,B.BOSS_ID) BOSS_ID
            FROM TEMP A ,TDEPT B,TDEPT C
            WHERE A.DEPT_CODE = B.DEPT_CODE
            AND B.PARENT_DEPT = C.DEPT_CODE(+)
            ORDER BY 1
            )D,TEMP E
     WHERE D.BOSS_ID = E.EMP_ID(+)
     ;


2. 1번의 VIEW를 이용한 19950601에서 시작하는 직원의 TOP-DOWN 계층검색



SELECT *
FROM VEMP_BOSS
START WITH EMP_ID = '19950601'
CONNECT BY NOCYCLE PRIOR  EMP_ID = BOSS_ID;







3. 1번의 VIEW를 이용해 ‘정북악’ 에서 시작하는 직원의 BOTTOM-UP 계층검색

SELECT *
FROM VEMP_BOSS
START WITH EMP_NAME = '정북악'
CONNECT BY NOCYCLE PRIOR  BOSS_ID = EMP_ID;





--직원의 계층검색을 지원하는 쿼리가 어떤 기준으로 정렬되는지 확인합니다.


--직원 계층 검색 VIEW(VEMP_BOSS) 를 이용해 직원의 이름으로 계층검색하고 직원이름이 결과의 첫번째 컬럼으로 나오게 합니다. 해당 결과의 정렬 기준 확인


>>> 같은 LEVEL일 경우 CONNECT BY 에 사용된 컬럼에 의해 정렬

--------EMP_NAME 순으로 빠른게 먼저 나옴 (ㄱㄴㄷㄻㅄ 순..)
SELECT LPAD(EMP_NAME, LENGTH(EMP_NAME) + (LEVEL*5)-2,'_') AS E_ID,EMP_ID, BOSS_NAME, BOSS_ID

FROM VEMP_BOSS

START WITH EMP_NAME = '김유니'
CONNECT BY PRIOR EMP_NAME = BOSS_NAME;

------------------------(EMP_ID가 빠른것보다 차례대로 나옴)
SELECT LPAD(EMP_NAME, LENGTH(EMP_NAME) + (LEVEL*5)-2,'_') AS E_ID,EMP_ID, BOSS_NAME, BOSS_ID
FROM VEMP_BOSS
START WITH EMP_NAME = '김유니'
CONNECT BY PRIOR EMP_ID = BOSS_ID;






















조직정리
1. 조직에 운영총괄(COO001)임원실, 기술총괄(CTO001)임원실, 
   영업총괄(CSO001)임원실, 대표이사(CEO001)임원실이 있으며 
   임원실은 모두 대표이사 임원실이 상위부서이고, 
   대표이사 임원실은 상위부서가 없습니다.


2. 재무,총무의 상위조직은 경영지원이며, 
  H/W,S/W지원의 상위조직은 기술지원이고, 
  영업기획,영업1,영업2의 상위조직은 영업입니다.


3. 경영지원의 상위조직은 운영총괄임원실, 
   기술지원의 상위조직은 기술총괄임원실, 
   영업의 상위조직은 영업총괄 임원실입니다 



4. 각 임원실의 AREA는 하위부서의 AREA와 동일합니다.
위의 데이터 변경 작업을 위해 필요한 DDL이 있다면 알아서 필요한 조치를 취하고 조직 데이터를 완성 하세요